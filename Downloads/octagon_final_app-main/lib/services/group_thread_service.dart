import 'dart:convert';
import 'dart:developer';

import 'package:octagon/networking/network.dart';

class GroupThreadService {
  GroupThreadService({NetworkAPICall? api}) : _api = api ?? NetworkAPICall();

  final NetworkAPICall _api;

  Future<String> createThreadForGroup(String groupId) async {
    final response = await _api.postApiCall('groups-create-chat-thread', {'group_id': groupId});
    final threadId = extractThreadId(response);
    if (threadId == null || threadId.isEmpty) {
      throw Exception('Thread id not found in response');
    }
    log('Chat thread $threadId prepared for group $groupId');
    return threadId;
  }

  static String? extractThreadId(dynamic payload) {
    final directMatch = _extractValue(payload, (key, value, map) {
      final normalizedKey = key.toLowerCase();
      if (normalizedKey == 'thread_id' || normalizedKey == 'threadid') return true;
      if ((normalizedKey == 'id' || normalizedKey == 'uuid') && _looksLikeThreadMap(map)) return true;
      return false;
    });
    if (directMatch != null && directMatch.isNotEmpty) {
      return directMatch;
    }

    if (payload is String) {
      return _extractThreadIdFromText(payload);
    }

    try {
      return _extractThreadIdFromText(jsonEncode(payload));
    } catch (_) {
      return null;
    }
  }

  static String? extractGroupId(dynamic payload) {
    return _extractValue(payload, (key, value, map) {
      final normalizedKey = key.toLowerCase();
      if (normalizedKey == 'group_id' || normalizedKey == 'groupid') return true;
      if (normalizedKey == 'id' && _looksLikeGroupMap(map)) return true;
      return false;
    });
  }

  static String? _extractValue(dynamic payload, bool Function(String key, dynamic value, Map source) predicate) {
    if (payload is Map) {
      for (final entry in payload.entries) {
        final key = entry.key.toString();
        if (predicate(key, entry.value, payload)) {
          final match = entry.value;
          if (_isValidId(match)) return match.toString();
        }
      }
      for (final value in payload.values) {
        final nested = _extractValue(value, predicate);
        if (nested != null) return nested;
      }
    } else if (payload is Iterable) {
      for (final value in payload) {
        final nested = _extractValue(value, predicate);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static bool _looksLikeGroupMap(Map source) {
    const hints = {'title', 'options', 'dates', 'description', 'is_public', 'user_id', 'photo', 'thread_id'};
    return source.keys.map((e) => e.toString().toLowerCase()).any((key) => hints.contains(key));
  }

  static bool _looksLikeThreadMap(Map source) {
    const hints = {'thread', 'thread_id', 'thread_type', 'participants', 'messages', 'latest_message', 'group_id', 'subject'};
    return source.keys.map((e) => e.toString().toLowerCase()).any((key) => hints.contains(key));
  }

  static bool _isValidId(dynamic value) {
    if (value == null) return false;
    final text = value.toString().trim();
    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  static String? _extractThreadIdFromText(String? text) {
    if (text == null || text.isEmpty) return null;
    final patterns = [
      RegExp(r'"thread_id"\s*:\s*"?([\w-]+)"?'),
      RegExp(r'"uuid"\s*:\s*"?([\w-]+)"?'),
      RegExp(r'"thread"\s*:\s*"?([\w-]+)"?')
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1);
    }
    return null;
  }
}
