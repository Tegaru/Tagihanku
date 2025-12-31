import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyBills = 'bills';
  static const _keyAuth = 'auth';
  static const _keyAuthList = 'auth_list';
  static const _keyActiveEmail = 'active_email';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<List<Map<String, dynamic>>> loadBills() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyBills);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveBills(List<Map<String, dynamic>> bills) async {
    final prefs = await _prefs;
    await prefs.setString(_keyBills, jsonEncode(bills));
  }

  Future<Map<String, dynamic>?> loadAuth() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyAuth);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveAuth(Map<String, dynamic> data) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAuth, jsonEncode(data));
  }

  Future<void> clearAuth() async {
    final prefs = await _prefs;
    await prefs.remove(_keyAuth);
  }

  Future<List<Map<String, dynamic>>> loadAuthList() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyAuthList);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveAuthList(List<Map<String, dynamic>> data) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAuthList, jsonEncode(data));
  }

  Future<String?> loadActiveEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyActiveEmail);
  }

  Future<void> saveActiveEmail(String? email) async {
    final prefs = await _prefs;
    if (email == null) {
      await prefs.remove(_keyActiveEmail);
    } else {
      await prefs.setString(_keyActiveEmail, email);
    }
  }
}
