import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:laravel_flutter_pusher/laravel_flutter_pusher.dart';

class PusherService extends GetxService {
  PusherClient? _pusher;
  final Map<String, Channel> _channels = {};
  final GetStorage _storage = GetStorage();
  static const List<String> _newMessageEventNames = [
    '.new.message',
    'new.message',
    '.message.new',
    'message.new',
    '.thread.message.new',
    'thread.message.new',
    'messenger.message.new',
    'messenger.new.message',
    'App\\Events\\NewMessageBroadcast',
  ];
  static const List<String> _reactionAddedEventNames = [
    '.reaction.added',
    'reaction.added',
    'reaction_added',
    'App\\Events\\ReactionAdded',
    'App\\Events\\ThreadReactionAdded',
  ];
  static const List<String> _reactionRemovedEventNames = [
    '.reaction.removed',
    'reaction.removed',
    'reaction_removed',
    'App\\Events\\ReactionRemoved',
    'App\\Events\\ThreadReactionRemoved',
  ];
  static const List<String> _userBlockedEventNames = [
    '.thread.blocked',
    'thread.blocked',
    '.user.blocked',
    'user.blocked',
    'App\\Events\\ThreadBlocked',
    'App\\Events\\UserBlocked',
  ];

  // Reactive controllers for different event types
  final Rx<Map<String, dynamic>> _currentMessage = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> _currentNotification = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> _currentThreadUpdate = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> _currentCallEvent = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> _currentFriendEvent = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> _currentReactionEvent = Rx<Map<String, dynamic>>({});

  // Broadcast streams for different event categories
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _threadController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _callController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _friendController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  final Rx<String> _connectionState = 'disconnected'.obs;
  final RxBool _isConnected = false.obs;

  static const String PUSHER_APP_KEY = "fa0fd416e67437732ca1";
  static const String PUSHER_CLUSTER = "us2";
  static const String BASE_URL = "http://3.134.119.154";

  // Getters for reactive data
  Map<String, dynamic> get currentMessage => _currentMessage.value;
  Map<String, dynamic> get currentNotification => _currentNotification.value;
  Map<String, dynamic> get currentThreadUpdate => _currentThreadUpdate.value;
  Map<String, dynamic> get currentCallEvent => _currentCallEvent.value;
  Map<String, dynamic> get currentFriendEvent => _currentFriendEvent.value;
  Map<String, dynamic> get currentReactionEvent => _currentReactionEvent.value;

  // Stream getters for UI listeners
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get threadStream => _threadController.stream;
  Stream<Map<String, dynamic>> get callStream => _callController.stream;
  Stream<Map<String, dynamic>> get friendStream => _friendController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  String get connectionState => _connectionState.value;
  bool get isConnected => _isConnected.value;
  String? _currentSocketId;

