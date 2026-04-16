class Tienda {
  
  final int id;
  final String nombre;
  
  Tienda({required this.id, required this.nombre});
  
  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre};
  
  factory Tienda.fromJson(Map<String, dynamic> json) => Tienda(id: json['id'], nombre: json['nombre']);
}