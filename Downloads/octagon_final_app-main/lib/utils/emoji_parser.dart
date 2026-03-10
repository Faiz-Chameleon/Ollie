import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_emoji/flutter_emoji.dart' as flutter_emoji;
import 'package:flutter/services.dart' show rootBundle;

class EmojiParser {
  static const String _assetPath = 'assets/json/emoji_aliases.json';
  static bool _initialized = false;
  static final Map<String, String> _aliasMap = <String, String>{};
  static final flutter_emoji.EmojiParser _libraryParser = flutter_emoji.EmojiParser();

  static const Map<String, String> _fallbackAliasMap = <String, String>{
    'slight_smile': '🙂',
    'slightly_smiling_face': '🙂',
    'upside_down': '🙃',
    'upside_down_face': '🙃',
    'zipper_mouth': '🤐',
    'zipper_mouth_face': '🤐',
    'rolling_eyes': '🙄',
    'face_with_rolling_eyes': '🙄',
    'person_facepalming': '🤦',
    'person_facepalmin': '🤦',
    'head_bandage': '🤕',
    'face_with_head_bandage': '🤕',
    'cowboy': '🤠',
    'cowboy_hat_face': '🤠',
    'face_with_cowboy_hat': '🤠',
    'skull_crossbones': '☠️',
    'skull_and_crossbones': '☠️',
    'heart_exclamation': '❣️',
    'heavy_heart_exclamation_mark_ornament': '❣️',
    'speaking_head': '🗣️',
    'speaking_head_in_silhouette': '🗣️',
    'face_with_symbols_over_mouth': '🤬',
    'person_bowing': '🙇',
    'person_raising_hand': '🙋',
    'person_tipping_hand': '💁',
    'person_gesturing_ok': '🙆',
    'person_gesturing_no': '🙅',
    'person_shrugging': '🤷',
    'person_pouting': '🙎',
    'person_standing': '🧍',
    'person_getting_haircut': '💇',
    'person_getting_massage': '💆',
    'person_kneeling': '🧎',
    'person_walking': '🚶',
    'person_running': '🏃',
    'person_biking': '🚴',
    'person_playing_handball': '🤾',
    'person_fencing': '🤺',
    'person_juggling': '🤹',
    'people_wrestling': '🤼',
    'person_mountain_biking': '🚵',
    'person_surfing': '🏄',
    'person_rowing_boat': '🚣',
    'person_swimming': '🏊',
    'person_playing_water_polo': '🤽',
    'person_with_veil': '👰',
    'guard': '💂',
    'police_officer': '👮',
    'people_with_bunny_ears_partying': '👯',
    'person_wearing_turban': '👳',
    'man_with_chinese_cap': '👲',
    'curly_haired': '🧑‍🦱',
    'white_haired': '🧑‍🦳',
    'person_white_hair': '🧑‍🦳',
    'levitate': '🕴️',
    'man_in_business_suit_levitating': '🕴️',
    'couple_ww': '👩‍❤️‍👩',
    'couple_mm': '👨‍❤️‍👨',
    'kiss_ww': '👩‍❤️‍💋‍👩',
    'kiss_mm': '👨‍❤️‍💋‍👨',
    'kiss_man_man': '👨‍❤️‍💋‍👨',
    'kiss_woman_man': '👩‍❤️‍💋‍👨',
    'kiss_woman_woman': '👩‍❤️‍💋‍👩',
    'slightly_frown': '🙁',
    'slight_frown': '🙁',
    'slightly_frowning_face': '🙁',
    'frowning2': '☹️',
    'smile': '😄',
    'smiley': '😃',
    'grinning': '😀',
    'grin': '😁',
    'joy': '😂',
    'face_with_tears_of_joy': '😂',
    'rofl': '🤣',
    'wink': '😉',
    'blush': '😊',
    'innocent': '😇',
    'heart_eyes': '😍',
    'kissing_heart': '😘',
    'thinking': '🤔',
    'sunglasses': '😎',
    'partying_face': '🥳',
    'sleeping': '😴',
    'cry': '😢',
    'sob': '😭',
    'loudly_crying_face': '😭',
    'heart': '❤️',
    'red_heart': '❤️',
    'purple_heart': '💜',
    'blue_heart': '💙',
    'green_heart': '💚',
    'yellow_heart': '💛',
    'black_heart': '🖤',
    'white_heart': '🤍',
    'orange_heart': '🧡',
    'broken_heart': '💔',
    'thumbsup': '👍',
    'thumbs_up': '👍',
    '+1': '👍',
    'thumbs_down': '👎',
    '-1': '👎',
    'right_facing_fist': '🤜',
    'left_facing_fist': '🤛',
    'clap': '👏',
    'raised_hands': '🙌',
    'pray': '🙏',
    'folded_hands': '🙏',
    'ok_hand': '👌',
    'wave': '👋',
    'vulcan': '🖖',
    'metal': '🤘',
    'the_horns': '🤘',
    'sign_of_the_horns': '🤘',
    'fire': '🔥',
    'thunder_cloud_rain': '⛈️',
    'thunder_cloud_and_rain': '⛈️',
    'sparkles': '✨',
    'star': '⭐',
    'eyes': '👀',
    'check_mark': '✅',
    'white_check_mark': '✅',
    'cross_mark': '❌',
    // Subdivision flags are often unsupported by emoji libraries.
    // Normalize common UK subdivision aliases to GB for compatibility.
    'england': '🇬🇧',
    'flag_england': '🇬🇧',
    'england_flag': '🇬🇧',
    'scotland': '🇬🇧',
    'flag_scotland': '🇬🇧',
    'scotland_flag': '🇬🇧',
    'wales': '🇬🇧',
    'flag_wales': '🇬🇧',
    'wales_flag': '🇬🇧',
  };

