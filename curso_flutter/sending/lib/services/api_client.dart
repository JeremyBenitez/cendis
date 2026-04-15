import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  static const String baseUrl = ApiConfig.baseUrl;
  
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();
  
  String? _authToken;
  
  String? get authToken => _authToken;
  
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }
  
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': ApiConfig.contentType,
      'Accept': ApiConfig.accept,
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('📤 POST a: $url');
    print('📤 Body: $data');
    
    final response = await http.post(
      url,
      headers: _buildHeaders(),
      body: jsonEncode(data),
    ).timeout(
      Duration(seconds: ApiConfig.receiveTimeout),
      onTimeout: () => throw Exception('Tiempo de conexión agotado'),
    );
    
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    
    return _handleResponse(response);
  }
  
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('📤 GET a: $url');
    
    final response = await http.get(
      url,
      headers: _buildHeaders(),
    ).timeout(
      Duration(seconds: ApiConfig.receiveTimeout),
      onTimeout: () => throw Exception('Tiempo de conexión agotado'),
    );
    
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    
    return _handleResponse(response);
  }
  
  dynamic _handleResponse(http.Response response) {
    final decodedResponse = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedResponse;
    } else {
      // Extraer mensaje personalizado si existe
      String errorMessage = 'Error en la petición';
      dynamic errorData = null;
      
      if (decodedResponse is Map) {
        errorMessage = decodedResponse['Mensaje'] ?? 
                       decodedResponse['message'] ?? 
                       decodedResponse['error'] ??
                       'Error en la petición';
        errorData = decodedResponse;
      }
      
      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
        errors: errorData,
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;
  
  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });
  
  @override
  String toString() => 'ApiException: $statusCode - $message';
}