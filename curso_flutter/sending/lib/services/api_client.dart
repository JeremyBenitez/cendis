import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  static const String baseUrl = ApiConfig.baseUrl;
  
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initDio();
  }
  
  late Dio _dio;
  String? _authToken;
  
  String? get authToken => _authToken;
  
  void _initDio() async {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      contentType: ApiConfig.contentType,
      connectTimeout: const Duration(seconds: ApiConfig.connectionTimeout),
      receiveTimeout: const Duration(seconds: ApiConfig.receiveTimeout),
      headers: {
        'Accept': ApiConfig.accept,
      },
    ));
    
    // Obtener directorio temporal para cookies (evita problemas de permisos)
    final Directory tempDir = await getTemporaryDirectory();
    final String cookiesPath = '${tempDir.path}/cookies';
    
    // Configurar cookie jar persistente
    final cookieJar = PersistCookieJar(
      storage: FileStorage(cookiesPath),
      ignoreExpires: true,
    );
    _dio.interceptors.add(CookieManager(cookieJar));
    
    // Logging interceptor para depuración
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('📤 ${options.method} a: ${options.uri}');
        print('📤 Headers: ${options.headers}');
        if (options.data != null) {
          print('📤 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Error: ${error.message}');
        if (error.response != null) {
          print('❌ Status: ${error.response?.statusCode}');
          print('❌ Data: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';
    }
  }
  
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _dio.options.headers.remove('Authorization');
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    await loadAuthToken();
    
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Error en la petición',
        errors: e.response?.data,
      );
    }
  }
  
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    await loadAuthToken();
    
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Error en la petición',
        errors: e.response?.data,
      );
    }
  }
  
  Future<dynamic> get(String endpoint) async {
    await loadAuthToken();
    
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Error en la petición',
        errors: e.response?.data,
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