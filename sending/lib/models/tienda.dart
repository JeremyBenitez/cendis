class Tienda {
  
  final int id;
  final String nombre;
  final String localidad; // Agregado para almacenar la localidad
  
  Tienda({required this.id, required this.nombre, required this.localidad});
  
  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'localidad': localidad};
  
  factory Tienda.fromJson(Map<String, dynamic> json) => Tienda(
        id: json['id'],
        nombre: json['nombre'],
        localidad: json['localidad'],
      );
}