  static Future<void> init() async {
    if (_initialized) return;
    _seedFallback();
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final alias = entry.key.toString();
          final emoji = entry.value?.toString() ?? '';
          _registerAlias(alias, emoji);
        }
      }
    } catch (_) {
      // Keep fallback aliases.
    } finally {
      _initialized = true;
    }
  }

  static String decode(String text) {
    if (text.trim().isEmpty) return text;
    if (!_initialized) _seedFallback();

    var decoded = text;
    decoded = _decodeUnicodeEscapes(decoded);
    decoded = _decodeHtmlEntities(decoded);
    decoded = _decodeCodepointTokens(decoded);
    try {
      decoded = _libraryParser.emojify(decoded);
    } catch (_) {
      // Keep processing with local parser fallback.
    }

    decoded = decoded.replaceAllMapped(
      RegExp(r':([a-zA-Z0-9_\-\+\s]{2,64}):'),
      (match) {
        final alias = match.group(1) ?? '';
        final resolved = _lookup(alias);
        if (resolved == null && kDebugMode) {
          debugPrint('[EmojiParser] Unresolved shortcode :$alias: in "$text"');
        }
        return resolved ?? match.group(0)!;
      },
    );

    decoded = decoded.replaceAllMapped(
      RegExp(r':([a-zA-Z][a-zA-Z0-9_\-\+]*(?:\s+[a-zA-Z][a-zA-Z0-9_\-\+]*){0,5})(?=\s|$|[.,!?;)\]\}])'),
      (match) {
        final full = match.group(0)!;
        final phrase = (match.group(1) ?? '').trim();
        if (phrase.isEmpty) return full;

        final direct = _lookup(phrase);
        if (direct != null) return direct;

        final words = phrase.split(RegExp(r'\s+'));
        final out = <String>[];
        var i = 0;
        var matchedAny = false;

        while (i < words.length) {
          String? found;
          var used = 0;
          for (var len = 3; len >= 1; len--) {
            if (i + len > words.length) continue;
            final candidate = words.sublist(i, i + len).join('_');
            final emoji = _lookup(candidate);
            if (emoji != null) {
              found = emoji;
              used = len;
              break;
            }
          }
          if (found != null) {
            out.add(found);
            i += used;
            matchedAny = true;
          } else {
            out.add(words[i]);
            i++;
          }
        }

        if (!matchedAny) {
          if (kDebugMode) {
            debugPrint('[EmojiParser] Unresolved loose shortcode "$full" in "$text"');
          }
          return full;
        }
        return out.join(' ');
      },
    );

    return decoded;
  }

  static String _decodeUnicodeEscapes(String input) {
    // Decode JSON-style unicode escapes such as \uD83D\uDE02.
    return input.replaceAllMapped(RegExp(r'\\u[0-9a-fA-F]{4}(?:\\u[0-9a-fA-F]{4})?'), (match) {
      final token = match.group(0)!;
      try {
        final decoded = jsonDecode('"$token"');
        if (decoded is String) return decoded;
      } catch (_) {}
      return token;
    });
  }

  static String _decodeHtmlEntities(String input) {
    // Decode HTML numeric entities like &#128512; and &#x1F600;.
    final decimal = RegExp(r'&#(\d+);');
    final hex = RegExp(r'&#x([0-9a-fA-F]+);');
    var out = input.replaceAllMapped(decimal, (match) {
      final value = int.tryParse(match.group(1)!);
      if (value == null) return match.group(0)!;
      return String.fromCharCode(value);
    });
    out = out.replaceAllMapped(hex, (match) {
      final value = int.tryParse(match.group(1)!, radix: 16);
      if (value == null) return match.group(0)!;
      return String.fromCharCode(value);
    });
    return out;
  }

  static String _decodeCodepointTokens(String input) {
    // Decode tokens like U+1F602 or 1F602 into emoji when isolated.
    return input.replaceAllMapped(RegExp(r'(?:(?:U\+|u\+)?)([0-9A-Fa-f]{4,6})'), (match) {
      final full = match.group(0)!;
      final code = match.group(1)!;
      // Avoid replacing regular words/numbers accidentally.
      if (full.length < 5) return full;
      final value = int.tryParse(code, radix: 16);
      if (value == null) return full;
      if (value < 0x1F000 || value > 0x1FAFF) return full;
      return String.fromCharCode(value);
    });
  }

  static void _seedFallback() {
    if (_aliasMap.isNotEmpty) return;
    for (final entry in _fallbackAliasMap.entries) {
      _registerAlias(entry.key, entry.value);
    }
  }

  static void _registerAlias(String rawAlias, String emoji) {
    final key = _normalizeAlias(rawAlias);
    if (key.isEmpty || emoji.isEmpty) return;
    _aliasMap[key] = emoji;
  }

  static String? _lookup(String alias) {
    for (final key in _candidateAliases(alias)) {
      final custom = _aliasMap[key];
      if (custom != null && custom.isNotEmpty) {
        return custom;
      }
      final lib = _lookupFromLibrary(key);
      if (lib != null && lib.isNotEmpty) {
        return lib;
      }
    }
    final dynamic = _lookupDynamicAlias(alias);
    if (dynamic != null && dynamic.isNotEmpty) {
      return dynamic;
    }
    return null;
  }

  static String _normalizeAlias(String raw) {
    return raw.trim().toLowerCase().replaceAll(':', '').replaceAll(RegExp(r'[^a-z0-9_\-\+\s]'), '').replaceAll(RegExp(r'[\s\-]+'), '_');
  }

  static List<String> _candidateAliases(String rawAlias) {
    final base = _normalizeAlias(rawAlias);
    if (base.isEmpty) return const <String>[];

    final variants = <String>{
      base,
      base.replaceAll('_', '-'),
      base.replaceAll('-', '_'),
    };

    if (base.endsWith('_face')) {
      final stripped = base.substring(0, base.length - 5);
      variants.add(stripped);
      variants.add(stripped.replaceAll('_', '-'));
    } else {
      variants.add('${base}_face');
      variants.add('${base}_face'.replaceAll('_', '-'));
    }

    if (base.contains('_over_mouth')) {
      final onMouth = base.replaceFirst('_over_mouth', '_on_mouth');
      variants.add(onMouth);
      variants.add(onMouth.replaceAll('_', '-'));
    }
    if (base.contains('_on_mouth')) {
      final overMouth = base.replaceFirst('_on_mouth', '_over_mouth');
      variants.add(overMouth);
      variants.add(overMouth.replaceAll('_', '-'));
    }

    if (base.contains('slightly_frown')) {
      variants.add(base.replaceFirst('slightly_frown', 'slightly_frowning_face'));
      variants.add(base.replaceFirst('slightly_frown', 'frowning_face'));
    }

    return variants.toList(growable: false);
  }

  static String? _lookupDynamicAlias(String rawAlias) {
    final alias = _normalizeAlias(rawAlias);
    if (alias.isEmpty) return null;

    // Support :us:, :pk:, :gb: and :flag_us:/:flag-us: style aliases.
    final twoLetter = RegExp(r'^[a-z]{2}$');
    final flagPattern = RegExp(r'^flag_([a-z]{2})$');

    String? countryCode;
    if (twoLetter.hasMatch(alias)) {
      countryCode = alias;
    } else {
      final match = flagPattern.firstMatch(alias);
      if (match != null) {
        countryCode = match.group(1);
      }
    }

    if (countryCode == null) return null;

    final fromLibrary = _lookupFromLibrary('flag-$countryCode') ?? _lookupFromLibrary(countryCode);
    if (fromLibrary != null && fromLibrary.isNotEmpty) {
      return fromLibrary;
    }

    return _countryCodeToFlag(countryCode);
  }

  static String? _countryCodeToFlag(String countryCode) {
    final code = countryCode.toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) return null;
    final first = code.codeUnitAt(0) + 127397;
    final second = code.codeUnitAt(1) + 127397;
    return String.fromCharCodes(<int>[first, second]);
  }

  static String? _lookupFromLibrary(String alias) {
    try {
      if (_libraryParser.hasName(alias)) {
        final code = _libraryParser.get(alias).code;
        if (code.isNotEmpty) return code;
      }

      final dashed = alias.replaceAll('_', '-');
      if (_libraryParser.hasName(dashed)) {
        final code = _libraryParser.get(dashed).code;
        if (code.isNotEmpty) return code;
      }

      final underscored = alias.replaceAll('-', '_');
      if (_libraryParser.hasName(underscored)) {
        final code = _libraryParser.get(underscored).code;
        if (code.isNotEmpty) return code;
      }
    } catch (_) {}
    return null;
  }
}