  Future<bool> waitUntilConnected({Duration timeout = const Duration(seconds: 8)}) async {
    if (_isConnected.value) return true;

    final completer = Completer<bool>();
    StreamSubscription? sub;
    Timer? timer;

    void complete(bool value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    sub = _connectionState.listen((state) {
      final normalized = state.toLowerCase();
      if (normalized == 'connected') {
        complete(true);
      } else if (normalized == 'failed' || normalized == 'error' || normalized == 'disconnected') {
        complete(false);
      }
    });

    timer = Timer(timeout, () => complete(_isConnected.value));

    final result = await completer.future;
    await sub.cancel();
    timer?.cancel();
    return result;
  }

  @override
  void onClose() {
    try {
      _messageController.close();
      _threadController.close();
      _callController.close();
      _friendController.close();
      _notificationController.close();
    } catch (_) {}
    disconnect();
    super.onClose();
  }

  Future<void> initializePusher() async {
    try {
      _connectionState.value = 'connecting';

      final token = _storage.read("token");
      if (token == null) {
        log("❌ No authentication token found in storage");
        // Debug what keys are available
        final allKeys = _storage.getKeys();
        log("🔑 Available storage keys: $allKeys");
        throw Exception("No authentication token found");
      }

      log("🔄 Initializing Pusher with token: ${token.substring(0, 15)}...");

      // Test the authentication endpoint manually
      // await _testBroadcastingAuth(token);

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

      log("🔐 Auth headers: ${headers.keys.join(', ')}");
      log("🔐 Auth URL: $BASE_URL/api/broadcasting/auth");

      _pusher = PusherClient(
        PUSHER_APP_KEY,
        PusherOptions(
          cluster: PUSHER_CLUSTER,
          auth: PusherAuth(
            '$BASE_URL/api/broadcasting/auth',
            headers: headers,
          ),
          host: 'ws-$PUSHER_CLUSTER.pusher.com',
          encrypted: true,
          port: 443,
        ),
        enableLogging: true,
        lazyConnect: false,
        onConnectionStateChange: (ConnectionStateChange stateChange) {
          _handleConnectionStateChange(stateChange);
        },
        onError: (ConnectionError error) {
          _handleConnectionError(error);
        },
      );

      log("✅ Pusher client configured, connecting...");
    } catch (e) {
      log("❌ Pusher Initialization Error: $e");
      _connectionState.value = 'failed';
      _isConnected.value = false;
      rethrow;
    }
  }

  Future<bool> _authenticateChannel(String channelName) async {
    try {
      final token = _storage.read("token");
      final currentUserId = _storage.read("current_uid");
      final socketId = _getSocketId();
      if (token == null || socketId == null) {
        log("❌ No token or socket ID for auth");
        return false;
      }

      log("🔐 Authenticating channel: $channelName for userId: ${currentUserId ?? 'unknown'}");
      log("🔐 Socket ID: $socketId");

      final response = await http.post(
        Uri.parse('$BASE_URL/api/broadcasting/auth'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode({
          'socket_id': socketId,
          'channel_name': channelName,
        }),
      );

      log("🔐 Auth Response - Status: ${response.statusCode}");
      log("🔐 Auth Response - Body: ${response.body}");

      if (response.statusCode == 200) {
        log("✅ Channel authentication successful: $channelName");
        return true;
      } else {
        log("❌ Channel authentication failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("❌ Channel auth error: $e");
      return false;
    }
  }

  Future<bool> testChannelAuthentication(String channelName) async {
    return _authenticateChannel(channelName);
  }

  String? _getSocketId() {
    if (_currentSocketId != null && _currentSocketId!.isNotEmpty) {
      return _currentSocketId;
    }
    final latestId = _pusher?.getSocketId();
    if (latestId != null && latestId.isNotEmpty) {
      _currentSocketId = latestId;
    }
    return _currentSocketId;
  }

  // Temporary: Test with public channel first
  Future<void> subscribeToTestChannel() async {
    try {
      final channelName = 'public-test-channel';
      log("🔰 Testing with public channel: $channelName");

      final channel = _pusher!.subscribe(channelName);
      channel.bind('pusher:subscription_succeeded', (event) {
        log("✅ Public channel subscribed successfully");
      });

      channel.bind('pusher:subscription_error', (event) {
        log("❌ Public channel subscription failed: $event");
      });
    } catch (e) {
      log("❌ Public channel test error: $e");
    }
  }

  void _handleConnectionStateChange(ConnectionStateChange stateChange) {
    final currentState = stateChange.currentState;
    final normalizedState = currentState.toLowerCase();
    log("🔌 Pusher State: $currentState");
    _connectionState.value = currentState;

    if (normalizedState == 'connected') {
      _currentSocketId = _pusher?.getSocketId();
      log("🆔 Current socket ID: ${_currentSocketId ?? 'unavailable'}");
      _isConnected.value = true;
      log("✅ Pusher connected!");
      _resubscribeToChannels();
    } else if (normalizedState == 'disconnected' || normalizedState == 'failed') {
      _isConnected.value = false;
    }
  }

  void _handleConnectionError(ConnectionError error) {
    log("❌ Pusher Error: ${error.message}");
    _isConnected.value = false;
    _connectionState.value = 'error';
  }

  // Private Channel: User-specific events
  Future<void> subscribeToMessengerUser(String userId) async {
    try {
      log("👤 subscribeToMessengerUser called with userId: $userId");
      if (!_isConnected.value) {
        final connected = await waitUntilConnected(timeout: const Duration(seconds: 10));
        if (!connected) {
          log('⚠️ Cannot subscribe to user $userId because Pusher is disconnected');
          return;
        }
      }

      final channelNames = [
        'private-messenger.user.$userId',
        'private-App.Models.User.$userId',
      ];

      log("👤 User channels to subscribe: ${channelNames.join(', ')}");
      for (final channelName in channelNames) {
        if (_channels.containsKey(channelName)) {
          log("⚠️ Already subscribed to user channel: $channelName");
          continue;
        }

        final authenticated = await _authenticateChannel(channelName);
        if (!authenticated) {
          log("❌ Authentication failed for $channelName, skipping subscription");
          continue;
        }

        log("👤 Subscribing to user channel: $channelName");
        final channel = _pusher!.subscribe(channelName);
        _channels[channelName] = channel;

        channel.bind('pusher:subscription_succeeded', (event) {
          log("✅ User channel subscribed: $channelName");
        });

        channel.bind('pusher:subscription_error', (event) {
          log("❌ User channel subscription error ($channelName): $event");
        });

        // Bind all private channel events
        log("👤 Binding events for user channel: $channelName");
        _bindPrivateChannelEvents(channel, userId);
      }
    } catch (e) {
      log("❌ Error subscribing to user: $e");
    }
  }

  void _bindPrivateChannelEvents(Channel channel, String userId) {
    // Message Events
    _bindEventVariations(channel, _newMessageEventNames, _handleNewMessage);
    channel.bind('.message.archived', (event) => _handleMessageArchived(event));

    // Thread Events
    channel.bind('.new.thread', (event) => _handleNewThread(event));
    channel.bind('.thread.archived', (event) => _handleThreadArchived(event));
    channel.bind('.thread.approval', (event) => _handleThreadApproval(event));
    channel.bind('.thread.left', (event) => _handleThreadLeft(event));
    channel.bind('.thread.read', (event) => _handleThreadRead(event));

    // Call Events
    channel.bind('.incoming.call', (event) => _handleIncomingCall(event));
    channel.bind('.joined.call', (event) => _handleJoinedCall(event));
    channel.bind('.ignored.call', (event) => _handleIgnoredCall(event));
    channel.bind('.left.call', (event) => _handleLeftCall(event));
    channel.bind('.call.ended', (event) => _handleCallEnded(event));
    channel.bind('.call.kicked', (event) => _handleCallKicked(event));

    // Friend Events
    channel.bind('.friend.request', (event) => _handleFriendRequest(event));
    channel.bind('.friend.approved', (event) => _handleFriendApproved(event));
    channel.bind('.friend.denied', (event) => _handleFriendDenied(event));
    channel.bind('.friend.cancelled', (event) => _handleFriendCancelled(event));
    channel.bind('.friend.removed', (event) => _handleFriendRemoved(event));

    // Admin & Permission Events
    channel.bind('.promoted.admin', (event) => _handlePromotedAdmin(event));
    channel.bind('.demoted.admin', (event) => _handleDemotedAdmin(event));
    channel.bind('.permissions.updated', (event) => _handlePermissionsUpdated(event));
    channel.bind('thread.blocked', (event) => _handleUserBlocked(event));
    _bindEventVariations(channel, _userBlockedEventNames, _handleUserBlocked);

    // Reaction Events
    _bindEventVariations(channel, _reactionAddedEventNames, _handleReactionAdded);
    _bindEventVariations(channel, _reactionRemovedEventNames, _handleReactionRemoved);

    // Other Events
    channel.bind('.knock.knock', (event) => _handleKnockKnock(event));
  }

  // Presence Channel: Thread-specific events
  Future<void> subscribeToMessengerThread(String threadId) async {
    try {
      if (!_isConnected.value) {
        final connected = await waitUntilConnected(timeout: const Duration(seconds: 10));
        if (!connected) {
          log('⚠️ Cannot subscribe to thread $threadId because Pusher is disconnected');
          return;
        }
      }

      final channelName = 'presence-messenger.thread.$threadId';
      if (_channels.containsKey(channelName)) {
        log("⚠️ Already subscribed to thread: $threadId");
        return;
      }

      final authenticated = await _authenticateChannel(channelName);
      if (!authenticated) {
        log("❌ Authentication failed for $channelName, skipping subscription");
        return;
      }

      log("💬 Subscribing to thread: $threadId");
      final channel = _pusher!.subscribe(channelName);
      _channels[channelName] = channel;

      channel.bind('pusher:subscription_succeeded', (event) {
        log("✅ Thread subscribed: $threadId");
      });

      channel.bind('pusher:subscription_error', (event) {
        log("❌ Thread subscription error ($threadId): $event");
      });

      channel.bind('pusher:member_added', (event) {
        log("👤 User joined thread: $threadId");
      });

      channel.bind('pusher:member_removed', (event) {
        log("👤 User left thread: $threadId");
      });

      // Bind thread presence events
      _bindPresenceChannelEvents(channel, threadId);
    } catch (e) {
      log("❌ Error subscribing to thread: $e");
    }
  }

  void _bindPresenceChannelEvents(Channel channel, String threadId) {
    // Thread presence channels also broadcast new message payloads; forward
    // them through the same handler used for private user channels so the UI
    // receives real-time updates for text, image, and video messages.
    _bindEventVariations(channel, _newMessageEventNames, _handleNewMessage);
    // Some backends broadcast reaction payloads using dynamic event names that
    // include the thread ID (e.g., messenger.thread.{thread_id}); bind those
    // explicitly so they don't get dropped on Android.
    channel.bind('messenger.thread.$threadId', (event) => _handleThreadReactionAdded(event));
    channel.bind('.thread.settings', (event) => _handleThreadSettings(event));
    channel.bind('.thread.avatar', (event) => _handleThreadAvatar(event));
    channel.bind('.message.edited', (event) => _handleMessageEdited(event));
    _bindEventVariations(channel, _reactionAddedEventNames, _handleThreadReactionAdded);
    _bindEventVariations(channel, _reactionRemovedEventNames, _handleThreadReactionRemoved);
    _bindEventVariations(channel, _userBlockedEventNames, _handleUserBlocked);
    channel.bind('.embeds.removed', (event) => _handleEmbedsRemoved(event));
  }

  // ========== EVENT HANDLER METHODS ==========

  // Message Event Handlers
  void _handleNewMessage(dynamic event) {
    log("📨 New message event received: ${event.toString()}");

    _processEvent(event, (data) {
      log("🔍 Processed message data: $data");

      _currentMessage.value = data;
      _messageController.add(data);

      // Also log to console for debugging
      log("✅ Message added to stream: ${data.toString()}");

      Get.snackbar('New Message', 'You have a new message', duration: Duration(seconds: 2));
    });
  }

  void _handleMessageArchived(dynamic event) {
    log("🗑️ Message archived");
    _processEvent(event, (data) {
      _messageController.add({'type': 'message_archived', 'data': data});
    });
  }

  void _handleMessageEdited(dynamic event) {
    log("✏️ Message edited");
    _processEvent(event, (data) {
      _messageController.add({'type': 'message_edited', 'data': data});
    });
  }

  // Thread Event Handlers
  void _handleNewThread(dynamic event) {
    log("💬 New thread created");
    _processEvent(event, (data) {
      _currentThreadUpdate.value = data;
      _threadController.add({'type': 'new_thread', 'data': data});
    });
  }

  void _handleThreadArchived(dynamic event) {
    log("🗑️ Thread archived");
    _processEvent(event, (data) {
      _threadController.add({'type': 'thread_archived', 'data': data});
    });
  }

  void _handleThreadApproval(dynamic event) {
    log("✅ Thread approval updated");
    _processEvent(event, (data) {
      _threadController.add({'type': 'thread_approval', 'data': data});
    });
  }

  void _handleThreadLeft(dynamic event) {
    log("👋 Left thread");
    _processEvent(event, (data) {
      _threadController.add({'type': 'thread_left', 'data': data});
    });
  }

  void _handleThreadRead(dynamic event) {
    log("👀 Thread read status updated");
    _processEvent(event, (data) {
      _threadController.add({'type': 'thread_read', 'data': data});
    });
  }

  void _handleThreadSettings(dynamic event) {
    log("⚙️ Thread settings updated");
    _processEvent(event, (data) {
      _threadController.add({'type': 'thread_settings', 'data': data});
    });
  }

  void _handleThreadAvatar(dynamic event) {
    log("🖼️ Thread avatar updated");
    _processEvent(event, (data) {
      _threadController.add({'type': 'thread_avatar', 'data': data});
    });
  }

  // Call Event Handlers
  void _handleIncomingCall(dynamic event) {
    log("📞 Incoming call");
    _processEvent(event, (data) {
      _currentCallEvent.value = data;
      _callController.add({'type': 'incoming_call', 'data': data});
      Get.snackbar('Incoming Call', 'You have an incoming call', duration: Duration(seconds: 5));
    });
  }

  void _handleJoinedCall(dynamic event) {
    log("✅ Joined call");
    _processEvent(event, (data) {
      _callController.add({'type': 'joined_call', 'data': data});
    });
  }

  void _handleIgnoredCall(dynamic event) {
    log("❌ Call ignored");
    _processEvent(event, (data) {
      _callController.add({'type': 'ignored_call', 'data': data});
    });
  }

  void _handleLeftCall(dynamic event) {
    log("👋 Left call");
    _processEvent(event, (data) {
      _callController.add({'type': 'left_call', 'data': data});
    });
  }

  void _handleCallEnded(dynamic event) {
    log("📞 Call ended");
    _processEvent(event, (data) {
      _callController.add({'type': 'call_ended', 'data': data});
    });
  }

  void _handleCallKicked(dynamic event) {
    log("🚪 Kicked from call");
    _processEvent(event, (data) {
      _callController.add({'type': 'call_kicked', 'data': data});
    });
  }

  // Friend Event Handlers
  void _handleFriendRequest(dynamic event) {
    log("👥 Friend request received");
    _processEvent(event, (data) {
      _currentFriendEvent.value = data;
      _friendController.add({'type': 'friend_request', 'data': data});
      Get.snackbar('Friend Request', 'You have a new friend request', duration: Duration(seconds: 3));
    });
  }

  void _handleFriendApproved(dynamic event) {
    log("✅ Friend request approved");
    _processEvent(event, (data) {
      _friendController.add({'type': 'friend_approved', 'data': data});
    });
  }

  void _handleFriendDenied(dynamic event) {
    log("❌ Friend request denied");
    _processEvent(event, (data) {
      _friendController.add({'type': 'friend_denied', 'data': data});
    });
  }

  void _handleFriendCancelled(dynamic event) {
    log("🚫 Friend request cancelled");
    _processEvent(event, (data) {
      _friendController.add({'type': 'friend_cancelled', 'data': data});
    });
  }

  void _handleFriendRemoved(dynamic event) {
    log("👋 Friend removed");
    _processEvent(event, (data) {
      _friendController.add({'type': 'friend_removed', 'data': data});
    });
  }

  // Admin & Permission Handlers
  void _handlePromotedAdmin(dynamic event) {
    log("👑 Promoted to admin");
    _processEvent(event, (data) {
      _notificationController.add({'type': 'promoted_admin', 'data': data});
    });
  }

  void _handleDemotedAdmin(dynamic event) {
    log("📉 Demoted from admin");
    _processEvent(event, (data) {
      _notificationController.add({'type': 'demoted_admin', 'data': data});
    });
  }

  void _handlePermissionsUpdated(dynamic event) {
    log("🔐 Permissions updated");
    _processEvent(event, (data) {
      _notificationController.add({'type': 'permissions_updated', 'data': data});
    });
  }

  void _handleUserBlocked(dynamic event) {
    log("⛔ User blocked");
    log("🔥 USER BLOCKED EVENT TRIGGERED");
    log("🔥 Raw event: ${event.toString()}");
    log("🔥 Event type: ${event.runtimeType}");
    _processEvent(event, (data) {
      if (data.containsKey('thread_id') && data['thread_id'] == 'a0d47d92-a557-4b89-ba4c-7b195c4b24ca') {
        log("🎯 MATCHING THREAD ID FOUND - THIS IS YOUR EVENT!");
      }
      _messageController.add({'type': 'user_blocked', 'data': data});
    });
  }

  // Reaction Handlers
  // void _handleReactionAdded(dynamic event) {
  //   log("😊 Reaction added");
  //   _processEvent(event, (data) {
  //     _currentReactionEvent.value = data;
  //     _messageController.add({'type': 'reaction_added', 'data': data});
  //   });
  // }
  void _handleReactionAdded(dynamic event) {
    log("🔥 REACTION ADDED EVENT RECEIVED: ${event.toString()}");
    log("🔥 Event type: ${event.runtimeType}");

    _processEvent(event, (data) {
      log("🔥 Processed reaction data: $data");

      _currentReactionEvent.value = data;
      _messageController.add({'type': 'reaction_added', 'data': data});

      // Visual feedback
      Get.snackbar('Reaction Added', 'Someone reacted to your message', duration: Duration(seconds: 2));
    });
  }

  void _handleReactionRemoved(dynamic event) {
    log("😞 Reaction removed");
    _processEvent(event, (data) {
      _messageController.add({'type': 'reaction_removed', 'data': data});
    });
  }

  void _handleThreadReactionAdded(dynamic event) {
    log("😊 Thread reaction added");
    _processEvent(event, (data) {
      _messageController.add({'type': 'thread_reaction_added', 'data': data});
    });
  }

  void _handleThreadReactionRemoved(dynamic event) {
    log("😞 Thread reaction removed");
    _processEvent(event, (data) {
      _messageController.add({'type': 'thread_reaction_removed', 'data': data});
    });
  }

  // Other Handlers
  void _handleEmbedsRemoved(dynamic event) {
    log("🔗 Embeds removed");
    _processEvent(event, (data) {
      _messageController.add({'type': 'embeds_removed', 'data': data});
    });
  }

  void _handleKnockKnock(dynamic event) {
    log("🚪 Knock knock");
    _processEvent(event, (data) {
      _notificationController.add({'type': 'knock_knock', 'data': data});
      Get.snackbar('Knock Knock', 'Someone is at the door!', duration: Duration(seconds: 2));
    });
  }

  void _bindEventVariations(Channel channel, List<String> eventNames, Function handler) {
    final seen = <String>{};
    for (final name in eventNames) {
      if (name.trim().isEmpty || seen.contains(name)) continue;
      seen.add(name);
      channel.bind(name, (event) => handler(event));
    }
  }

  // Helper method to process events
  void _processEvent(dynamic event, Function(Map<String, dynamic>) handler) {
    if (event != null) {
      try {
        final data = event is String ? json.decode(event) : event;
        final Map<String, dynamic> mapData = data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);
        handler(mapData);
      } catch (e) {
        log("❌ Error processing event: $e");
      }
    }
  }

  void _resubscribeToChannels() {
    if (_channels.isEmpty) return;
    final channelsToResubscribe = Map<String, Channel>.from(_channels);
    _channels.clear();

    Timer(const Duration(milliseconds: 1000), () {
      channelsToResubscribe.forEach((channelName, _) {
        if (channelName.startsWith('private-messenger.user.')) {
          final userId = channelName.replaceFirst('private-messenger.user.', '');
          subscribeToMessengerUser(userId);
        } else if (channelName.startsWith('private-App.Models.User.')) {
          final userId = channelName.replaceFirst('private-App.Models.User.', '');
          subscribeToMessengerUser(userId);
        } else if (channelName.startsWith('presence-messenger.thread.')) {
          final threadId = channelName.replaceFirst('presence-messenger.thread.', '');
          subscribeToMessengerThread(threadId);
        }
      });
    });
  }

  Future<void> unsubscribeFromChannel(String channelName) async {
    if (_channels.containsKey(channelName)) {
      try {
        _pusher?.unsubscribe(channelName);
        _channels.remove(channelName);
        log("📭 Unsubscribed: $channelName");
      } catch (e) {
        log("Error unsubscribing: $e");
      }
    }
  }

  Future<void> disconnect() async {
    _isConnected.value = false;
    _connectionState.value = 'disconnected';
    try {
      await _pusher?.disconnect();
      _channels.clear();
      log("📴 Pusher disconnected");
    } catch (e) {
      log("Error disconnecting: $e");
    }
  }
}
