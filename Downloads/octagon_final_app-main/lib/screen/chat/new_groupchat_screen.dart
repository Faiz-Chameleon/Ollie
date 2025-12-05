import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:octagon/screen/group/group_settings_screen.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'dart:async';
import 'dart:developer';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/group/pusher_implementation/pusher_service.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/services/group_thread_service.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'group_chat_controller.dart';

class NewGroupChatScreen extends StatefulWidget {
  final String groupId;
  final bool isPublic;
  final String userId;
  final String userName;
  final String groupName;

  final String groupImage;
  final String userImage;
  String thread_id;

  NewGroupChatScreen({
    required this.groupId,
    required this.isPublic,
    required this.userId,
    required this.userName,
    required this.groupName,
    required this.groupImage,
    required this.userImage,
    required this.thread_id,
  });

  @override
  State<NewGroupChatScreen> createState() => _NewGroupChatScreenState();
}

class _NewGroupChatScreenState extends State<NewGroupChatScreen> {
  final GroupChatController controller = Get.put(GroupChatController());
  final storage = GetStorage();
  final NetworkAPICall _api = NetworkAPICall();
  final PusherService _pusher = Get.find<PusherService>();
  final List<String> _reactionOptions = const ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥'];
  final Map<String, String> _reactionAliasMap = const {
    ':thumbsup:': '👍',
    ':+1:': '👍',
    ':heart:': '❤️',
    ':joy:': '😂',
    ':laughing:': '😂',
    ':open_mouth:': '😮',
    ':astonished:': '😮',
    ':cry:': '😢',
    ':sob:': '😢',
    ':pray:': '🙏',
    ':fire:': '🔥',
  };

  // String? _threadId;
  StreamSubscription<dynamic>? _pusherSub;
  bool _initializing = false;
  final Map<String, bool> _thumbnailAvailabilityCache = {};
  final Set<String> _thumbnailPrefetchInFlight = <String>{};
  final ItemScrollController _messageScrollController = ItemScrollController();
  final ItemPositionsListener _messagePositionsListener = ItemPositionsListener.create();
  final Map<String, int> _messageIndexLookup = {};

