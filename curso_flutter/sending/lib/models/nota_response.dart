class NotaResponse {
  final bool success;
  final String? message;
  final String? rawMessage;
  final NotaData? data;
  final List<ProductoData>? productosDirectos;
  final List<ProductoEscaneadoPrecargado>? productosPrecargados;
  final int? cantidadCorrecta; // ← Campo necesario

  NotaResponse({
    required this.success,
    this.message,
    this.rawMessage,
    this.data,
    this.productosDirectos,
    this.productosPrecargados,
    this.cantidadCorrecta,
  });

  factory NotaResponse.fromJson(dynamic json) {
    print('📦 Procesando respuesta en NotaResponse.fromJson');
    print('📦 Tipo: ${json.runtimeType}');
    print('📦 Contenido: $json');

    // Caso: La respuesta es una lista
    if (json is List) {
      // Buscar el mensaje de error dentro de la lista
      for (var item in json) {
        if (item is Map && item.containsKey('Response')) {
          final errorMsg = item['Response'];
          final cantidadesCargadas = item['cantidades_cargadas'];
          final documento = item['documento'];

          // Si hay cantidades_cargadas, precargar productos
          List<ProductoEscaneadoPrecargado>? productosPrecargados;
          if (cantidadesCargadas is List && cantidadesCargadas.isNotEmpty) {
            productosPrecargados = cantidadesCargadas
                .whereType<Map<String, dynamic>>()
                .map(
                  (e) => ProductoEscaneadoPrecargado(
                    codigo: e['codigo']?.toString() ?? '',
                    cantidad: e['cantidad'] ?? 0,
                  ),
                )
                .toList();
          }

          return NotaResponse(
            success: false,
            message: errorMsg?.toString(),
            rawMessage: errorMsg?.toString(),
            productosPrecargados: productosPrecargados,
            data: NotaData(
              documento: documento?.toString(),
              productos: productosPrecargados
                  ?.map(
                    (p) => ProductoData(
                      codigo: p.codigo,
                      descripcion: '',
                      cantidadEsperada: p.cantidad,
                      cantidadEscaneada: p.cantidad,
                    ),
                  )
                  .toList(),
            ),
          );
        }
      }

      // Si no hay mensaje de error, asumir que es lista de productos
      final productos = json
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductoData.fromJson(e))
          .toList();

      if (productos.isNotEmpty) {
        return NotaResponse(
          success: true,
          productosDirectos: productos,
          data: NotaData(productos: productos),
        );
      }

      return NotaResponse(
        success: false,
        message: 'Formato de respuesta inválido',
      );
    }

    // Caso: La respuesta es un mapa
    if (json is Map<String, dynamic>) {
      final isSuccess = json['success'] == true || json['error'] == null;
      final errorMsg = json['message'] ?? json['Mensaje'] ?? json['error'];

      return NotaResponse(
        success: isSuccess,
        message: isSuccess ? null : errorMsg?.toString(),
        rawMessage: errorMsg?.toString(),
        data: isSuccess ? NotaData.fromJson(json) : null,
      );
    }

    return NotaResponse(
      success: false,
      message: 'Formato de respuesta inválido',
    );
  }

  factory NotaResponse.error(String message) {
    return NotaResponse(success: false, message: message, rawMessage: message);
  }

  List<ProductoData> get productos {
    if (productosDirectos != null) return productosDirectos!;
    if (data?.productos != null) return data!.productos!;
    return [];
  }

  List<ProductoEscaneadoPrecargado> get productosPrecargadosList {
    return productosPrecargados ?? [];
  }
}

class ProductoEscaneadoPrecargado {
  final String codigo;
  final int cantidad;

  ProductoEscaneadoPrecargado({required this.codigo, required this.cantidad});
}

class NotaData {
  final String? documento;
  final List<ProductoData>? productos;
  final Map<String, dynamic>? rawData;

  NotaData({this.documento, this.productos, this.rawData});

  factory NotaData.fromJson(Map<String, dynamic> json) {
    List<ProductoData> productos = [];

    if (json['productos'] is List) {
      productos = (json['productos'] as List)
          .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['data'] is List) {
      productos = (json['data'] as List)
          .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['items'] is List) {
      productos = (json['items'] as List)
          .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['cantidades_cargadas'] is List) {
      productos = (json['cantidades_cargadas'] as List)
          .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return NotaData(
      documento: json['documento']?.toString() ?? json['nota']?.toString(),
      productos: productos,
      rawData: json,
    );
  }
}

class ProductoData {
  final String codigo;
  final String descripcion;
  final int cantidadEsperada;
  final int cantidadEscaneada;

  ProductoData({
    required this.codigo,
    required this.descripcion,
    required this.cantidadEsperada,
    required this.cantidadEscaneada,
  });

  factory ProductoData.fromJson(Map<String, dynamic> json) {
    return ProductoData(
      codigo:
          json['codigo']?.toString() ??
          json['c_codigo']?.toString() ??
          json['Codigo']?.toString() ??
          '',
      descripcion:
          json['descripcion']?.toString() ??
          json['c_descripcion']?.toString() ??
          '',
      cantidadEsperada: json['cantidad_esperada'] ?? json['cantidad'] ?? 0,
      cantidadEscaneada: json['cantidad_escaneada'] ?? 0,
    );
  }
}
