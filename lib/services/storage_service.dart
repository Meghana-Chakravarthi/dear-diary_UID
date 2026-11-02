import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/entry.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const String _passwordKey = 'secret_diary_password_hash';
  static const String _entriesKey = 'secret_diary_entries';

  SharedPreferences? _prefs;
  List<Entry> entries = [];

  Future<void> init() async {
    await ensureInitialized();
    await loadEntries();
  }

  Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _hashPassword(String value) {
    return base64Encode(utf8.encode(value));
  }

  bool get hasPassword => _prefs?.getString(_passwordKey)?.isNotEmpty == true;

  bool passwordMatches(String value) {
    final savedHash = _prefs?.getString(_passwordKey);
    if (savedHash == null || savedHash.isEmpty) {
      return false;
    }
    return _hashPassword(value) == savedHash;
  }

  Future<void> setPassword(String value) async {
    await ensureInitialized();
    await _prefs!.setString(_passwordKey, _hashPassword(value));
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (!passwordMatches(currentPassword)) {
      throw StateError('Current password does not match.');
    }
    await ensureInitialized();
    await _prefs!.setString(_passwordKey, _hashPassword(newPassword));
  }

  Future<void> loadEntries() async {
    await ensureInitialized();
    final rawData = _prefs!.getString(_entriesKey);
    if (rawData == null || rawData.isEmpty) {
      entries = [];
      return;
    }

    try {
      final decoded = jsonDecode(rawData);
      final jsonList = List<dynamic>.from(decoded as List<dynamic>);
      entries = jsonList
          .map((json) => Entry.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      entries = [];
    }
  }

  Future<void> saveEntries() async {
    await ensureInitialized();
    final payload = entries.map((entry) => entry.toJson()).toList();
    await _prefs!.setString(_entriesKey, jsonEncode(payload));
  }

  Future<void> addEntry(Entry entry) async {
    entries.insert(0, entry);
    await saveEntries();
  }

  Future<void> deleteEntryAt(int index) async {
    if (index < 0 || index >= entries.length) {
      return;
    }
    entries.removeAt(index);
    await saveEntries();
  }
}