  @override
  void initState() {
    super.initState();
    controller.setGroup(widget.groupId, widget.isPublic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initThreadFlow();
    });
  }

  @override
  void dispose() {
    _pusherSub?.cancel();
    super.dispose();
  }

  Future<void> _initThreadFlow() async {
    if (_initializing) return;
    _initializing = true;
    try {
      if (widget.thread_id.isEmpty) {
        final res = await _createThreadForGroup();
        String? tid = GroupThreadService.extractThreadId(res);
        if (tid == null) {
          Get.snackbar('Error', 'Could not open chat thread for group');
          return;
        }
        widget.thread_id = tid;
      }

      await _loadHistory();

      // Initialize Pusher first
      await _pusher.initializePusher();

      // Wait for connection with better error handling
      final connected = await _pusher.waitUntilConnected(timeout: Duration(seconds: 15));
      if (!connected) {
        log('Pusher connection failed - retrying initialization');
        await _pusher.initializePusher();
        await _pusher.waitUntilConnected(timeout: Duration(seconds: 10));
      }

      // Get user ID with fallback
      final currentUserId = storage.read("current_uid") ?? storage.read("user_id") ?? storage.read("id");
      if (currentUserId == null) {
        log('❌ No user ID found in storage');
        return;
      }

      log('👤 Subscribing with user ID: $currentUserId, thread ID: ${widget.thread_id}');

      // Subscribe to channels
      await _pusher.subscribeToMessengerUser(currentUserId.toString());
      await _pusher.subscribeToMessengerThread(widget.thread_id);

      // Cancel existing subscription
      await _pusherSub?.cancel();

      // Listen to message stream with better debugging
      _pusherSub = _pusher.messageStream.listen((payload) {
        log('📨 Received Pusher message: ${payload.toString()}');

        try {
          final Map<String, dynamic> data = Map<String, dynamic>.from(payload);

          // Debug the incoming data structure
          log('🔍 Incoming data structure: $data');

          final dynamic eventPayload = data['data'];
          final dynamic eventType = data['type'];

          if (eventPayload is Map<String, dynamic> && eventType is String && eventType.isNotEmpty) {
            if (eventType.contains('reaction')) {
              _handleReactionEvent(eventType, eventPayload);
              return;
            }
            _handleMessageStreamEvent(eventType, eventPayload);
            return;
          }

          _handleIncomingMessagePayload(data);
        } catch (e) {
          log('❌ Pusher message parse error: $e');
          log('📦 Problematic payload: $payload');
        }
      }, onError: (error) {
        log('❌ Pusher stream error: $error');
      });

      log('✅ Pusher initialization completed successfully');
    } catch (e) {
      log('❌ _initThreadFlow error: $e');
      Get.snackbar('Error', 'Failed to initialize real-time messaging: ${e.toString()}');
    } finally {
      _initializing = false;
    }
  }

  Future<dynamic> _createThreadForGroup() async {
    final token = storage.read("token") ?? storage.read("auth_token");
    if (token == null) {
      throw Exception('Missing authentication token');
    }
    final uri = Uri.parse('${baseUrl}groups-create-chat-thread');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    request.fields['group_id'] = widget.groupId;

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    log('Thread request status: ${streamed.statusCode} $body');
    if (streamed.statusCode == 200 || streamed.statusCode == 201) {
      return jsonDecode(body);
    }
    if (streamed.statusCode == 401) {
      throw Exception('You are not allowed to create a chat for this group.');
    }
    throw Exception('Failed to create chat thread (${streamed.statusCode})');
  }

  String _absUrl(String? path) {
    if (path == null) return '';
    final p = path.toString().trim();
    if (p.isEmpty) return '';
    if (p.startsWith('http://') || p.startsWith('https://')) return p;

    final cleaned = p.startsWith('/') ? p : '/$p';
    final uri = Uri.tryParse(baseUrl);
    final origin = uri?.hasAuthority == true ? uri!.origin : '';
    if (origin.isNotEmpty) {
      return origin + cleaned;
    }
    final fallbackBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return fallbackBase + cleaned;
  }

  Map<String, dynamic> _mapIncomingToMessage(Map<String, dynamic> data) {
    String senderId = data['owner_id']?.toString() ?? data['owner']?['id']?.toString() ?? data['sender_id']?.toString() ?? '';
    String senderName = '';
    try {
      senderName = data['owner']?['name']?.toString() ?? data['owner']?['base']?['name']?.toString() ?? data['sender_name']?.toString() ?? '';
    } catch (_) {
      senderName = data['sender_name']?.toString() ?? '';
    }

    String senderImage = '';
    try {
      if (data['owner'] != null) {
        final avatar = data['owner']['avatar'];
        if (avatar is Map) {
          senderImage = _absUrl(avatar['md'] ?? avatar['lg'] ?? avatar['sm'] ?? '');
        }
      }
      if (senderImage.isEmpty && data['avatar'] != null) {
        senderImage = _absUrl(data['avatar']?.toString());
      }
    } catch (_) {
      senderImage = _absUrl(data['avatar']?.toString());
    }

    final extraData = _normalizeExtra(data['extra']);
    // Determine message type
    String type = 'text';
    final tv = (data['type_verbose']?.toString() ?? '').toLowerCase();
    final tn = data['type'];
    if (tv.contains('image') || tn == 1)
      type = 'image';
    else if (tv.contains('video') || tn == 4)
      type = 'video';
    else if (tv.contains('audio') || tn == 3)
      type = 'audio';
    else if (tv.contains('document') || tn == 2) type = 'document';

    // Text/body
    final text = data['body'] ?? data['message'] ?? data['text'] ?? '';

    // Media URLs (image/audio/document/video)
    String mediaUrl = '';
    String thumbnailUrl = '';
    try {
      if (type == 'image') {
        if (data['image'] is Map) {
          final img = data['image'];
          mediaUrl = _absUrl(img['lg'] ?? img['md'] ?? img['sm'] ?? '');
        } else if (data['image'] is String) {
          mediaUrl = _absUrl(data['image']);
        } else if (data['media_url'] != null) {
          mediaUrl = _absUrl(data['media_url']?.toString());
        }
      } else if (type == 'audio') {
        mediaUrl = _absUrl(data['audio']?.toString() ?? data['media_url']?.toString() ?? data['url']?.toString());
      } else if (type == 'document') {
        mediaUrl = _absUrl(data['document']?.toString() ?? data['file']?.toString() ?? data['media_url']?.toString());
      } else if (type == 'video') {
        mediaUrl = _absUrl(data['video']?.toString() ?? data['media_url']?.toString() ?? data['url']?.toString());
        // some responses may provide a thumbnail field
        thumbnailUrl = _absUrl(data['thumbnail']?.toString() ?? data['thumbnail_url']?.toString() ?? '');
        if (thumbnailUrl.isEmpty && extraData != null) {
          final thumb = extraData['thumbnail']?.toString();
          if (thumb != null && thumb.isNotEmpty) {
            thumbnailUrl = _absUrl(thumb);
          }
        }
      } else {
        // fallback: any common fields
        mediaUrl = _absUrl(data['media_url']?.toString() ?? data['url']?.toString() ?? '');
      }
    } catch (_) {
      mediaUrl = '';
    }

    final DateTime? parsedCreatedAt = _parseTimestampValue(data['created_at']);
    final DateTime createdAt = parsedCreatedAt ?? DateTime.now();
    if (parsedCreatedAt == null) {
      log('⚠️ Missing created_at for message ${data['id']} (${data['body'] ?? ''}); defaulting to now');
    }
    final DateTime updatedAt = _parseTimestampValue(data['updated_at']) ?? createdAt;
    final DateTime? reactionUpdatedAt = _parseTimestampValue(data['reaction_updated_at']);

    final replyData = _normalizeReplyData(data['reply_to'] ?? data['reply_to_message'] ?? data['parent_message']);
    final reactionUsers = _extractReactionUsers(data);
    final reactionCounts = _extractReactionCounts(data, reactionUsers);
    final reactions =
        reactionCounts.entries.where((e) => (e.key.toString()).isNotEmpty && e.value > 0).map((e) => {'emoji': e.key, 'count': e.value}).toList();

    return {
      'id': data['id']?.toString() ?? '',
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'timestamp': createdAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (reactionUpdatedAt != null) 'reaction_updated_at': reactionUpdatedAt,
      'type': type,
      'text': text?.toString() ?? '',
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'extra': extraData ?? data['extra'],
      'reply_to': replyData,
      'reply_to_id': data['reply_to_id']?.toString() ?? replyData?['id']?.toString() ?? '',
      'reactions': reactions,
      'reaction_users': reactionUsers.map((key, value) => MapEntry(key, value.toList())),
      'raw': data,
    };
  }

  void _handleIncomingMessagePayload(Map<String, dynamic> payload) {
    final normalizedPayload = _unwrapMessagePayload(payload);
    _upsertMappedMessage(normalizedPayload);
  }

  void _handleMessageStreamEvent(String type, Map<String, dynamic> payload) {
    final normalizedPayload = _unwrapMessagePayload(payload);
    final eventThread = _extractThreadId(normalizedPayload);
    log('📡 Structured message event "$type" for thread: $eventThread');

    if (eventThread != null && eventThread != widget.thread_id) {
      log('⏭️ Skipping "$type" event for thread $eventThread');
      return;
    }

    bool handled = true;
    switch (type) {
      case 'message_archived':
        _removeMessageFromList(normalizedPayload['id']?.toString() ?? normalizedPayload['message_id']?.toString());
        break;
      case 'message_edited':
      case 'reaction_added':
      case 'reaction_removed':
      case 'thread_reaction_added':
      case 'thread_reaction_removed':
      case 'embeds_removed':
        final updated = _mapIncomingToMessage(normalizedPayload);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _replaceMessageInList(updated);
        });
        break;
      default:
        handled = false;
        break;
    }
    if (!handled) {
      final id = normalizedPayload['id'] ?? normalizedPayload['message_id'];
      final looksLikeMessage = id != null ||
          normalizedPayload.containsKey('body') ||
          normalizedPayload.containsKey('message') ||
          normalizedPayload.containsKey('video') ||
          normalizedPayload.containsKey('media_url');
      if (looksLikeMessage) {
        final updated = _mapIncomingToMessage(normalizedPayload);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _replaceMessageInList(updated);
        });
      } else {
        log('ℹ️ Unhandled message event type: $type');
      }
    }
  }

  void _handleReactionEvent(String type, Map<String, dynamic> payload) {
    final normalizedPayload = _unwrapMessagePayload(payload);
    final bool hasReactionArrays = normalizedPayload.containsKey('reactions') || normalizedPayload.containsKey('reaction_users');
    final bool hasMessageBody = normalizedPayload['id'] != null && (normalizedPayload.containsKey('body') || hasReactionArrays);

    if (hasMessageBody) {
      if (!hasReactionArrays) {
        log('⚠️ Reaction message payload lacks reaction data: id=${normalizedPayload['id']} thread=${_extractThreadId(normalizedPayload)}');
      }
      _upsertMappedMessage(normalizedPayload);
    }

    final messageId = payload['message_id']?.toString() ?? normalizedPayload['message_id']?.toString() ?? normalizedPayload['id']?.toString();
    if (messageId == null || messageId.isEmpty) {
      log('⚠️ Reaction event missing message id: $payload');
      return;
    }

    final emoji = _extractReactionEmojiFromPayload(payload, normalizedPayload);
    if (emoji.isEmpty) {
      log('⚠️ Reaction event missing emoji: $payload');
      return;
    }

    final reactorId = _extractReactionUserId(payload, normalizedPayload);
    final DateTime? reactionTimestamp = _parseTimestampValue(
      payload['created_at'] ?? normalizedPayload['created_at'] ?? normalizedPayload['updated_at'],
    );
    if (reactorId == null || reactorId.isEmpty) {
      log('⚠️ Reaction event missing reactor id (message: $messageId, emoji: $emoji)');
    } else {
      log('ℹ️ Applying reaction delta -> message: $messageId, emoji: $emoji, reactor: $reactorId, added: ${type.contains('added')}');
    }
    _applyReactionDeltaFromNetwork(
      messageId,
      emoji,
      reactorId,
      type.contains('added'),
      reactionTimestamp: reactionTimestamp,
    );
  }

