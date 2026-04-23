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
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: ApiConfig.contentType,
        connectTimeout: const Duration(seconds: ApiConfig.connectionTimeout),
        receiveTimeout: const Duration(seconds: ApiConfig.receiveTimeout),
        headers: {'Accept': ApiConfig.accept},
      ),
    );

    final Directory tempDir = await getTemporaryDirectory();
    final String cookiesPath = '${tempDir.path}/cookies';

    final cookieJar = PersistCookieJar(
      storage: FileStorage(cookiesPath),
      ignoreExpires: true,
    );
    _dio.interceptors.add(CookieManager(cookieJar));

    // Interceptor silencioso para no mostrar errores técnicos
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('📤 ${options.method} a: ${options.uri.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 Status: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Error en petición: ${error.type}');
          return handler.next(error);
        },
      ),
    );
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

  bool _isConnectionError(DioException e) {
    final isTimeout =
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
    final isSocket = e.error is SocketException;
    return isTimeout ||
        isSocket ||
        (e.type == DioExceptionType.unknown &&
            e.error != null &&
            e.error is SocketException);
  }

  String _extraerMensajeReal(dynamic responseData) {
    if (responseData == null) return '';
    
    if (responseData is Map) {
      // Buscar mensaje en diferentes campos posibles
      return responseData['Response']?.toString() ?? 
             responseData['message']?.toString() ?? 
             responseData['Mensaje']?.toString() ?? 
             responseData['error']?.toString() ?? 
             responseData['error_description']?.toString() ?? '';
    } else if (responseData is String) {
      return responseData;
    }
    return '';
  }

  ApiException _buildApiException(DioException e) {
    final bool connectionError = _isConnectionError(e);
    final int statusCode = e.response?.statusCode ?? 500;
    final dynamic responseData = e.response?.data;
    
    // ✅ Extraer mensaje real del backend
    final String mensajeReal = _extraerMensajeReal(responseData);
    
    String message;
    
    if (connectionError) {
      // ✅ Error de conexión real
      message = 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
    } else if (mensajeReal.isNotEmpty) {
      // ✅ Usar el mensaje real del backend
      message = mensajeReal;
    } else {
      // ✅ Mensajes por código HTTP (fallback)
      switch (statusCode) {
        case 400:
          message = 'Solicitud incorrecta. Verifica los datos ingresados.';
          break;
        case 401:
          message = 'Usuario o contraseña incorrectos.';
          break;
        case 403:
          message = 'No tienes permisos para acceder.';
          break;
        case 404:
          message = 'Recurso no encontrado.';
          break;
        case 500:
          message = 'Error interno del servidor. Intenta más tarde.';
          break;
        case 503:
          message = 'Servicio no disponible. Intenta más tarde.';
          break;
        default:
          message = 'Error en la comunicación con el servidor.';
      }
    }
    
    print('❌ ApiException - Status: $statusCode, Message: $message');
    
    return ApiException(
      statusCode: connectionError ? 0 : statusCode,
      message: message,
      errors: responseData,
    );
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    await loadAuthToken();

    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _buildApiException(e);
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    await loadAuthToken();

    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _buildApiException(e);
    }
  }

  Future<dynamic> get(String endpoint) async {
    await loadAuthToken();

    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _buildApiException(e);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;

  ApiException({required this.statusCode, required this.message, this.errors});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}