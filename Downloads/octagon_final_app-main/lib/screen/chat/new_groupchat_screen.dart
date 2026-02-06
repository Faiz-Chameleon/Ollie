import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:octagon/screen/group/group_settings_screen.dart';
import 'package:octagon/screen/profile/other_user_profile.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:developer';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/common/create_post_controller.dart';
import 'package:octagon/screen/group/pusher_implementation/pusher_service.dart';
import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/services/group_thread_service.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/intl.dart';

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
  final int otheruserId;

  NewGroupChatScreen({
    required this.userId,
    required this.groupId,
    required this.isPublic,
    required this.otheruserId,
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
  static const String _heartReactionEmoji = '❤️';
  final GroupChatController controller = Get.put(GroupChatController());
  final CreatePostController _postController = Get.put(CreatePostController());
  final storage = GetStorage();
  final NetworkAPICall _api = NetworkAPICall();
  final PusherService _pusher = Get.find<PusherService>();
  final List<String> _reactionOptions = const [_heartReactionEmoji];
  final Map<String, String> _reactionAliasMap = const {
    ':heart:': _heartReactionEmoji,
    ':love:': _heartReactionEmoji,
    ':like:': _heartReactionEmoji,
  };

  // String? _threadId;
  StreamSubscription<dynamic>? _pusherSub;
  bool _initializing = false;
  final Map<String, bool> _thumbnailAvailabilityCache = {};
  final Set<String> _thumbnailPrefetchInFlight = <String>{};
  final ItemScrollController _messageScrollController = ItemScrollController();
  final ItemPositionsListener _messagePositionsListener = ItemPositionsListener.create();
  final Map<String, int> _messageIndexLookup = {};
  final Set<String> _expandedThreads = <String>{};
  final RegExp _mentionMatcher = RegExp(r'@([^\s@]*)$');
  Timer? _mentionSearchDebounce;
  TextRange? _activeMentionRange;
  bool _isMentionPanelVisible = false;
  static const int _defaultVisibleReplies = 3;
  bool _showJumpToLatest = false;
  bool _isBlockedByAdmin = false;
  String _blockNotice = 'You have been blocked from this group by an admin.';

  @override
  void initState() {
    super.initState();
    controller.setGroup(widget.groupId, widget.isPublic);
    controller.messageController.addListener(_handleComposerTextChanged);
    _messagePositionsListener.itemPositions.addListener(_handleMessageListPositionsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initThreadFlow();
    });
  }

  @override
  void dispose() {
    _pusherSub?.cancel();
    _mentionSearchDebounce?.cancel();
    controller.messageController.removeListener(_handleComposerTextChanged);
    _messagePositionsListener.itemPositions.removeListener(_handleMessageListPositionsChanged);
    controller.clearMentionResults();
    super.dispose();
  }

  Future<void> _initThreadFlow() async {
    if (_initializing) return;
    _initializing = true;
    try {
      // Get user ID with fallback
      final currentUserId = storage.read("current_uid") ?? storage.read("user_id") ?? storage.read("id");
      if (currentUserId == null) {
        log('❌ No user ID found in storage');
        return;
      }

      if (widget.thread_id.isEmpty) {
        final res = await _createThreadForGroup();
        String? tid = GroupThreadService.extractThreadId(res);
        if (tid == null) {
          Get.snackbar('Error', 'Could not open chat thread for group');
          return;
        }
        widget.thread_id = tid;
      }

      final blocked = await _checkBlockedStatus(widget.thread_id, currentUserId.toString());
      if (blocked) {
        return;
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

  Future<bool> _checkBlockedStatus(String threadId, String userId) async {
    try {
      final res = await _api.checkGroupUserBlocked(threadId: threadId, userId: userId);
      final blocked = _extractBlockedFlag(res);
      if (blocked) {
        final message = res['message']?.toString() ?? (res['success'] is Map ? res['success']['message']?.toString() : null);
        if (message != null && message.isNotEmpty) {
          _blockNotice = message;
        }
        if (mounted) {
          setState(() {
            _isBlockedByAdmin = true;
          });
        } else {
          _isBlockedByAdmin = true;
        }
        controller.messageController.clear();
        Get.snackbar('Blocked', _blockNotice);
      }
      return blocked;
    } catch (e) {
      log('❌ Failed to check blocked status: $e');
      return false;
    }
  }

  bool _extractBlockedFlag(Map<String, dynamic> payload) {
    final direct =
        _parseBool(payload['blocked']) ?? _parseBool(payload['is_blocked']) ?? _parseBool(payload['isBlocked']) ?? _parseBool(payload['status']);
    if (direct != null) return direct;

    final success = payload['success'];
    if (success is Map<String, dynamic>) {
      return _parseBool(success['blocked']) ??
          _parseBool(success['is_blocked']) ??
          _parseBool(success['isBlocked']) ??
          _parseBool(success['status']) ??
          false;
    }
    if (success is bool) {
      return success;
    }
    return false;
  }

  bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == '1' || normalized == 'true' || normalized == 'blocked') return true;
      if (normalized == '0' || normalized == 'false') return false;
    }
    return null;
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
    final String messageId = data['id']?.toString() ??
        data['message_id']?.toString() ??
        data['message']?['id']?.toString() ??
        data['message']?['message_id']?.toString() ??
        '';
    if (messageId.isEmpty) {
      log('⚠️ Incoming message payload missing id fields. Keys: ${data.keys}');
    } else if (data['id'] == null && data['message_id'] != null) {
      log('ℹ️ Using message_id=${data['message_id']} as fallback identifier');
    }

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
        final avatar = data['owner']['base'];
        if (avatar is Map) {
          senderImage = _absUrl(avatar['photo'] ?? avatar['photo'] ?? avatar['photo'] ?? '');
        }
      }
      if (senderImage.isEmpty && data['owner'] != null) {
        senderImage = _absUrl(data['owner']['base']['photo']?.toString());
      }
    } catch (_) {
      senderImage = _absUrl(data['owner']?.toString());
    }
    String userIndividualGroupImage = '';
    try {
      if (data['owner'] != null) {
        final avatar = data['owner']['base'];
        if (avatar is Map) {
          userIndividualGroupImage = _absUrl(avatar['user_group_img'] ?? '');
        }
      }
      if (userIndividualGroupImage.isEmpty && data['owner'] != null) {
        userIndividualGroupImage = _absUrl(data['owner']['base']['user_group_img']?.toString());
      }
    } catch (_) {
      userIndividualGroupImage = _absUrl(data['owner']?.toString());
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
    String text = data['body']?.toString() ?? data['message']?.toString() ?? data['text']?.toString() ?? '';

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

    if (_isMediaMessageType(type) && text.trim().isNotEmpty) {
      final trimmed = text.trim();
      if (_looksLikeUrl(trimmed) || trimmed == mediaUrl || trimmed == thumbnailUrl) {
        text = '';
      }
    }

    final replyData = _normalizeReplyData(data['reply_to'] ?? data['reply_to_message'] ?? data['parent_message']);
    final reactionUsers = _extractReactionUsers(data);
    final reactionCounts = _extractReactionCounts(data, reactionUsers);
    final reactions = reactionCounts.entries
        .where((e) => (e.key.toString()).isNotEmpty && e.value > 0 && _isSupportedReaction(e.key))
        .map((e) => {'emoji': e.key, 'count': e.value})
        .toList();

    return {
      'id': messageId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'temporary_id': data['temporary_id']?.toString() ?? data['temp_id']?.toString() ?? data['temporaryId']?.toString(),
      'timestamp': createdAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (reactionUpdatedAt != null) 'reaction_updated_at': reactionUpdatedAt,
      'type': type,
      'text': text,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'extra': extraData ?? data['extra'],
      'reply_to': replyData,
      'reply_to_id': data['reply_to_id']?.toString() ?? replyData?['id']?.toString() ?? '',
      'reactions': reactions,
      'reaction_users': reactionUsers.map((key, value) => MapEntry(key, value.toList())),
      'raw': data,
      'group_image': userIndividualGroupImage,
      "userType": data['owner']['base']['user_type']?.toString() ?? '',
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
      case 'user_blocked':
        _handleUserBlockedEvent(normalizedPayload);
        break;
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

  void _handleUserBlockedEvent(Map<String, dynamic> payload) {
    final blockedUserId = _extractBlockedUserId(payload);
    final currentUserId =
        widget.userId.isNotEmpty ? widget.userId : (storage.read("current_uid") ?? storage.read("user_id") ?? storage.read("id"))?.toString();
    if (blockedUserId == null || currentUserId == null || blockedUserId != currentUserId) {
      return;
    }

    final message = payload['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      _blockNotice = message;
    }

    if (mounted) {
      setState(() {
        _isBlockedByAdmin = true;
      });
    } else {
      _isBlockedByAdmin = true;
    }
    controller.messageController.clear();
    Get.snackbar('Blocked', _blockNotice);
  }

  String? _extractBlockedUserId(Map<String, dynamic> payload) {
    final direct = payload['user_id'] ?? payload['blocked_user_id'] ?? payload['blockedUserId'];
    if (direct != null && direct.toString().isNotEmpty) {
      return direct.toString();
    }
    final user = payload['user'];
    if (user is Map && user['id'] != null) {
      return user['id'].toString();
    }
    return null;
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
      if (emoji.isEmpty || id.isEmpty || !_isSupportedReaction(emoji)) return;
      reactionUsers.putIfAbsent(emoji, () => <String>{}).add(id);
    }

    final reactions = data['reactions'];
    if (reactions is List) {
      for (final entry in reactions) {
        if (entry is Map) {
          final emoji = _normalizeReactionEmoji(entry['reaction']?.toString() ?? entry['value']?.toString() ?? '');
          if (emoji.isEmpty || !_isSupportedReaction(emoji)) continue;
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
          if (emojiKey.isEmpty || value is! List || !_isSupportedReaction(emojiKey)) return;
          for (final item in value) {
            if (item is Map) {
              final emoji = _normalizeReactionEmoji(item['reaction']?.toString() ?? emojiKey);
              if (!_isSupportedReaction(emoji)) continue;
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
      if (_isSupportedReaction(key)) {
        counts[key] = value.length;
      }
    });

    final totals = data['reaction_totals'];
    if (totals is Map) {
      totals.forEach((key, value) {
        final emoji = key.toString();
        if (emoji.isEmpty || !_isSupportedReaction(emoji)) return;
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
    if (!_isSupportedReaction(emoji)) return;
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
      if (!_isRenderableMessage(message)) {
        log('🚫 Skipping non-renderable payload (id=$id, temp=${message['temporary_id']}). Likely reaction-only update.');
        return;
      }
      log('🆕 Inserting new message entry (id=$id, temp=${message['temporary_id']}). Text preview: "${message['text'] ?? ''}"');
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
    if (!_isSupportedReaction(emoji)) {
      log('⚠️ Ignoring unsupported reaction update: $emoji');
      return;
    }
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

  bool _isSupportedReaction(String emoji) {
    return emoji == _heartReactionEmoji;
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

  bool _isMediaMessageType(String type) {
    final normalized = type.toLowerCase();
    return normalized == 'image' || normalized == 'images' || normalized == 'video' || normalized == 'videos';
  }

  String? _extractMediaCaption(Map<String, dynamic> message) {
    final type = (message['type'] ?? '').toString();
    if (!_isMediaMessageType(type)) return null;
    final extra = _normalizeExtra(message['extra']);
    final extraCaption = extra?['caption']?.toString().trim();
    if (extraCaption != null && extraCaption.isNotEmpty) {
      return extraCaption;
    }
    // final text = (message['text']?.toString() ?? '').trim();
    // if (text.isEmpty || _looksLikeUrl(text)) return null;
    // return text;
  }

  bool _looksLikeUrl(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://') || trimmed.startsWith('www.')) return true;
    final uri = Uri.tryParse(trimmed);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  String _replySnippet(Map<String, dynamic> message) {
    final type = (message['type'] ?? 'text').toString();
    final caption = _extractMediaCaption(message);
    if (caption != null) return caption;
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
    if (_isBlockedByAdmin) {
      Get.snackbar('Blocked', _blockNotice);
      return;
    }
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
    _hideMentionPanel();
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
      backgroundColor: Color(0xff191a23),
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
                          GestureDetector(
                            onTap: () {
                              Get.to(() => OtherUserProfileScreen(userId: widget.otheruserId));
                            },
                            child: ClipPath(
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
            Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: IconButton(
                icon: const Icon(Icons.perm_media, color: Colors.white),
                onPressed: _openMediaGallery,
              ),
            ),
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
        final threadedMessages = _buildThreadedMessages(controller.messages);
        final groupedMessages = groupMessagesByDate(threadedMessages);
        _messageIndexLookup.clear();
        for (var i = 0; i < groupedMessages.length; i++) {
          final item = groupedMessages[i];
          if (item['type'] == 'message') {
            final msg = item['data'] as Map<String, dynamic>;
            _registerThreadIndices(msg, i);
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
              child: Stack(
                children: [
                  ScrollablePositionedList.builder(
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
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                        return _buildMessageWidget(msg);
                      }
                    },
                  ),
                  if (_showJumpToLatest)
                    Positioned(
                      right: 16,
                      bottom: 24,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: const Color(0xff653FF6),
                        onPressed: _scrollToLatest,
                        child: const Icon(Icons.arrow_downward, color: Colors.white),
                      ),
                    ),
                ],
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
                _buildMentionSuggestions(),
                _isBlockedByAdmin
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFCE8E6),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Text(
                          _blockNotice,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  hintText: "Write message...",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _sendMessage();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
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

  Widget _buildMessageWidget(Map<String, dynamic> message) {
    final replies = (message['thread_children'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final threadKey = _threadKey(message);
    final bool hasReplies = replies.isNotEmpty;
    final bool isExpanded = hasReplies && _expandedThreads.contains(threadKey);
    final bool needsToggle = replies.length > _defaultVisibleReplies;
    final List<Map<String, dynamic>> repliesToDisplay = (!needsToggle || isExpanded) ? replies : replies.take(_defaultVisibleReplies).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageBubble(
            message,
            isThreadReply: false,
            showReplyPreview: true,
          ),
          if (hasReplies) ...[
            _buildReplyThread(repliesToDisplay),
            if (needsToggle) _buildReplyToggleButton(threadKey, replies.length, isExpanded),
          ],
        ],
      ),
    );
  }

  void _openMediaGallery() {
    final media = _gatherMediaCollections();
    if (media.images.isEmpty && media.videos.isEmpty) {
      Get.snackbar('No media yet', 'No images or videos shared in this chat.');
      return;
    }
    Get.to(() => MediaGalleryScreen(images: media.images, videos: media.videos));
  }

  _MediaCollections _gatherMediaCollections() {
    final images = <MediaAttachment>[];
    final videos = <MediaAttachment>[];

    void collectFromMessage(Map<String, dynamic> message) {
      final type = (message['type'] ?? '').toString().toLowerCase();
      final timestamp = message['timestamp'] ?? message['created_at'];
      final messageId = message['id']?.toString() ?? message['temporary_id']?.toString() ?? '';

      void addAttachment({
        required List<MediaAttachment> target,
        required dynamic url,
        dynamic thumbnail,
        required bool isVideo,
      }) {
        if (url == null) return;
        final resolved = _absUrl(url.toString());
        if (resolved.isEmpty) return;
        final thumb = thumbnail == null ? null : _absUrl(thumbnail.toString());
        target.add(
          MediaAttachment(
            url: resolved,
            thumbnailUrl: thumb,
            isVideo: isVideo,
            timestamp: _parseTimestampValue(timestamp),
            messageId: messageId,
          ),
        );
      }

      if (type == 'image') {
        addAttachment(target: images, url: message['media_url'], isVideo: false);
      } else if (type == 'images') {
        final urls = message['media_urls'];
        if (urls is List) {
          for (final url in urls) {
            addAttachment(target: images, url: url, isVideo: false);
          }
        }
      } else if (type == 'video') {
        addAttachment(
          target: videos,
          url: message['media_url'],
          thumbnail: message['thumbnail_url'],
          isVideo: true,
        );
      } else if (type == 'videos') {
        final urls = message['media_urls'];
        final thumbs = message['thumbnail_urls'];
        if (urls is List) {
          for (int i = 0; i < urls.length; i++) {
            final thumb = (thumbs is List && i < thumbs.length) ? thumbs[i] : null;
            addAttachment(target: videos, url: urls[i], thumbnail: thumb, isVideo: true);
          }
        }
      }

      final replies = (message['thread_children'] as List?)?.cast<Map<String, dynamic>>();
      if (replies != null) {
        for (final reply in replies) {
          collectFromMessage(reply);
        }
      }
    }

    for (final message in controller.messages) {
      collectFromMessage(message);
    }

    int compare(MediaAttachment a, MediaAttachment b) {
      final aTime = a.timestamp?.millisecondsSinceEpoch ?? 0;
      final bTime = b.timestamp?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    }

    images.sort(compare);
    videos.sort(compare);

    return _MediaCollections(images: images, videos: videos);
  }

  Widget _buildReplyThread(List<Map<String, dynamic>> replies) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 0),
      child: Column(
        children: [
          for (var i = 0; i < replies.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: _buildMessageBubble(
                      replies[i],
                      isThreadReply: true,
                      showReplyPreview: false,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyToggleButton(String threadKey, int replyCount, bool expanded) {
    final int hiddenCount = replyCount - _defaultVisibleReplies;
    final label = expanded
        ? 'Hide replies'
        : hiddenCount > 0
            ? 'View more ($hiddenCount)'
            : 'View more';
    return Padding(
      padding: const EdgeInsets.only(left: 62, top: 0, bottom: 6),
      child: GestureDetector(
        onTap: () => _toggleThreadReplies(threadKey),
        behavior: HitTestBehavior.opaque,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xff9F8EFF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _toggleThreadReplies(String threadKey) {
    setState(() {
      if (_expandedThreads.contains(threadKey)) {
        _expandedThreads.remove(threadKey);
      } else {
        _expandedThreads.add(threadKey);
      }
    });
  }

  Widget _buildMentionSuggestions() {
    return Obx(() {
      final suggestions = controller.mentionResults;
      final loading = controller.isMentionLoading.value;
      if (!_isMentionPanelVisible) return const SizedBox.shrink();
      if (suggestions.isEmpty && !loading) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(maxHeight: 220),
        decoration: BoxDecoration(
          color: const Color(0xff211D39),
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading && suggestions.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (_, index) {
                  final member = suggestions[index];
                  final displayName = (member['name'] ?? '').toString();
                  final username = (member['username'] ?? displayName).toString();
                  final avatar = (member['image'] ?? '').toString();
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: _buildMentionAvatar(avatar, displayName),
                    title: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: username.isNotEmpty && username != displayName
                        ? Text(
                            '@$username',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          )
                        : null,
                    onTap: () => _handleMentionSelection(member),
                  );
                },
                separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
              ),
      );
    });
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message, {
    bool isThreadReply = false,
    bool showReplyPreview = true,
  }) {
    final messageType = (message['type'] ?? 'text').toString();
    final hasReactions = (message['reactions'] as List?)?.isNotEmpty ?? false;
    final bool isMediaMessage = _isMediaMessageType(messageType);
    final String? captionText = isMediaMessage ? _extractMediaCaption(message) : null;
    final backgroundColor = isThreadReply ? const Color(0xff1F1A37) : const Color(0xff262042);
    final senderName = message['sender_name']?.toString().trim();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: () => _handleMessageDoubleTap(message),
      onLongPress: () => _showMessageActions(message),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: _buildUserAvatar(
              message['sender_id']?.toString() ?? '',
              message['sender_image']?.toString() ?? '',
              message["group_image"]?.toString() ?? '',
              isThreadReply: isThreadReply,
              userType: message["userType"]?.toString() ?? '0',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              decoration: BoxDecoration(
                // color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          (senderName == null || senderName.isEmpty) ? 'Unknown' : senderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Text(
                      //   _formatMessageTime(message['timestamp'] ?? message['created_at']),
                      //   style: const TextStyle(
                      //     color: Colors.white54,
                      //     fontSize: 12,
                      //   ),
                      // ),
                    ],
                  ),
                  if (captionText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      captionText,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                  if (showReplyPreview && message['reply_to'] != null) ...[
                    const SizedBox(height: 8),
                    _buildReplyPreview(message['reply_to']),
                  ],
                  const SizedBox(height: 8),
                  if (messageType == 'image')
                    _buildImageMessage(message)
                  else if (messageType == 'images')
                    _buildMultipleImagesMessage(message)
                  else if (messageType == 'video')
                    _buildVideoMessage(message)
                  else if (messageType == 'videos')
                    _buildMultipleVideosMessage(message)
                  else
                    _buildStyledMessageText(message['text']?.toString() ?? ''),
                  if (hasReactions) ...[
                    const SizedBox(height: 8),
                    _buildReactionsRow(message),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatMessageTime(message['timestamp'] ?? message['created_at']),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledMessageText(String text) {
    final baseStyle = TextStyle(color: Colors.white, fontSize: 16.sp, height: 1.4);
    if (text.trim().isEmpty) {
      return Text(text, style: baseStyle);
    }
    final spans = <TextSpan>[];
    final mentionPattern = RegExp(r'@[\w\.\-]+');
    int startIndex = 0;
    for (final match in mentionPattern.allMatches(text)) {
      if (match.start > startIndex) {
        spans.add(TextSpan(text: text.substring(startIndex, match.start)));
      }
      final mentionText = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: mentionText,
          style: baseStyle.copyWith(
            color: const Color(0xff4F9DFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      startIndex = match.end;
    }
    if (startIndex < text.length) {
      spans.add(TextSpan(text: text.substring(startIndex)));
    }
    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
    );
  }

  void _handleComposerTextChanged() {
    final selection = controller.messageController.selection;
    final text = controller.messageController.text;
    if (!selection.isValid || selection.baseOffset <= 0 || selection.baseOffset > text.length) {
      _hideMentionPanel();
      return;
    }
    final prefix = text.substring(0, selection.baseOffset);
    final match = _mentionMatcher.firstMatch(prefix);
    if (match == null) {
      _hideMentionPanel();
      return;
    }
    final query = match.group(1)?.trim() ?? '';
    _activeMentionRange = TextRange(start: match.start, end: selection.baseOffset);
    _showMentionPanel();
    _mentionSearchDebounce?.cancel();
    if (query.isEmpty) {
      controller.clearMentionResults();
      return;
    }
    _mentionSearchDebounce = Timer(const Duration(milliseconds: 250), () {
      controller.searchGroupMembers(query);
    });
  }

  void _handleMessageListPositionsChanged() {
    final positions = _messagePositionsListener.itemPositions.value;
    bool shouldShow = false;
    if (positions.isNotEmpty) {
      shouldShow = !positions.any((position) => position.index <= 1);
    }
    if (mounted && shouldShow != _showJumpToLatest) {
      setState(() => _showJumpToLatest = shouldShow);
    }
  }

  void _handleMentionSelection(Map<String, dynamic> member) {
    final range = _activeMentionRange;
    if (range == null) return;
    final rawDisplay = (member['username'] ?? member['name'] ?? '').toString().trim();
    if (rawDisplay.isEmpty) return;
    final mentionText = '@$rawDisplay ';
    final text = controller.messageController.text;
    final int start = range.start.clamp(0, text.length).toInt();
    final int end = range.end.clamp(0, text.length).toInt();
    final newText = text.replaceRange(start, end, mentionText);
    controller.messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + mentionText.length),
    );
    _hideMentionPanel();
  }

  void _showMentionPanel() {
    if (!_isMentionPanelVisible) {
      setState(() {
        _isMentionPanelVisible = true;
      });
    }
  }

  void _hideMentionPanel() {
    _mentionSearchDebounce?.cancel();
    controller.clearMentionResults();
    _activeMentionRange = null;
    if (_isMentionPanelVisible) {
      setState(() {
        _isMentionPanelVisible = false;
      });
    }
  }

  Widget _buildMentionAvatar(String imageUrl, String name) {
    final trimmed = name.trim();
    final initials = trimmed.isNotEmpty ? trimmed.substring(0, 1).toUpperCase() : '?';
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xff332B55),
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
    final resolvedUrl = imageUrl.startsWith('http') ? imageUrl : 'http://3.134.119.154/$imageUrl';
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xff332B55),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: resolvedUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Center(
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
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

    return GestureDetector(
      onTap: () => _openImageViewer(imageUrl),
      child: ClipRRect(
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
          final imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () => _openImageViewer(imageUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
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
        onDoubleTap: () => _handleMessageDoubleTap(message),
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

  void _openImageViewer(String imageUrl) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageUrl: trimmed),
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
    final rawReactions = (message['reactions'] as List?) ?? const [];
    final reactions = rawReactions.where((reaction) {
      final emoji = reaction is Map ? reaction['emoji']?.toString() ?? '' : '';
      return emoji.isNotEmpty && _isSupportedReaction(emoji);
    }).toList();
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

  Future<void> _scrollToLatest() async {
    if (!_messageScrollController.isAttached) return;
    await _messageScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0,
    );
  }

  Widget _buildComposerReplyPreview(Map<String, dynamic> reply) {
    final sender = reply['sender_name']?.toString() ?? 'Unknown';
    final snippet = _replySnippet(reply);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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

  Widget _buildUserAvatar(String? userId, String? imageUrl, String groupImage, {bool isThreadReply = false, String? userType}) {
    final double avatarWidth = isThreadReply ? 40 : 50;
    final double avatarHeight = isThreadReply ? 50 : 60;
    final double badgeSize = isThreadReply ? 25 : 30;
    final double badgeOffset = isThreadReply ? -15 : -20;
    final double iconSize = isThreadReply ? 15 : 20;
    return userType == "2"
        ? GestureDetector(
            onTap: () {
              int changeUserId = int.parse(userId.toString());
              Get.to(() => OtherUserProfileScreen(userId: changeUserId));
              // Optionally handle avatar tap
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Octagon background image
                Image.asset(
                  // widget.postData?.groupType == "personal"
                  //     ?
                  // 'assets/ic/Group 5.png'
                  // :
                  'assets/ic/Group 4.png', // Your uploaded PNG asset
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),

                // Centered network image
                ClipPath(
                  clipper: OctagonClipper(),
                  child: CustomPaint(
                    painter: OctagonBorderPainter(
                      strokeWidth: 20.0,
                      borderColor: Color(0xff211D39), // Change border color
                    ),
                    child: Image.network(
                      groupImage.contains("http") ? '$groupImage' : "http://3.134.119.154/$groupImage", // Replace with your image URL
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
                ),
              ],
            ),
          )
        : Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: () {
                  int changeUserId = int.parse(userId.toString());
                  Get.to(() => OtherUserProfileScreen(userId: changeUserId));
                  // Optionally handle avatar tap
                },
                child: Container(
                  width: avatarWidth,
                  height: avatarHeight,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipOval(
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          )
                        : Image.asset(
                            'assets/ic/Group 4.png', // Your uploaded PNG asset
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: badgeOffset,
                child: ClipPath(
                  clipper: OctagonClipper(),
                  child: Container(
                    width: badgeSize,
                    height: badgeSize,
                    color: Colors.black, // Optional: for border effect
                    child: Image.network(
                      groupImage,
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

  String? _currentUserId() {
    final raw = widget.userId.isNotEmpty ? widget.userId : (storage.read("current_uid") ?? storage.read("user_id") ?? storage.read("id"));
    if (raw == null) return null;
    final id = raw.toString().trim();
    return id.isEmpty ? null : id;
  }

  String? _extractMessageId(Map<String, dynamic> message) {
    final raw = message['id'] ?? message['message_id'];
    if (raw == null) return null;
    final id = raw.toString().trim();
    return id.isEmpty ? null : id;
  }

  bool _canDeleteMessage(Map<String, dynamic> message) {
    if (controller.isGroupCreator.value) {
      return true;
    }
    final senderId = message['sender_id']?.toString();
    final currentUserId = _currentUserId();
    if (senderId == null || senderId.isEmpty || currentUserId == null) {
      return false;
    }
    return senderId == currentUserId;
  }

  Future<void> _confirmDeleteMessage(Map<String, dynamic> message) async {
    final messageId = _extractMessageId(message);
    if (messageId == null || widget.thread_id.isEmpty) {
      Get.snackbar('Error', 'Message cannot be deleted yet.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete message?'),
          content: const Text('This will remove the message for everyone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _deleteMessage(messageId);
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    if (widget.thread_id.isEmpty) return;
    try {
      await _api.deleteThreadMessage(threadId: widget.thread_id, messageId: messageId);
      _removeMessageFromList(messageId);
      controller.messages.refresh();
      Get.snackbar('Deleted', 'Message removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message: $e');
    }
  }

  bool _isShareableMediaMessage(Map<String, dynamic> message) {
    final type = (message['type'] ?? '').toString().toLowerCase();
    if (!_isMediaMessageType(type)) return false;
    final urls = _extractMediaUrlsForPost(message);
    return urls.isNotEmpty;
  }

  List<String> _extractMediaUrlsForPost(Map<String, dynamic> message) {
    final List<String> urls = [];
    final type = (message['type'] ?? '').toString().toLowerCase();
    if (type == 'image' || type == 'video') {
      final candidate = message['media_url'] ?? message['url'] ?? message['media'];
      if (candidate != null) {
        final resolved = _absUrl(candidate.toString());
        if (resolved.isNotEmpty) urls.add(resolved);
      }
    } else if (type == 'images' || type == 'videos') {
      final candidates = message['media_urls'];
      if (candidates is List) {
        for (final item in candidates) {
          if (item == null) continue;
          final resolved = _absUrl(item.toString());
          if (resolved.isNotEmpty) urls.add(resolved);
        }
      }
    }
    return urls;
  }

  Future<File?> _downloadMediaToTemp(String url, {required bool isVideo, int index = 0}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }
      final uri = Uri.tryParse(url);
      String ext = '';
      final path = uri?.path ?? '';
      final dotIndex = path.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < path.length - 1) {
        ext = path.substring(dotIndex);
      }
      if (ext.isEmpty) {
        ext = isVideo ? '.mp4' : '.jpg';
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/chat_post_${DateTime.now().millisecondsSinceEpoch}_$index$ext');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> _shareMessageMediaAsPost(Map<String, dynamic> message) async {
    final type = (message['type'] ?? '').toString().toLowerCase();
    if (!_isMediaMessageType(type)) {
      Get.snackbar('Error', 'Only image/video messages can be shared as posts.');
      return;
    }
    final urls = _extractMediaUrlsForPost(message);
    if (urls.isEmpty) {
      Get.snackbar('Error', 'No media found for this message.');
      return;
    }
    final isVideo = type == 'video' || type == 'videos';
    final List<PostFile> imageFiles = [];
    final List<PostFile> videoFiles = [];
    final List<File> tempFiles = [];

    try {
      for (int i = 0; i < urls.length; i++) {
        final file = await _downloadMediaToTemp(urls[i], isVideo: isVideo, index: i);
        if (file != null) {
          tempFiles.add(file);
          if (isVideo) {
            videoFiles.add(PostFile(filePath: file.path, isVideo: true));
          } else {
            imageFiles.add(PostFile(filePath: file.path, isVideo: false));
          }
        }
      }
      if (imageFiles.isEmpty && videoFiles.isEmpty) {
        Get.snackbar('Error', 'Failed to download media for posting.');
        return;
      }

      final caption = _extractMediaCaption(message) ?? message['text']?.toString() ?? '';
      await _postController.submitPostFromFiles(
        images: imageFiles,
        videos: videoFiles,
        description: caption,
        isRepost: 1,
        originalUserId: message['sender_id'],
        originalResource: urls,
      );
    } finally {
      for (final file in tempFiles) {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    }
  }

  void _showMessageActions(Map<String, dynamic> message) {
    if (widget.thread_id.isEmpty) return;
    final canDelete = _canDeleteMessage(message);
    final messageId = _extractMessageId(message);
    final canShare = _isShareableMediaMessage(message);
    final currentUserId = _currentUserId();
    final senderId = _extractMessageSenderId(message);
    final isGroupCreator = currentUserId != null && currentUserId == widget.otheruserId.toString();
    final canBlockUser = isGroupCreator && senderId != null && senderId != currentUserId;
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
                ListTile(
                  leading: const Icon(Icons.reply, color: Colors.white),
                  title: const Text('Reply', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    final senderName = message['sender_name']?.toString() ?? 'Unknown';
                    final mentionText = '@$senderName ';
                    final currentText = controller.messageController.text;
                    controller.messageController.text = mentionText + currentText;
                    controller.startReply(message);
                  },
                ),
                if (canShare)
                  ListTile(
                    leading: const Icon(Icons.ios_share, color: Colors.white),
                    title: const Text('Share/Post', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _shareMessageMediaAsPost(message);
                    },
                  ),
                if (canDelete && messageId != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                    title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _confirmDeleteMessage(message);
                    },
                  ),
                if (canBlockUser && senderId != null)
                  ListTile(
                    leading: const Icon(Icons.block, color: Colors.redAccent),
                    title: const Text('Block User', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _confirmBlockUser(senderId);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _extractMessageSenderId(Map<String, dynamic> message) {
    final raw = message['sender_id'] ?? message['owner_id'] ?? message['user_id'] ?? message['owner']?['id'] ?? message['owner']?['base']?['id'];
    final id = raw?.toString();
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<void> _confirmBlockUser(String userId) async {
    Get.defaultDialog(
      title: 'Block user?',
      middleText: 'They will be blocked from this group.',
      textConfirm: 'Block',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await blockMember(userId: int.parse(userId), threadId: widget.thread_id);
      },
    );
  }

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> blockMember({required int userId, required String threadId}) async {
    try {
      isLoading.value = true;
      await NetworkAPICall().blockGroupUser(userId: userId, threadId: threadId);

      Get.snackbar('Success', 'Member blocked successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to block member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleMessageDoubleTap(Map<String, dynamic> message) {
    _handleReactionSelection(message, _heartReactionEmoji);
  }

  Future<void> _handleReactionSelection(Map<String, dynamic> message, String emoji) async {
    if (widget.thread_id.isEmpty) return;
    emoji = _normalizeReactionEmoji(emoji);
    if (!_isSupportedReaction(emoji)) return;
    final messageId = message['id']?.toString();
    if (messageId == null || messageId.isEmpty) return;
    final reactionUsers = message['reaction_users'] as Map<String, dynamic>?;
    if (_userHasReacted(reactionUsers, emoji)) {
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

  String _formatMessageTime(dynamic timestamp) {
    final DateTime? dateTime = _parseTimestampValue(timestamp);
    if (dateTime == null) return '';
    return DateFormat('h:mm a').format(dateTime);
  }

  void _registerThreadIndices(Map<String, dynamic> message, int index) {
    final messageId = message['id']?.toString() ?? message['temporary_id']?.toString() ?? '';
    if (messageId.isNotEmpty) {
      _messageIndexLookup[messageId] = index;
    }
    final replies = (message['thread_children'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    for (final reply in replies) {
      _registerThreadIndices(reply, index);
    }
  }

  String _threadKey(Map<String, dynamic> message) {
    return message['id']?.toString() ?? message['temporary_id']?.toString() ?? message['message_id']?.toString() ?? message.hashCode.toString();
  }

  List<Map<String, dynamic>> _buildThreadedMessages(List<Map<String, dynamic>> messages) {
    final Map<String, Map<String, dynamic>> lookup = {};
    final List<Map<String, dynamic>> ordered = [];

    for (final msg in messages) {
      final clone = Map<String, dynamic>.from(msg);
      clone['thread_children'] = <Map<String, dynamic>>[];
      final id = msg['id']?.toString() ?? msg['temporary_id']?.toString() ?? '';
      if (id.isNotEmpty) {
        lookup[id] = clone;
      }
      ordered.add(clone);
    }

    final List<Map<String, dynamic>> roots = [];
    for (final clone in ordered) {
      final parentId = clone['reply_to_id']?.toString();
      if (parentId != null && parentId.isNotEmpty && lookup.containsKey(parentId)) {
        final parent = lookup[parentId]!;
        final children = (parent['thread_children'] as List<Map<String, dynamic>>?) ?? <Map<String, dynamic>>[];
        children.add(clone);
        parent['thread_children'] = children;
      } else {
        roots.add(clone);
      }
    }

    for (final clone in ordered) {
      final children = (clone['thread_children'] as List?)?.cast<Map<String, dynamic>>();
      if (children != null && children.isNotEmpty) {
        children.sort((a, b) {
          final DateTime? aTime = _parseTimestampValue(a['timestamp'] ?? a['created_at']);
          final DateTime? bTime = _parseTimestampValue(b['timestamp'] ?? b['created_at']);
          return (aTime ?? DateTime.now()).compareTo(bTime ?? DateTime.now());
        });
      }
    }

    return roots;
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

  bool _isRenderableMessage(Map<String, dynamic> message) {
    final type = (message['type'] ?? 'text').toString();
    final text = message['text']?.toString().trim() ?? '';
    final mediaUrl = message['media_url']?.toString().trim() ?? '';
    final thumbnail = message['thumbnail_url']?.toString().trim() ?? '';
    final hasReply = message['reply_to'] != null;
    final hasAttachment = mediaUrl.isNotEmpty || thumbnail.isNotEmpty || type != 'text';
    return text.isNotEmpty || hasAttachment || hasReply;
  }
}

class MediaAttachment {
  final String url;
  final String? thumbnailUrl;
  final bool isVideo;
  final DateTime? timestamp;
  final String messageId;

  const MediaAttachment({
    required this.url,
    this.thumbnailUrl,
    required this.isVideo,
    this.timestamp,
    required this.messageId,
  });
}

class _MediaCollections {
  final List<MediaAttachment> images;
  final List<MediaAttachment> videos;

  const _MediaCollections({
    required this.images,
    required this.videos,
  });
}

class MediaGalleryScreen extends StatelessWidget {
  final List<MediaAttachment> images;
  final List<MediaAttachment> videos;

  const MediaGalleryScreen({
    Key? key,
    required this.images,
    required this.videos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xff1F1A37),
        appBar: AppBar(
          backgroundColor: const Color(0xff1F1A37),
          title: const Text('Shared Media'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMediaGrid(context, images, false),
            _buildMediaGrid(context, videos, true),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<MediaAttachment> media, bool isVideo) {
    if (media.isEmpty) {
      return Center(
        child: Text(
          isVideo ? 'No videos yet' : 'No images yet',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: media.length,
      itemBuilder: (context, index) {
        final attachment = media[index];
        final previewUrl = isVideo ? (attachment.thumbnailUrl ?? attachment.url) : attachment.url;
        return GestureDetector(
          onTap: () {
            if (isVideo) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(videoUrl: attachment.url),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(imageUrl: attachment.url),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: previewUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
                if (isVideo)
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white),
          ),
        ),
      ),
    );
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
