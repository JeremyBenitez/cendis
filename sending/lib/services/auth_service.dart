import 'api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../config/api_config.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(ApiConfig.auth, request.toJson());
      
      if (response['token'] != null) {
        await _apiClient.setAuthToken(response['token']);
      }
      
      return LoginResponse(
        rawData: response,
        isSuccess: true,
        message: 'Inicio de sesión exitoso',
      );
    } on ApiException catch (e) {
      // Primero intentar extraer el mensaje personalizado de la respuesta
      String mensajePersonalizado = '';
      if (e.errors != null && e.errors is Map) {
        mensajePersonalizado = e.errors['Mensaje'] ?? e.errors['message'] ?? '';
      }
      
      // Si hay mensaje personalizado, usarlo
      if (mensajePersonalizado.isNotEmpty) {
        final mensajeAmigable = _traducirMensajePersonalizado(mensajePersonalizado);
        return LoginResponse(
          rawData: {'message': mensajePersonalizado, 'statusCode': e.statusCode},
          isSuccess: false,
          message: mensajeAmigable,
        );
      }
      
      // Si no, traducir por código HTTP
      final mensajeAmigable = _traducirError(e.message, e.statusCode);
      return LoginResponse(
        rawData: {'message': e.message, 'statusCode': e.statusCode},
        isSuccess: false,
        message: mensajeAmigable,
      );
    } catch (e) {
      return LoginResponse(
        rawData: {'message': e.toString()},
        isSuccess: false,
        message: 'No se pudo conectar al servidor. Verifica tu conexión a internet.',
      );
    }
  }
  
  String _traducirMensajePersonalizado(String mensaje) {
    final msgLower = mensaje.toLowerCase();
    
    if (msgLower.contains('usuario no encontrado') || msgLower.contains('user not found')) {
      return '❌ Usuario no encontrado. Verifica tu nombre de usuario.';
    }
    if (msgLower.contains('contraseña incorrecta') || msgLower.contains('invalid password')) {
      return '❌ Contraseña incorrecta. Por favor, inténtalo de nuevo.';
    }
    if (msgLower.contains('tienda no válida') || msgLower.contains('invalid store')) {
      return '❌ La tienda seleccionada no es válida. Contacta al administrador.';
    }
    if (msgLower.contains('usuario inactivo') || msgLower.contains('user inactive')) {
      return '❌ Tu usuario está inactivo. Contacta al administrador.';
    }
    
    return '❌ Error: $mensaje';
  }
  
  String _traducirError(String error, int statusCode) {
    // Primero, verificar si el error contiene mensajes específicos
    final errorLower = error.toLowerCase();
    
    // Mensajes de error comunes en la respuesta
    if (errorLower.contains('usuario no encontrado')) {
      return '❌ Usuario no encontrado. Verifica tu nombre de usuario.';
    }
    if (errorLower.contains('contraseña incorrecta')) {
      return '❌ Contraseña incorrecta. Por favor, inténtalo de nuevo.';
    }
    
    // Errores por código HTTP
    switch (statusCode) {
      case 400:
        return '❌ Datos inválidos. Verifica la información ingresada.';
      case 401:
        return '❌ Usuario o contraseña incorrectos. Por favor, inténtalo de nuevo.';
      case 403:
        return '❌ No tienes permisos para acceder a esta aplicación.';
      case 404:
        return '❌ Usuario no encontrado. Verifica tu nombre de usuario.';
      case 500:
        return '⚠️ Error interno del servidor. Intenta más tarde.';
      case 503:
        return '⚠️ Servicio temporalmente no disponible. Intenta más tarde.';
      default:
        break;
    }
    
    return '❌ Error al iniciar sesión. Intenta nuevamente.';
  }
  
  Future<void> logout() async {
    await _apiClient.clearAuthToken();
  }
  
  Future<bool> isLoggedIn() async {
    await _apiClient.loadAuthToken();
    return _apiClient.authToken != null;
  }
}