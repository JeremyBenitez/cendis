import 'api_client.dart';
import '../models/tienda_response.dart';
import '../config/api_config.dart';  // ← Importar configuración

class TiendaService {
  final ApiClient _apiClient = ApiClient();
  
  Future<TiendaResponse> getTiendas() async {
    try {
      final response = await _apiClient.get(ApiConfig.tiendas);  // ← Usar endpoint
      
      print('📦 Respuesta procesada: $response');
      
      if (response is List) {
        return TiendaResponse.fromJson(response);
      } else {
        return TiendaResponse.error('Formato de respuesta inválido: no es una lista');
      }
    } on ApiException catch (e) {
      return TiendaResponse.error(e.message);
    } catch (e) {
      return TiendaResponse.error('Error de conexión: ${e.toString()}');
    }
  }
}