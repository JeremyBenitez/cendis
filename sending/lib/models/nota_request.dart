class ProcesarNotaRequest {
  final String filtro;
  final String usuario;
  final String originDeposito;
  final String tienda;
  
  ProcesarNotaRequest({
    required this.filtro,
    required this.usuario,
    required this.originDeposito,
    required this.tienda,
  });
  
  Map<String, dynamic> toJson() => {
    'filtro': filtro,
    'usuario': usuario,  // ← Asegurar que sea 'usuario' en minúsculas
    'origin_deposito': originDeposito.isNotEmpty ? originDeposito : "S/D",
    'tienda': tienda,
  };
}

class EscanearProductoRequest {
  final int cantidad;
  final String codigo;
  final String documento;
  final String tienda;
  final String force;
  
  EscanearProductoRequest({
    required this.cantidad,
    required this.codigo,
    required this.documento,
    required this.tienda,
    required this.force,
  });
  
  Map<String, dynamic> toJson() => {
    'cantidad': cantidad,
    'codigo': codigo,
    'documento': documento,
    'tienda': tienda,
    'force': force.isNotEmpty ? force : "NO",
  };
}