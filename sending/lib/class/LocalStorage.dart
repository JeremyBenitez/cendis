import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  LocalStorage._(); // constructor privado (solo métodos estáticos)

  /// Guarda un String
  static Future<void> setData(String key, String value) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Obtiene un String
  static Future<String?> getData(String key) async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Guarda un bool
  static Future<void> setBool(String key, bool value) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Obtiene un bool
  static Future<bool?> getBool(String key) async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Guarda un int
  static Future<void> setInt(String key, int value) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Obtiene un int
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Guarda un double
  static Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  /// Obtiene un double
  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  /// Guarda una lista de Strings
  static Future<void> setStringList(String key, List<String> value) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  /// Obtiene una lista de Strings
  static Future<List<String>?> getStringList(String key) async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  // ============================
  // JSON (Map / List)
  // ============================

  /// Guarda un Map<String, dynamic> como JSON
  static Future<void> setJson(String key, Map<String, dynamic> value,) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  /// Obtiene un Map<String, dynamic> desde JSON
  static Future<Map<String, dynamic>?> getJson(String key) async {

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);

    if (jsonString == null) return null;
    
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Guarda una lista de Maps como JSON
  static Future<void> setJsonList(String key,List<Map<String, dynamic>> value,) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  /// Obtiene una lista de Maps desde JSON
  static Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ============================
  // Eliminar / Limpiar
  // ============================

  /// Elimina una key específica
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Limpia TODO el storage
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Verifica si existe una key
  static Future<bool> verificarKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
