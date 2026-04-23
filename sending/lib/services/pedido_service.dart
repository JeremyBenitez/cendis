import 'api_client.dart';
import '../config/api_config.dart';
import '../models/pedido_response.dart';

class PedidoService {
  final ApiClient _apiClient = ApiClient();

  Future<PedidosResponse> getPedidos(
    String nombreTienda, {
    String? deposito,
  }) async {
    try {
      final endpoint = ApiConfig.getPedidosEndpoint(
        nombreTienda,
        deposito: deposito,
      );
      print('📦 Endpoint calculado: $endpoint');

      final response = await _apiClient.get(endpoint);

      print('📦 Tipo de respuesta: ${response.runtimeType}');
      print('📦 Respuesta completa: $response');

      if (response is List) {
        print('📦 Es una lista con ${response.length} elementos');
        if (response.isNotEmpty) {
          print('📦 Primer elemento: ${response[0]}');
        }
      } else if (response is Map) {
        print('📦 Es un mapa con keys: ${response.keys}');
      }

      final result = PedidosResponse.fromJson(response);
      print('📦 Pedidos procesados: ${result.pedidos.length}');

      return result;
    } on ApiException catch (e) {
      print('❌ Error API: ${e.message}');
      print('❌ Status code: ${e.statusCode}');
      return PedidosResponse.error(e.message);
    } catch (e) {
      print('❌ Error conexión: Se perdió la conexión');
      return PedidosResponse.error('Verifica tu conexión a internet.');
    }
  }
}
