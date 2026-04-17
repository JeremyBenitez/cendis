class ProductoEscaneado {
  final String codigo;
  int cantidad;

  ProductoEscaneado({
    required this.codigo,
    required this.cantidad,
  });

  Map<String, dynamic> toJson() => {
        'codigo': codigo,
        'cantidad': cantidad,
      };

  factory ProductoEscaneado.fromJson(Map<String, dynamic> json) {
    return ProductoEscaneado(
      codigo: json['codigo'],
      cantidad: json['cantidad'],
    );
  }
}