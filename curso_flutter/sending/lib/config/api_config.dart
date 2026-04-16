class ApiConfig {
  // ============================================
  // CAMBIA AQUÍ LA URL BASE CUANDO SEA NECESARIO
  // ============================================
  static const String baseUrl = 'http://10.100.39.17:5041/api/v1';
  
  // Endpoints de Autenticación
  static const String auth = '/auth';
  
  // Endpoints de Tiendas
  static const String tiendas = '/notas/tiendas';
  
  // Endpoints de Pedidos
  static const String notasVar = '/notas/var';
  static const String yaguara = '/yaguara';
  static const String depositos = '/yaguara/depositos';// Endpoint victor

  // Endpoints de Escaneo
  static const String procesarNotas = '/notas/procesar_notas_yaguara';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  
  // Timeouts
  static const int connectionTimeout = 60;
  static const int receiveTimeout = 60;
  
  static String getPedidosEndpoint(String nombreTienda, {String? deposito}) {
    final storeNameUpper = nombreTienda.toUpperCase();
    
    if (storeNameUpper.contains('IMPORTADORA')) {
      var endpoint = '$yaguara/${Uri.encodeComponent(nombreTienda)}';
      if (deposito != null && deposito.isNotEmpty) {
        endpoint += '?deposito=${Uri.encodeComponent(deposito)}';
      }
      return endpoint;
    } else {
      return '$notasVar/${Uri.encodeComponent(nombreTienda)}';
    }
  }
}