import 'api_client.dart';
import '../models/tienda_response.dart';
import '../config/api_config.dart';

class TiendaService {
  final ApiClient _apiClient = ApiClient();
  
  Future<TiendaResponse> getTiendas() async {
    try {
      final response = await _apiClient.get(ApiConfig.tiendas);
      
      print('📦 Respuesta procesada: $response');
      
      if (response is List) {
        return TiendaResponse.fromJson(response);
      } else {
        return TiendaResponse.error('Formato de respuesta inválido');
      }
    } on ApiException catch (e) {
      // Error de API - mensaje del backend
      return TiendaResponse.error(e.message);
    } catch (e) {
      // Error de conexión - mensaje amigable (sin detalles técnicos)
      return TiendaResponse.error('Verifica tu conexión a internet.');
    }
  }
}