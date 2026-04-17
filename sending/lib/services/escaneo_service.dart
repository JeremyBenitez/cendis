import 'dart:convert';
import 'api_client.dart';
import '../config/api_config.dart';
import '../models/nota_response.dart';

class EscaneoService {
  final ApiClient _apiClient = ApiClient();
  
  Future<NotaResponse> procesarNota({
    required String filtro,
    required String usuario,
    required String originDeposito,
    required String tienda,
  }) async {
    try {
      final Map<String, String> requestData = {
        'filtro': filtro.toString(),
        'usuario': usuario.toString(),
        'origin_deposito': originDeposito.isEmpty ? "" : originDeposito.toString(),
        'tienda': tienda.toString(),
      };
      
      // ✅ Usar endpoint dinámico según tipo de tienda
      final endpoint = ApiConfig.getEscaneoEndpoint(tienda);
      
      print('========== PROCESAR NOTA ==========');
      print('📤 URL: $endpoint');
      print('📤 Body: $requestData');
      print('📤 JSON: ${jsonEncode(requestData)}');
      
      final response = await _apiClient.post(endpoint, requestData);
      
      print('📥 Response status: OK');
      print('📥 Response type: ${response.runtimeType}');
      print('📥 Response: $response');
      print('====================================');
      
      final notaResponse = NotaResponse.fromJson(response);
      print('📦 NotaResponse success: ${notaResponse.success}');
      print('📦 Productos: ${notaResponse.productos.length}');
      print('📦 Precargados: ${notaResponse.productosPrecargadosList.length}');
      
      return notaResponse;
    } on ApiException catch (e) {
      print('❌ Error API: ${e.message}');
      print('❌ Status code: ${e.statusCode}');
      print('❌ Detalles: ${e.errors}');
      
      int? cantidadCorrecta;
      String? mensajeError = e.message;
      
      if (e.errors is Map) {
        final errorsMap = e.errors as Map;
        if (errorsMap.containsKey('cantidad_correcta')) {
          final raw = errorsMap['cantidad_correcta'];
          if (raw is int) cantidadCorrecta = raw;
          else if (raw is String) cantidadCorrecta = int.tryParse(raw.split('.')[0]);
          else if (raw is double) cantidadCorrecta = raw.toInt();
        }
        if (errorsMap.containsKey('Response')) {
          mensajeError = errorsMap['Response'].toString();
        }
      }
      
      return NotaResponse(
        success: false,
        message: mensajeError,
        rawMessage: e.message,
        cantidadCorrecta: cantidadCorrecta,
      );
    } catch (e) {
      print('❌ Error conexión: $e');
      return NotaResponse(
        success: false,
        message: 'Error de conexión',
        rawMessage: e.toString(),
      );
    }
  }
  
  Future<NotaResponse> escanearProducto({
    required int cantidad,
    required String codigo,
    required String documento,
    required String tienda,
    required String force,
    required String usuario,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'cantidad': cantidad,
        'codigo': codigo,
        'documento': documento,
        'tienda': tienda,
        'usuario': usuario,
        'force': force,
      };
      
      // ✅ Usar endpoint dinámico según tipo de tienda
      final endpoint = ApiConfig.getEscaneoEndpoint(tienda);
      
      print('========== ESCANEAR PRODUCTO ==========');
      print('📤 URL: $endpoint');
      print('📤 Method: PUT');
      print('📤 Body: $requestData');
      
      final response = await _apiClient.put(endpoint, requestData);
      
      print('📥 Response: $response');
      print('========================================');
      
      return NotaResponse.fromJson(response);
    } on ApiException catch (e) {
      print('❌ Error API: ${e.message}');
      print('❌ Status code: ${e.statusCode}');
      print('❌ Errors: ${e.errors}');
      
      int? cantidadCorrecta;
      String? mensajeError = e.message;
      
      if (e.errors is Map) {
        final errorsMap = e.errors as Map;
        if (errorsMap.containsKey('cantidad_correcta')) {
          final raw = errorsMap['cantidad_correcta'];
          if (raw is int) cantidadCorrecta = raw;
          else if (raw is String) cantidadCorrecta = int.tryParse(raw.split('.')[0]);
          else if (raw is double) cantidadCorrecta = raw.toInt();
        }
        if (errorsMap.containsKey('Response')) {
          mensajeError = errorsMap['Response'].toString();
        }
      }
      
      return NotaResponse(
        success: false,
        message: mensajeError,
        rawMessage: e.message,
        cantidadCorrecta: cantidadCorrecta,
      );
    } catch (e) {
      print('❌ Error conexión: $e');
      return NotaResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
        rawMessage: e.toString(),
      );
    }
  }
}