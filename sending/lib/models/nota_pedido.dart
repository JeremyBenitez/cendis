class NotaPedido {
  final String id;
  final String fecha;

  NotaPedido({
    required this.id,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha,
      };

  factory NotaPedido.fromJson(Map<String, dynamic> json) {
    return NotaPedido(
      id: json['id'],
      fecha: json['fecha'],
    );
  }
}

// Datos mock para pruebas
final List<NotaPedido> mockOrders = [
  NotaPedido(id: "NE-2026-001", fecha: "2026-04-13"),
  NotaPedido(id: "NE-2026-002", fecha: "2026-04-13"),
  NotaPedido(id: "NE-2026-003", fecha: "2026-04-12"),
  NotaPedido(id: "NE-2026-004", fecha: "2026-04-12"),
  NotaPedido(id: "NE-2026-005", fecha: "2026-04-11"),
  NotaPedido(id: "NE-2026-006", fecha: "2026-04-11"),
  NotaPedido(id: "NE-2026-007", fecha: "2026-04-10"),
  NotaPedido(id: "NE-2026-008", fecha: "2026-04-10"),
];