class PedidosResponse {
  final List<PedidoData> pedidos;
  final bool success;
  final String? message;
  
  PedidosResponse({
    required this.pedidos,
    required this.success,
    this.message,
  });
  
  factory PedidosResponse.fromJson(dynamic json) {
    List<dynamic> pedidosList = [];
    
    if (json is List) {
      pedidosList = json;
    } else if (json['data'] is List) {
      pedidosList = json['data'];
    } else if (json['pedidos'] is List) {
      pedidosList = json['pedidos'];
    }
    
    return PedidosResponse(
      pedidos: pedidosList.map((e) => PedidoData.fromJson(e)).toList(),
      success: true,
      message: null,
    );
  }
  
  factory PedidosResponse.error(String message) {
    return PedidosResponse(
      pedidos: [],
      success: false,
      message: message,
    );
  }
}

class PedidoData {
  final String id;
  final String fecha;
  final String? estado;
  final Map<String, dynamic>? rawData;
  
  PedidoData({
    required this.id,
    required this.fecha,
    this.estado,
    this.rawData,
  });
  
  factory PedidoData.fromJson(Map<String, dynamic> json) {
    String id = '';
    String fecha = '';
    
    // Obtener ID
    if (json['c_Documento'] != null) {
      id = json['c_Documento'].toString();
    } else if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['nota'] != null) {
      id = json['nota'].toString();
    } else if (json['numero'] != null) {
      id = json['numero'].toString();
    } else if (json['pedido_id'] != null) {
      id = json['pedido_id'].toString();
    }
    
    // Obtener y formatear fecha
    String fechaRaw = '';
    if (json['d_Fecha'] != null) {
      fechaRaw = json['d_Fecha'].toString();
    } else if (json['fecha'] != null) {
      fechaRaw = json['fecha'].toString();
    } else if (json['fecha_creacion'] != null) {
      fechaRaw = json['fecha_creacion'].toString();
    } else if (json['created_at'] != null) {
      fechaRaw = json['created_at'].toString();
    }
    
    fecha = _formatearFecha(fechaRaw);
    
    return PedidoData(
      id: id,
      fecha: fecha,
      estado: json['estado']?.toString(),
      rawData: json,
    );
  }
  
  static String _formatearFecha(String fechaRaw) {
    try {
      // Limpiar la fecha
      String fechaLimpia = fechaRaw.trim();
      
      // Formato Yaguara: "Wed, 15 Apr 2026 17:48:56 GMT"
      if (fechaLimpia.contains(',')) {
        final partes = fechaLimpia.split(' ');
        if (partes.length >= 4) {
          final dia = partes[1].padLeft(2, '0');
          final mes = _mesANumero(partes[2]);
          final anio = partes[3];
          return '$dia/$mes/$anio';
        }
      }
      
      // Formato ISO: "2026-04-15" o "2026-04-15T17:48:56"
      if (fechaLimpia.contains('-')) {
        final partes = fechaLimpia.split('-');
        if (partes.length >= 3) {
          String anio = partes[0];
          String mes = partes[1];
          String dia = partes[2].substring(0, 2);
          return '$dia/$mes/$anio';
        }
      }
      
      // Formato: "2026/04/15"
      if (fechaLimpia.contains('/')) {
        final partes = fechaLimpia.split('/');
        if (partes.length >= 3) {
          return '${partes[2]}/${partes[1]}/${partes[0]}';
        }
      }
      
      // Si no se pudo formatear, devolver la original
      return fechaRaw;
    } catch (e) {
      print('Error formateando fecha: $fechaRaw -> $e');
      return fechaRaw;
    }
  }
  
  static String _mesANumero(String mes) {
    const meses = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };
    return meses[mes] ?? mes;
  }
}