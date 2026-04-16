class ApiConfig {
  // ============================================
  // CAMBIA AQUÍ LA URL BASE CUANDO SEA NECESARIO
  // ============================================
  static const String baseUrl = 'http://10.100.39.17:5041/api/v1';
  
  // Endpoints
  static const String auth = '/auth';
  static const String tiendas = '/notas/tiendas';
  static const String pedidos = '/notas/pedidos';
  static const String notas = '/notas';
  static const String escanear = '/escanear';
  static const String verificar = '/verificar';
  static const String depositos = '/yaguara/depositos';// Endpoint victor
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  
  // Timeouts
  static const int connectionTimeout = 30; // segundos
  static const int receiveTimeout = 30; // segundos
}