// here we are
  void _upsertMappedMessage(Map<String, dynamic> normalizedPayload) {
    final incomingThread = _extractThreadId(normalizedPayload);
    log('🧵 Thread check - incoming: $incomingThread, current: ${widget.thread_id}');

    if (incomingThread != null && incomingThread != widget.thread_id) {
      log('⏭️ Skipping message for different thread: $incomingThread');
      return;
    }

    log('✅ Updating UI with message payload for thread: ${incomingThread ?? 'unknown'}');
    final newMessage = _mapIncomingToMessage(normalizedPayload);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _replaceMessageInList(newMessage);
    });
  }

  Map<String, dynamic> _unwrapMessagePayload(Map<String, dynamic> payload) {
    if (payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload['data'] is Map) {
      final dataMap = Map<String, dynamic>.from(payload['data'] as Map);
      if (dataMap['message'] is Map) {
        return Map<String, dynamic>.from(dataMap['message'] as Map);
      }
    }
    return payload;
  }

  String? _extractThreadId(Map<String, dynamic> data) {
    final directThread = data['thread_id'] ?? data['threadId'];
    if (directThread != null && directThread.toString().isNotEmpty) {
      return directThread.toString();
    }

    final thread = data['thread'];
    if (thread is Map && thread['id'] != null) {
      return thread['id'].toString();
    }

    final meta = data['meta'];
    if (meta is Map && meta['thread_id'] != null) {
      return meta['thread_id'].toString();
    }

    return null;
  }

  Map<String, dynamic>? _normalizeReplyData(dynamic raw) {
    if (raw is Map) {
      try {
        String type = 'text';
        final tv = (raw['type_verbose']?.toString() ?? raw['type']?.toString() ?? '').toLowerCase();
        if (tv.contains('image'))
          type = 'image';
        else if (tv.contains('video'))
          type = 'video';
        else if (tv.contains('audio'))
          type = 'audio';
        else if (tv.contains('document')) type = 'document';

        final replyText = raw['body'] ?? raw['message'] ?? raw['text'] ?? '';
        String media = '';
        String thumbnail = '';
        final extra = _normalizeExtra(raw['extra']);
        if (type == 'image' && raw['image'] != null) {
          if (raw['image'] is Map) {
            media = _absUrl(raw['image']['md'] ?? raw['image']['lg'] ?? raw['image']['sm'] ?? '');
          } else {
            media = _absUrl(raw['image']?.toString());
          }
          thumbnail = media;
        } else if (type == 'video') {
          media = _absUrl(raw['media_url']?.toString() ?? raw['video']?.toString());
          thumbnail = _absUrl(raw['thumbnail']?.toString() ?? raw['thumbnail_url']?.toString() ?? '');
          if (thumbnail.isEmpty && extra != null) {
            final thumb = extra['thumbnail']?.toString();
            if (thumb != null && thumb.isNotEmpty) {
              thumbnail = _absUrl(thumb);
            }
          }
          if (thumbnail.isEmpty && raw['image'] is Map) {
            thumbnail = _absUrl(raw['image']['md'] ?? raw['image']['lg'] ?? raw['image']['sm'] ?? '');
          }
        } else if (raw['media_url'] != null) {
          media = _absUrl(raw['media_url']?.toString());
          thumbnail = _absUrl(raw['thumbnail_url']?.toString() ?? raw['thumbnail']?.toString() ?? '');
        }

        return {
          'id': raw['id']?.toString() ?? '',
          'sender_name': raw['sender_name']?.toString() ?? raw['owner']?['name']?.toString() ?? raw['owner']?['base']?['name']?.toString() ?? '',
          'text': replyText?.toString() ?? '',
          'type': type,
          'media_url': media,
          'thumbnail_url': thumbnail,
        };
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic>? _normalizeExtra(dynamic rawExtra) {
    if (rawExtra == null) return null;
    if (rawExtra is Map<String, dynamic>) return rawExtra;
    if (rawExtra is Map) return Map<String, dynamic>.from(rawExtra);
    if (rawExtra is String && rawExtra.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawExtra);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  Map<String, Set<String>> _extractReactionUsers(Map<String, dynamic> data) {
    final Map<String, Set<String>> reactionUsers = {};
    void addUser(String emoji, dynamic userId) {
      emoji = _normalizeReactionEmoji(emoji);
      final id = userId?.toString() ?? '';
      if (emoji.isEmpty || id.isEmpty) return;
      reactionUsers.putIfAbsent(emoji, () => <String>{}).add(id);
    }

    final reactions = data['reactions'];
    if (reactions is List) {
      for (final entry in reactions) {
        if (entry is Map) {
          final emoji = _normalizeReactionEmoji(entry['reaction']?.toString() ?? entry['value']?.toString() ?? '');
          if (emoji.isEmpty) continue;
          if (entry['users'] is List) {
            for (final user in entry['users']) {
              if (user is Map && user['id'] != null) {
                addUser(emoji, user['id']);
              } else {
                addUser(emoji, user);
              }
            }
          } else {
            addUser(emoji, entry['owner_id'] ?? entry['user_id'] ?? entry['user']?['id']);
          }
        }
      }
    } else if (reactions is Map) {
      final payload = reactions['data'];
      if (payload is Map) {
        payload.forEach((key, value) {
          final emojiKey = _normalizeReactionEmoji(key.toString());
          if (emojiKey.isEmpty || value is! List) return;
          for (final item in value) {
            if (item is Map) {
              final emoji = _normalizeReactionEmoji(item['reaction']?.toString() ?? emojiKey);
              addUser(emoji, item['owner_id'] ?? item['user_id'] ?? item['owner']?['id']);
            }
          }
        });
      }
    }
    return reactionUsers;
  }

  Map<String, int> _extractReactionCounts(Map<String, dynamic> data, Map<String, Set<String>> reactionUsers) {
    final Map<String, int> counts = {};
    reactionUsers.forEach((key, value) {
      counts[key] = value.length;
    });

    final totals = data['reaction_totals'];
    if (totals is Map) {
      totals.forEach((key, value) {
        final emoji = key.toString();
        if (emoji.isEmpty) return;
        final count = value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
        if (count > 0) {
          final current = counts[emoji] ?? 0;
          counts[emoji] = count > current ? count : current;
        }
      });
    }
    return counts;
  }

  Map<String, dynamic> _cloneMessage(Map<String, dynamic> message) {
    final clone = Map<String, dynamic>.from(message);
    if (message['reaction_users'] is Map) {
      final Map<String, dynamic> usersClone = {};
      (message['reaction_users'] as Map).forEach((key, value) {
        if (value is List) {
          usersClone[key] = List<String>.from(value.map((e) => e.toString()));
        }
      });
      clone['reaction_users'] = usersClone;
    }
    if (message['reactions'] is List) {
      clone['reactions'] = (message['reactions'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (message['reply_to'] is Map) {
      clone['reply_to'] = Map<String, dynamic>.from(message['reply_to']);
    }
    return clone;
  }

  Map<String, dynamic>? _mapReactionResponse(dynamic payload) {
    if (payload is Map) {
      try {
        final normalized = _mapIncomingToMessage(Map<String, dynamic>.from(payload as Map));
        final id = normalized['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          final existing = _findMessageById(id);
          if (existing != null && existing['timestamp'] != null) {
            normalized['timestamp'] = existing['timestamp'];
          }
          return normalized;
        }
      } catch (e) {
        log('Failed to map reaction response: $e');
      }
    }
    return null;
  }

  Map<String, dynamic>? _findMessageById(String id) {
    for (final message in controller.messages) {
      final existingId = message['id']?.toString();
      final tempId = message['temporary_id']?.toString();
      if (existingId == id || tempId == id) {
        return message;
      }
    }
    return null;
  }

  void _applyLocalReaction(Map<String, dynamic> message, String emoji) {
    emoji = _normalizeReactionEmoji(emoji);
    final userId = widget.userId.toString();
    final Map<String, dynamic> reactionUsers = Map<String, dynamic>.from(message['reaction_users'] ?? {});
    final dynamic existing = reactionUsers[emoji];
    final List<String> users = existing is List ? existing.map((e) => e.toString()).toList() : <String>[];
    if (users.contains(userId)) {
      users.removeWhere((id) => id == userId);
    } else {
      users.add(userId);
    }

    if (users.isEmpty) {
      reactionUsers.remove(emoji);
    } else {
      reactionUsers[emoji] = users;
    }

    final reactions = reactionUsers.entries.map((entry) => {'emoji': entry.key, 'count': (entry.value as List).length}).toList();
    message['reaction_users'] = reactionUsers;
    message['reactions'] = reactions;
  }

  void _replaceMessageInList(Map<String, dynamic> message) {
    final id = message['id']?.toString();
    int index = -1;
    if (id != null && id.isNotEmpty) {
      index = controller.messages.indexWhere((element) => element['id'] == id);
    }
    if (index == -1 && message['temporary_id'] != null) {
      index = controller.messages.indexWhere((element) => element['temporary_id'] == message['temporary_id']);
    }
    if (index != -1) {
      final existing = controller.messages[index];
      if (existing['timestamp'] != null) {
        message['timestamp'] = existing['timestamp'];
      } else if (message['timestamp'] == null) {
        log('⚠️ No timestamp found for message ${message['id']} while replacing; using created_at');
        message['timestamp'] = message['created_at'] ?? DateTime.now();
      }
      if (existing['created_at'] != null && message['created_at'] == null) {
        message['created_at'] = existing['created_at'];
      }
      if (existing['updated_at'] != null && message['updated_at'] == null) {
        message['updated_at'] = existing['updated_at'];
      }
      if (existing['reaction_updated_at'] != null && message['reaction_updated_at'] == null) {
        message['reaction_updated_at'] = existing['reaction_updated_at'];
      }
      if (message['raw'] == null && existing['raw'] != null) {
        message['raw'] = existing['raw'];
      }
      controller.messages[index] = message;
      _prefetchThumbnailIfNeeded(controller.messages[index]);
      controller.messages.refresh();
    } else {
      controller.messages.insert(0, message);
      _prefetchThumbnailIfNeeded(controller.messages[0]);
    }
  }

  void _removeMessageFromList(String? messageId) {
    if (messageId == null || messageId.isEmpty) return;
    final idx = controller.messages.indexWhere((element) => element['id']?.toString() == messageId);
    if (idx != -1) {
      controller.messages.removeAt(idx);
      controller.messages.refresh();
    }
  }

  String _extractReactionEmojiFromPayload(Map<String, dynamic> raw, Map<String, dynamic> normalized) {
    dynamic candidate = raw['reaction'] ?? raw['emoji'] ?? raw['value'] ?? normalized['reaction'] ?? normalized['emoji'] ?? normalized['value'];
    if (candidate is Map) {
      candidate = candidate['reaction'] ?? candidate['emoji'] ?? candidate['alias'];
    }
    if (candidate is String) {
      return _normalizeReactionEmoji(candidate);
    }
    return '';
  }

  String? _extractReactionUserId(Map<String, dynamic> raw, Map<String, dynamic> normalized) {
    dynamic candidate = raw['owner_id'] ??
        raw['user_id'] ??
        raw['provider_id'] ??
        raw['member_id'] ??
        raw['owner']?['id'] ??
        raw['owner']?['provider_id'] ??
        raw['owner']?['base']?['id'] ??
        normalized['owner_id'] ??
        normalized['user_id'];
    if (candidate == null && raw['user'] is Map) {
      candidate = raw['user']['id'];
    }
    if (candidate == null && normalized['owner'] is Map) {
      final owner = normalized['owner'] as Map;
      candidate = owner['id'] ?? owner['provider_id'] ?? owner['base']?['id'];
    }
    return candidate?.toString();
  }

  void _applyReactionDeltaFromNetwork(String messageId, String emoji, String? reactorId, bool added, {DateTime? reactionTimestamp}) {
    final idx = controller.messages.indexWhere(
      (element) => element['id']?.toString() == messageId || element['temporary_id']?.toString() == messageId,
    );
    if (idx == -1) {
      log('⚠️ Reaction event for unknown message id: $messageId');
      return;
    }

    final updated = Map<String, dynamic>.from(controller.messages[idx]);
    final Map<String, dynamic> reactionUsers = Map<String, dynamic>.from(updated['reaction_users'] ?? {});
    final List<String> users = reactionUsers[emoji] is List ? List<String>.from((reactionUsers[emoji] as List).map((e) => e.toString())) : <String>[];

    if (reactorId != null && reactorId.isNotEmpty) {
      if (added) {
        if (!users.contains(reactorId)) users.add(reactorId);
      } else {
        users.removeWhere((id) => id == reactorId);
      }
    }

    if (users.isEmpty) {
      reactionUsers.remove(emoji);
    } else {
      reactionUsers[emoji] = users;
    }

    updated['reaction_users'] = reactionUsers;
    updated['reactions'] = reactionUsers.entries.map((entry) => {'emoji': entry.key, 'count': (entry.value as List).length}).toList();
    if (reactionTimestamp != null) {
      updated['reaction_updated_at'] = reactionTimestamp;
      final DateTime? existingUpdatedAt = _parseTimestampValue(updated['updated_at']);
      if (existingUpdatedAt == null || reactionTimestamp.isAfter(existingUpdatedAt)) {
        updated['updated_at'] = reactionTimestamp;
      }
    }

    controller.messages[idx] = updated;
    controller.messages.refresh();
  }

  void _prefetchThumbnailIfNeeded(Map<String, dynamic> message) {
    final messageId = message['id']?.toString() ?? message['temporary_id']?.toString();
    if (messageId == null || messageId.isEmpty) return;

    void schedule(String url, {int? index}) {
      if (url.isEmpty || url.contains('thumb_ts=')) return;
      if (!_shouldPrefetchThumbnail(url)) return;
      if (_thumbnailAvailabilityCache[url] == false) return;
      final cacheKey = '${messageId}_${index ?? -1}|$url';
      if (_thumbnailPrefetchInFlight.contains(cacheKey)) return;

      _thumbnailPrefetchInFlight.add(cacheKey);
      _ensureThumbnailAvailable(url).then((success) {
        _thumbnailAvailabilityCache[url] = success;
        if (success) {
          final refreshed = _appendThumbnailCacheBuster(url);
          _applyThumbnailUpdate(messageId, refreshed, index: index);
        }
      }).whenComplete(() {
        _thumbnailPrefetchInFlight.remove(cacheKey);
      });
    }

    final single = message['thumbnail_url']?.toString();
    if (single != null && single.isNotEmpty) {
      schedule(single);
    }

    final multi = message['thumbnail_urls'];
    if (multi is List) {
      for (var i = 0; i < multi.length; i++) {
        final entry = multi[i];
        if (entry is String && entry.isNotEmpty) {
          schedule(entry, index: i);
        }
      }
    }
  }

  bool _shouldPrefetchThumbnail(String url) {
    return url.contains('/storage/threads/');
  }

  Future<bool> _ensureThumbnailAvailable(String url) async {
    const maxAttempts = 5;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (await _probeRemoteAsset(url)) {
        return true;
      }
      await Future.delayed(Duration(milliseconds: 600 * (attempt + 1)));
    }
    return false;
  }

  Future<bool> _probeRemoteAsset(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;
      final resp = await http.head(uri);
      return resp.statusCode >= 200 && resp.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  String _appendThumbnailCacheBuster(String url) {
    if (url.contains('thumb_ts=')) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}thumb_ts=${DateTime.now().millisecondsSinceEpoch}';
  }

  void _applyThumbnailUpdate(String messageId, String refreshedUrl, {int? index}) {
    final idx = controller.messages.indexWhere(
      (element) => element['id']?.toString() == messageId || element['temporary_id']?.toString() == messageId,
    );
    if (idx == -1) return;
    final updated = Map<String, dynamic>.from(controller.messages[idx]);
    if (index == null) {
      updated['thumbnail_url'] = refreshedUrl;
    } else {
      final thumbs = (updated['thumbnail_urls'] as List?)?.map((e) => e).toList() ?? [];
      if (index >= thumbs.length) return;
      thumbs[index] = refreshedUrl;
      updated['thumbnail_urls'] = thumbs;
    }
    controller.messages[idx] = updated;
    controller.messages.refresh();
  }

  bool _userHasReacted(Map<String, dynamic>? reactionUsers, String emoji) {
    if (reactionUsers == null) return false;
    final users = reactionUsers[emoji];
    if (users is List) {
      return users.map((e) => e.toString()).contains(widget.userId.toString());
    }
    return false;
  }

  String _normalizeReactionEmoji(String raw) {
    if (raw.isEmpty) return raw;
    if (_reactionOptions.contains(raw)) return raw;
    final trimmed = raw.trim();
    if (_reactionAliasMap.containsKey(trimmed)) {
      return _reactionAliasMap[trimmed]!;
    }
    final alias = trimmed.replaceAll(':', '').toLowerCase();
    for (final entry in _reactionAliasMap.entries) {
      final keyAlias = entry.key.replaceAll(':', '').toLowerCase();
      if (keyAlias == alias) return entry.value;
    }
    return trimmed;
  }

  String _serializeReactionEmoji(String emoji) {
    final match = _reactionAliasMap.entries.firstWhere(
      (entry) => entry.value == emoji,
      orElse: () => const MapEntry('', ''),
    );
    if (match.key.isNotEmpty) return match.key;
    return emoji;
  }

  String _replySnippet(Map<String, dynamic> message) {
    final type = (message['type'] ?? 'text').toString();
    if (type == 'text') {
      final text = message['text']?.toString() ?? '';
      return text.isEmpty ? 'Text message' : text;
    }
    if (type.contains('image')) return 'Photo';
    if (type.contains('video')) return 'Video';
    if (type.contains('audio')) return 'Audio';
    if (type.contains('document')) return 'Document';
    return message['text']?.toString() ?? '';
  }

  Future<void> _loadHistory() async {
    if (widget.thread_id.isEmpty) return;
    try {
      final res = await _api.getApiCall('messenger/threads/${widget.thread_id}/messages?per_page=50');
      List<dynamic> msgs = [];
      if (res is Map && res['data'] is List)
        msgs = res['data'];
      else if (res is List) msgs = res;
      final normalized = msgs.map((m) {
        if (m is Map<String, dynamic>) return _mapIncomingToMessage(m);
        try {
          return _mapIncomingToMessage(Map<String, dynamic>.from(m));
        } catch (_) {
          return {'text': m.toString(), 'sender_name': '', 'sender_id': '', 'sender_image': '', 'timestamp': DateTime.now(), 'type': 'text'};
        }
      }).toList();
      controller.messages.value = List<Map<String, dynamic>>.from(normalized);
      for (final msg in controller.messages) {
        _prefetchThumbnailIfNeeded(msg);
      }
    } catch (e) {
      log('loadHistory error: $e');
    }
  }

  void _handleMessengerUploadResponse(Map<String, dynamic> payload) {
    try {
      final data = Map<String, dynamic>.from(payload);
      final normalized = _mapIncomingToMessage(data);
      _replaceMessageInList(normalized);
    } catch (e) {
      log('Failed to handle messenger upload response: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = controller.messageController.text.trim();
    if (text.isEmpty || widget.thread_id.isEmpty) return;
    final replyTarget = controller.replyingTo.value;
    final tempId = Uuid().v4();
    final optimistic = {
      'temporary_id': tempId,
      'text': text,
      'sender_id': widget.userId,
      'sender_name': widget.userName,
      'sender_image': widget.userImage,
      'timestamp': DateTime.now(),
      'type': 'text',
      'reply_to': replyTarget,
      'reply_to_id': replyTarget?['id']?.toString() ?? '',
    };
    controller.messages.insert(0, optimistic);
    controller.messageController.clear();
    try {
      final payload = {'message': text, 'temporary_id': tempId};
      if (replyTarget != null && (replyTarget['id']?.toString().isNotEmpty ?? false)) {
        payload['reply_to_id'] = replyTarget['id'].toString();
      }
      final res = await _api.postApiCall('messenger/threads/${widget.thread_id}/messages', payload);
      if (res is Map) {
        final Map<String, dynamic> normalizedRes = res is Map<String, dynamic> ? res : Map<String, dynamic>.from(res);
        final idx = controller.messages.indexWhere((m) => m['temporary_id'] == tempId);
        if (idx != -1)
          controller.messages[idx] = _mapIncomingToMessage(normalizedRes);
        else
          controller.messages.insert(0, _mapIncomingToMessage(normalizedRes));
        controller.messages.refresh();
      }
      controller.replyingTo.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Color(0xff653FF6),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),

                widget.isPublic == true
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/ic/Group 5.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),

                          // Centered network image
                          ClipPath(
                            clipper: OctagonClipper(),
                            child: Image.network(
                              'http://3.134.119.154/${widget.groupImage}', // Replace with your image URL
                              width: 45,
                              height: 45,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 45,
                                height: 45,
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Octagon background image
                          Image.asset(
                            'assets/ic/Group 4.png', // Your uploaded PNG asset
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),

                          // Centered network image
                          ClipPath(
                            clipper: OctagonClipper(),
                            child: Image.network(
                              'http://3.134.119.154/${widget.groupImage}', // Replace with your image URL
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 45,
                                height: 45,
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                // Image.network(
                //   "http://3.134.119.154/$groupImage",
                //   scale: 4,
                //   errorBuilder: (context, error, stackTrace) => const Icon(
                //     Icons.broken_image,
                //     color: Colors.white,
                //     size: 32,
                //   ),
                // ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isPublic == true ? "Public Group" : "Private Group",
                      style: whiteColor14TextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.groupName,
                      style: whiteColor20BoldTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Chat Room",
                      style: whiteColor16TextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Obx(() {
              if (controller.isLoadingGroupDetails.value) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }

              if (controller.isGroupCreator.value) {
                return Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Get.to(() => GroupSettingsScreen(groupId: widget.groupId));
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      body: Obx(() {
        final groupedMessages = groupMessagesByDate(controller.messages);
        _messageIndexLookup.clear();
        for (var i = 0; i < groupedMessages.length; i++) {
          final item = groupedMessages[i];
          if (item['type'] == 'message') {
            final msg = item['data'] as Map<String, dynamic>;
            final messageId = msg['id']?.toString() ?? msg['temporary_id']?.toString() ?? '';
            if (messageId.isNotEmpty) {
              _messageIndexLookup[messageId] = i;
            }
          }
        }
        return Column(
          children: [
            // Group details at the top
            Obx(() {
              final details = controller.groupDetails;
              if (details.isEmpty) return SizedBox();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (details['options'] != null)
                      Text(
                        "Update: ${details['options']}",
                        style: TextStyle(
                          color: Color(0xFF653FF6),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (details['dates'] != null)
                      Text(
                        "Date: ${details['dates']}",
                        style: TextStyle(
                          color: Color(0xFF653FF6),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (details['description'] != null)
                      Text(
                        details['description'],
                        style: TextStyle(
                          color: Color(0xFF653FF6),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              );
            }),
            Expanded(
              child: ScrollablePositionedList.builder(
                reverse: true,
                itemScrollController: _messageScrollController,
                itemPositionsListener: _messagePositionsListener,
                itemCount: groupedMessages.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) {
                  final item = groupedMessages[index];
                  if (item['type'] == 'date') {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xff211D39),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['label'],
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    );
                  } else {
                    final msg = item['data'];
                    final isMe = (msg['sender_id']?.toString() ?? '') == widget.userId.toString();
                    return _buildMessageWidget(msg, isMe);
                  }
                },
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final reply = controller.replyingTo.value;
                  if (reply == null) return const SizedBox.shrink();
                  return _buildComposerReplyPreview(reply);
                }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await controller.pickMedia(
                            context,
                            threadId: widget.thread_id,
                            onMessengerMessage: _handleMessengerUploadResponse,
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Obx(() => controller.isUploading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller.messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(),
                      ),
                    ],
                  ),
                ),
              ],
            )
            // else
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   margin: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[800],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.lock,
            //         color: Colors.grey[400],
            //         size: 20,
            //       ),
            //       const SizedBox(width: 8),
            //       Text(
            //         "This group is private. Only members can send messages.",
            //         style: TextStyle(
            //           color: Colors.grey[400],
            //           fontSize: 14,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        );
      }),
    );
  }

  Widget _buildMessageWidget(Map<String, dynamic> message, bool isMe) {
    final messageType = message['type'] ?? 'text';

    return GestureDetector(
      onLongPress: () => _showMessageActions(message),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildUserAvatar(message['sender_image']?.toString() ?? '', widget.groupImage),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.65,
                ),
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTimestamp(message['timestamp']),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!isMe) ...[
                      Text(
                        message['sender_name'] ?? "Unknown",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (message['reply_to'] != null) ...[
                      _buildReplyPreview(message['reply_to']),
                      const SizedBox(height: 6),
                    ],
                    if (messageType == 'image')
                      _buildImageMessage(message)
                    else if (messageType == 'images')
                      _buildMultipleImagesMessage(message)
                    else if (messageType == 'video')
                      _buildVideoMessage(message)
                    else if (messageType == 'videos')
                      _buildMultipleVideosMessage(message)
                    else
                      Text(
                        message['text'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    const SizedBox(height: 4),
                    _buildReactionsRow(message),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message) {
    final imageUrl = message['media_url'];
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Text(
        'Image not available',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey[700],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.grey[700],
          child: const Icon(
            Icons.error,
            color: Colors.red,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleImagesMessage(Map<String, dynamic> message) {
    final mediaUrls = message['media_urls'] as List<dynamic>?;
    if (mediaUrls == null || mediaUrls.isEmpty) {
      return const Text(
        'Images not available',
        style: TextStyle(color: Colors.grey),
      );
    }

    final imageUrls = mediaUrls.cast<String>();
    final int imageCount = imageUrls.length;

    // Determine grid layout based on number of images
    int crossAxisCount = 2;
    double aspectRatio = 1.0;

    if (imageCount == 1) {
      crossAxisCount = 1;
      aspectRatio = 1.0;
    } else if (imageCount == 2) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else if (imageCount == 3) {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    } else if (imageCount == 4) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: Get.width * 0.65,
        maxHeight: 300,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: aspectRatio,
        ),
        itemCount: imageCount,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[700],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[700],
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoMessage(Map<String, dynamic> message) {
    final videoUrl = message['media_url'];
    final thumbnailUrl = message['thumbnail_url'];
    final bool pendingStorageThumbnail =
        thumbnailUrl != null && thumbnailUrl.toString().contains('/storage/threads/') && !thumbnailUrl.toString().contains('thumb_ts=');
    final bool canShowThumbnail = thumbnailUrl != null && thumbnailUrl.isNotEmpty && !pendingStorageThumbnail;

    // Debug logging
    print('=== VIDEO MESSAGE DEBUG ===');
    print('Video URL: $videoUrl');
    print('Thumbnail URL: $thumbnailUrl');
    print('Message type: ${message['type']}');
    print('=== END VIDEO MESSAGE DEBUG ===');

    if (videoUrl == null || videoUrl.isEmpty) {
      return const Text(
        'Video not available',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(videoUrl: videoUrl),
            ),
          );
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              if (canShowThumbnail)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[700],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print('Thumbnail load error: $error');
                      return Container(
                        color: Colors.grey[700],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_file,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  color: Colors.grey[700],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.video_file,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pendingStorageThumbnail ? 'Preparing thumbnail...' : 'Video',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleVideosMessage(Map<String, dynamic> message) {
    final videoUrls = message['media_urls'] as List<dynamic>?;
    final thumbnailUrls = message['thumbnail_urls'] as List<dynamic>?;

    if (videoUrls == null || videoUrls.isEmpty) {
      return const Text(
        'Videos not available',
        style: TextStyle(color: Colors.grey),
      );
    }

    final videoCount = videoUrls.length;

    // Determine grid layout based on number of videos
    int crossAxisCount = 2;
    double aspectRatio = 1.0;

    if (videoCount == 1) {
      crossAxisCount = 1;
      aspectRatio = 1.0;
    } else if (videoCount == 2) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else if (videoCount == 3) {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    } else if (videoCount == 4) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: Get.width * 0.65,
        maxHeight: 300,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: aspectRatio,
        ),
        itemCount: videoCount,
        itemBuilder: (context, index) {
          final thumbnailUrl = thumbnailUrls != null && index < thumbnailUrls.length ? thumbnailUrls[index] as String? : null;
          final pendingStorageThumbnail = thumbnailUrl != null && thumbnailUrl.contains('/storage/threads/') && !thumbnailUrl.contains('thumb_ts=');
          final canShowThumbnail = thumbnailUrl != null && thumbnailUrl.isNotEmpty && !pendingStorageThumbnail;

          return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                if (canShowThumbnail)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[700],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[700],
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        pendingStorageThumbnail ? 'Preparing thumbnail...' : 'Video',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplyPreview(Map<String, dynamic> reply) {
    final sender = reply['sender_name']?.toString() ?? 'Unknown';
    final snippet = _replySnippet(reply);
    final type = (reply['type'] ?? '').toString();
    final mediaUrl = reply['media_url']?.toString() ?? '';
    final thumbnailUrl = reply['thumbnail_url']?.toString() ?? '';
    final isImage = type.contains('image') && mediaUrl.isNotEmpty;
    final isVideo = type.contains('video');
    final previewUrl = isVideo ? thumbnailUrl : mediaUrl;
    final hasPreview = previewUrl.isNotEmpty;
    final replyId = reply['id']?.toString() ?? '';
    final enableNavigation = replyId.isNotEmpty && (isImage || isVideo);

    Widget? preview;
    if (isImage || isVideo) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasPreview)
              CachedNetworkImage(
                imageUrl: previewUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey[700],
                  child: const Center(child: SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2))),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey[700],
                  child: Icon(isVideo ? Icons.videocam : Icons.image_not_supported, size: 20, color: Colors.white),
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                color: Colors.grey[700],
                child: Icon(isVideo ? Icons.videocam : Icons.image, color: Colors.white70, size: 20),
              ),
            if (isVideo)
              const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      );
    }

    final content = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (preview != null) ...[
            preview,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!enableNavigation) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _scrollToMessage(replyId),
      child: content,
    );
  }

  Widget _buildReactionsRow(Map<String, dynamic> message) {
    final reactions = (message['reactions'] as List?) ?? const [];
    if (reactions.isEmpty) return const SizedBox.shrink();
    final reactionUsers = message['reaction_users'] as Map<String, dynamic>?;
    final chips = <Widget>[];
    for (final reaction in reactions) {
      final emoji = reaction['emoji']?.toString() ?? '';
      if (emoji.isEmpty) continue;
      final count = reaction['count'] ?? 0;
      final isMine = _userHasReacted(reactionUsers, emoji);
      chips.add(
        GestureDetector(
          onTap: () => _handleReactionSelection(message, emoji),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMine ? const Color(0xff653FF6) : Colors.white12,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(color: isMine ? Colors.white : Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: chips,
    );
  }

  Future<void> _scrollToMessage(String? messageId) async {
    if (messageId == null || messageId.isEmpty) return;
    final index = _messageIndexLookup[messageId];
    if (index == null) {
      log('⚠️ Unable to locate message index for $messageId');
      return;
    }
    if (!_messageScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (!_messageScrollController.isAttached) {
      log('⚠️ Message list is not attached to scroll controller');
      return;
    }
    await _messageScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  Widget _buildComposerReplyPreview(Map<String, dynamic> reply) {
    final sender = reply['sender_name']?.toString() ?? 'Unknown';
    final snippet = _replySnippet(reply);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        border: Border(
          left: BorderSide(color: Color(0xff653FF6), width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to $sender',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.clearReply(),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? imageUrl, String groupImage) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ),
        Positioned(
          bottom: -20,
          child: ClipPath(
            clipper: OctagonClipper(),
            child: Container(
              width: 30,
              height: 30,
              color: Colors.black, // Optional: for border effect
              child: Image.network(
                "http://3.134.119.154/$groupImage",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: Icon(Icons.broken_image, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showMessageActions(Map<String, dynamic> message) {
    if (widget.thread_id.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1F1A37),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 12,
                  children: _reactionOptions
                      .map(
                        (emoji) => GestureDetector(
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _handleReactionSelection(message, emoji);
                          },
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.reply, color: Colors.white),
                  title: const Text('Reply', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.startReply(message);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleReactionSelection(Map<String, dynamic> message, String emoji) async {
    if (widget.thread_id.isEmpty) return;
    final messageId = message['id']?.toString();
    if (messageId == null || messageId.isEmpty) return;
    final reactionUsers = message['reaction_users'] as Map<String, dynamic>?;
    if (_userHasReacted(reactionUsers, emoji)) {
      Get.snackbar('Reaction already sent', 'You have already reacted with $emoji');
      return;
    }
    final payloadEmoji = _serializeReactionEmoji(emoji);
    final optimistic = _cloneMessage(message);
    _applyLocalReaction(optimistic, emoji);
    _replaceMessageInList(optimistic);
    bool reverted = false;
    try {
      final res = await controller.reactToMessage(threadId: widget.thread_id, messageId: messageId, emoji: payloadEmoji);
      final normalized = _mapReactionResponse(res);
      if (normalized != null) {
        _replaceMessageInList(normalized);
      }
    } catch (e) {
      reverted = true;
      _replaceMessageInList(_mapIncomingToMessage(message['raw'] ?? message));
      Get.snackbar('Reaction failed', e.toString());
    } finally {
      if (reverted) {
        controller.messages.refresh();
      }
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    final DateTime? dateTime = _parseTimestampValue(timestamp);
    if (dateTime == null) return 'now';
    try {
      return timeago.format(dateTime);
    } catch (_) {
      return 'now';
    }
  }

  // Helper to group messages by date
  List<Map<String, dynamic>> groupMessagesByDate(List<Map<String, dynamic>> messages) {
    List<Map<String, dynamic>> grouped = [];
    String? lastDate;

    for (var msg in messages) {
      final DateTime dateTime = _parseTimestampValue(msg['timestamp']) ?? DateTime.now();
      final dateLabel = "${dateTime.year}/${dateTime.month}/${dateTime.day} ${_weekdayString(dateTime.weekday)}";

      if (lastDate != dateLabel) {
        grouped.add({'type': 'date', 'label': dateLabel});
        lastDate = dateLabel;
      }
      grouped.add({'type': 'message', 'data': msg});
    }
    return grouped;
  }

  String _weekdayString(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  DateTime? _parseTimestampValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      try {
        return DateTime.parse(trimmed);
      } catch (_) {
        final numeric = num.tryParse(trimmed);
        if (numeric != null) {
          return _parseTimestampValue(numeric);
        }
      }
    } else if (value is int) {
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    } else if (value is double) {
      final millis = (value > 1000000000000) ? value.toInt() : (value * 1000).toInt();
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return null;
  }
}

// Add OctagonClipper for octagon shape
class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double s = w < h ? w : h;
    final double k = 0.293; // Octagon constant

    return Path()
      ..moveTo(k * s, 0)
      ..lineTo((1 - k) * s, 0)
      ..lineTo(s, k * s)
      ..lineTo(s, (1 - k) * s)
      ..lineTo((1 - k) * s, s)
      ..lineTo(k * s, s)
      ..lineTo(0, (1 - k) * s)
      ..lineTo(0, k * s)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OctagonBorderPainter extends CustomPainter {
  final Color borderColor;
  final double strokeWidth;

  OctagonBorderPainter({
    this.borderColor = Colors.yellow,
    this.strokeWidth = 4.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double s = w < h ? w : h;
    final double k = 0.293;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(k * s, 0)
      ..lineTo((1 - k) * s, 0)
      ..lineTo(s, k * s)
      ..lineTo(s, (1 - k) * s)
      ..lineTo((1 - k) * s, s)
      ..lineTo(k * s, s)
      ..lineTo(0, (1 - k) * s)
      ..lineTo(0, k * s)
      ..close();

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is OctagonBorderPainter) {
      return oldDelegate.borderColor != borderColor || oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}

// Add this widget at the end of the file or in a suitable place
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _errorMessage;
  bool _fallbackTried = false;
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  Future<void> _startPlayback() async {
    final controller = VideoPlayerController.network(
      widget.videoUrl,
      httpHeaders: const {'Range': 'bytes=0-'},
    );
    await _initializeController(controller);
  }

  Future<void> _initializeController(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      _controller?.dispose();
      setState(() {
        _controller = controller;
        _errorMessage = null;
      });
      controller.play();
    } on PlatformException catch (e) {
      controller.dispose();
      if (!_fallbackTried && _isRangeError(e)) {
        _fallbackTried = true;
        await _downloadAndPlay();
      } else {
        if (mounted) {
          setState(() => _errorMessage = e.message ?? 'Failed to load video');
        }
      }
    } catch (e) {
      controller.dispose();
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  bool _isRangeError(PlatformException e) {
    final text = '${e.message} ${e.details}'.toLowerCase();
    return text.contains('coremediaerrordomain') || text.contains('byte range') || text.contains('-12939');
  }

  Future<void> _downloadAndPlay() async {
    if (!mounted) return;
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = null;
    });

    final uri = Uri.parse(widget.videoUrl);
    final client = http.Client();
    File? tempFile;

    try {
      final response = await client.send(http.Request('GET', uri));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dir = await getTemporaryDirectory();
        tempFile = File('${dir.path}/cached_video_${DateTime.now().millisecondsSinceEpoch}.mp4');
        final sink = tempFile.openWrite();
        final completer = Completer<void>();
        final total = response.contentLength ?? 0;
        int received = 0;

        response.stream.listen(
          (chunk) {
            received += chunk.length;
            sink.add(chunk);
            if (total > 0 && mounted) {
              setState(() => _downloadProgress = received / total);
            }
          },
          onDone: () async {
            await sink.close();
            completer.complete();
          },
          onError: (error) async {
            await sink.close();
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
          cancelOnError: true,
        );

        await completer.future;
        _cachedFile = tempFile;
        await _initializeController(VideoPlayerController.file(tempFile));
      } else {
        if (mounted) {
          setState(() => _errorMessage = 'Download failed (${response.statusCode})');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Download failed: $e');
      }
      if (tempFile != null) {
        await tempFile.delete().catchError((_) {});
      }
    } finally {
      client.close();
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _cachedFile?.delete().catchError((_) {});
    super.dispose();
  }

  void _togglePlayback() {
    final ctrl = _controller;
    if (ctrl == null) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      ctrl.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_errorMessage != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isDownloading
                ? null
                : () {
                    _fallbackTried = false;
                    _cachedFile?.delete().catchError((_) {});
                    _cachedFile = null;
                    _startPlayback();
                  },
            child: const Text('Retry'),
          ),
        ],
      );
    } else if (_isDownloading) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            'Downloading ${(100 * _downloadProgress).clamp(0, 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );
    } else if (_controller != null && _controller!.value.isInitialized) {
      content = AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    } else {
      content = const CircularProgressIndicator();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: content),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (_controller != null && _controller!.value.isInitialized)
          ? FloatingActionButton(
              backgroundColor: Colors.white24,
              onPressed: _togglePlayback,
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
