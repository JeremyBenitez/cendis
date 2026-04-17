class ApiConfig {
  static const String baseUrl = 'http://10.100.39.17:5041/api/v1';
  
  static const String auth = '/auth';
  static const String tiendas = '/notas/tiendas';
  static const String notasVar = '/notas/var';
  static const String yaguara = '/yaguara';
  static const String depositos = '/yaguara/depositos';
  static const String procesarNotas = '/notas/procesar_notas_yaguara';
  
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  
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
  
  // Nuevo método para obtener el endpoint de escaneo
  static String getEscaneoEndpoint(String nombreTienda) {
    final storeNameUpper = nombreTienda.toUpperCase();
    
    if (storeNameUpper.contains('IMPORTADORA')) {
      return '/yaguara/procesar_notas_yaguara';
    } else {
      return '/notas/procesar_notas_yaguara';
    }
  }
}