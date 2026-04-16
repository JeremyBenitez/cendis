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
        'origin_deposito': originDeposito.isEmpty ? "S/D" : originDeposito.toString(),
        'tienda': tienda.toString(),
      };
      
      print('========== PROCESAR NOTA ==========');
      print('📤 URL: ${ApiConfig.procesarNotas}');
      print('📤 Body: $requestData');
      print('📤 JSON: ${jsonEncode(requestData)}');
      
      final response = await _apiClient.post(ApiConfig.procesarNotas, requestData);
      
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
      return NotaResponse(
        success: false,
        message: e.message,
        rawMessage: e.message,
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
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'cantidad': cantidad,
        'codigo': codigo,
        'documento': documento,
        'tienda': tienda,
        'force': force.isEmpty ? "NO" : force,
      };
      
      print('========== ESCANEAR PRODUCTO ==========');
      print('📤 URL: ${ApiConfig.procesarNotas}');
      print('📤 Method: PUT');
      print('📤 Body: $requestData');
      print('📤 JSON: ${jsonEncode(requestData)}');
      
      final response = await _apiClient.put(ApiConfig.procesarNotas, requestData);
      
      print('📥 Response status: OK');
      print('📥 Response type: ${response.runtimeType}');
      print('📥 Response: $response');
      print('========================================');
      
      Map<String, dynamic> convertedResponse;
      if (response is Map) {
        convertedResponse = Map<String, dynamic>.from(response);
      } else {
        convertedResponse = {};
      }
      
      return NotaResponse(
        success: true,
        data: convertedResponse.isNotEmpty ? NotaData.fromJson(convertedResponse) : null,
      );
    } on ApiException catch (e) {
      print('❌ Error API: ${e.message}');
      print('❌ Status code: ${e.statusCode}');
      return NotaResponse(
        success: false,
        message: e.message,
        rawMessage: e.message,
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