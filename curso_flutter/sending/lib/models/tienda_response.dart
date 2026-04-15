import 'tienda.dart';

class TiendaResponse {
  final List<TiendaData> tiendas;
  final bool success;
  final String? message;
  
  TiendaResponse({
    required this.tiendas,
    required this.success,
    this.message,
  });
  
  // La API devuelve una lista directa, no un objeto con campo 'data'
  factory TiendaResponse.fromJson(List<dynamic> jsonList) {
    return TiendaResponse(
      tiendas: jsonList.map((e) => TiendaData.fromJson(e)).toList(),
      success: true,
      message: null,
    );
  }
  
  // Constructor para errores
  factory TiendaResponse.error(String message) {
    return TiendaResponse(
      tiendas: [],
      success: false,
      message: message,
    );
  }
}

class TiendaData {
  final int id;
  final String nombre;  // Este será el campo "tienda" de la API
  final String localidad;
  final String publicId;
  final String server;
  
  TiendaData({
    required this.id,
    required this.nombre,
    required this.localidad,
    required this.publicId,
    required this.server,
  });
  
  factory TiendaData.fromJson(Map<String, dynamic> json) {
    return TiendaData(
      id: json['id'] ?? 0,
      nombre: json['tienda'] ?? '',  // ← El campo se llama "tienda"
      localidad: json['localidad'] ?? '',
      publicId: json['public_id'] ?? '',
      server: json['server'] ?? '',
    );
  }
  
  // Convertir a tu modelo Tienda existente
  Tienda toTienda() {
    return Tienda(id: id, nombre: nombre);
  }
}