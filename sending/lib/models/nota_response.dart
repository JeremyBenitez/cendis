import 'dart:convert';

class NotaResponse {
  final bool success;
  final String? message;
  final String? rawMessage;
  final NotaData? data;
  final List<ProductoData>? productosDirectos;
  final List<ProductoEscaneadoPrecargado>? productosPrecargados;
  final int? cantidadCorrecta;

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
    print('📦 Procesando respuesta JSON: ${jsonEncode(json)}');
    print('📦 Tipo de respuesta: ${json.runtimeType}');

    // ✅ CASO 1: Respuesta exitosa con solo "Response" (ej: "Cantidad actualizada correctamente")
    if (json is Map && json.containsKey('Response') && json.length == 1) {
      return NotaResponse(
        success: true,
        message: json['Response'].toString(),
      );
    }

    // Caso 2: Lista con dos elementos [mapaConDatos, codigoHttp] (nota duplicada)
    if (json is List && json.length >= 2 && json[0] is Map) {
      final innerMap = Map<String, dynamic>.from(json[0]);
      if (innerMap.containsKey('Response') && innerMap.containsKey('cantidades_cargadas')) {
        final errorMsg = innerMap['Response'].toString();
        final cantidadesCargadas = innerMap['cantidades_cargadas'] as List;
        final precargados = cantidadesCargadas
            .map((e) => ProductoEscaneadoPrecargado(
                  codigo: (e as Map)['codigo']?.toString() ?? '',
                  cantidad: (e as Map)['cantidad'] ?? 0,
                ))
            .toList();
        return NotaResponse(
          success: false,
          message: errorMsg,
          productosPrecargados: precargados,
        );
      }
    }

    // Caso 3: Lista con [mensaje, listaDeProductos] (importadora exitosa)
    if (json is List && json.length == 2) {
      final primerElemento = json[0];
      final segundoElemento = json[1];
      if (primerElemento is String && segundoElemento is List) {
        final mensaje = primerElemento;
        final listaProductos = segundoElemento;
        final productos = listaProductos
            .map((item) => ProductoData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        return NotaResponse(
          success: true,
          message: mensaje,
          productosDirectos: productos,
          data: NotaData(productos: productos),
        );
      }
    }

    // Caso 4: Lista general de productos (sin mensaje)
    if (json is List) {
      final List<ProductoData> productos = [];
      for (var item in json) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (map.containsKey('c_CodArticulo') || map.containsKey('codigo')) {
            productos.add(ProductoData.fromJson(map));
          }
        }
      }
      if (productos.isNotEmpty) {
        return NotaResponse(
          success: true,
          productosDirectos: productos,
          data: NotaData(productos: productos),
        );
      }
      return NotaResponse(
        success: false,
        message: 'No se encontraron productos',
      );
    }

    // Caso 5: Mapa con error (para tiendas normales)
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      if (map.containsKey('Response')) {
        final errorMsg = map['Response'].toString();
        int? cantidadCorrecta;
        if (map.containsKey('cantidad_correcta')) {
          final raw = map['cantidad_correcta'];
          if (raw is int) cantidadCorrecta = raw;
          else if (raw is String) cantidadCorrecta = int.tryParse(raw.split('.')[0]);
          else if (raw is double) cantidadCorrecta = raw.toInt();
        }
        return NotaResponse(
          success: false,
          message: errorMsg,
          cantidadCorrecta: cantidadCorrecta,
        );
      }

      if (map.containsKey('data')) {
        final dataJson = map['data'];
        if (dataJson is List) {
          final productos = dataJson
              .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          return NotaResponse(
            success: true,
            productosDirectos: productos,
            data: NotaData(productos: productos),
          );
        } else if (dataJson is Map) {
          return NotaResponse(
            success: true,
            data: NotaData.fromJson(Map<String, dynamic>.from(dataJson)),
          );
        }
      }

      if (map.containsKey('productos') && map['productos'] is List) {
        final productos = (map['productos'] as List)
            .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return NotaResponse(
          success: true,
          productosDirectos: productos,
          data: NotaData(productos: productos),
        );
      }

      if (map.containsKey('cantidades_cargadas') && map['cantidades_cargadas'] is List) {
        final precargados = (map['cantidades_cargadas'] as List)
            .map((e) => ProductoEscaneadoPrecargado(
                  codigo: (e as Map)['codigo']?.toString() ?? '',
                  cantidad: (e as Map)['cantidad'] ?? 0,
                ))
            .toList();
        return NotaResponse(
          success: false,
          message: map['Response']?.toString() ?? 'Nota ya procesada',
          productosPrecargados: precargados,
        );
      }

      return NotaResponse(
        success: false,
        message: 'Formato de respuesta no reconocido',
      );
    }

    return NotaResponse(
      success: false,
      message: 'Tipo de respuesta inesperado: ${json.runtimeType}',
    );
  }

  factory NotaResponse.error(String message) {
    return NotaResponse(
      success: false,
      message: message,
      rawMessage: message,
    );
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

class NotaData {
  final String? documento;
  final List<ProductoData>? productos;
  final Map<String, dynamic>? rawData;

  NotaData({
    this.documento,
    this.productos,
    this.rawData,
  });

  factory NotaData.fromJson(Map<String, dynamic> json) {
    List<ProductoData> productos = [];
    if (json['productos'] is List) {
      productos = (json['productos'] as List)
          .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['items'] is List) {
      productos = (json['items'] as List)
          .map((e) => ProductoData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return NotaData(
      documento: json['documento']?.toString(),
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
    final codigo = json['c_CodArticulo']?.toString() ??
                    json['codigo']?.toString() ??
                    json['c_codigo']?.toString() ??
                    '';
    final descripcion = json['c_Descri']?.toString() ??
                         json['descripcion']?.toString() ??
                         '';
    final cantidad = (json['n_Cantidad'] ?? json['cantidad_esperada'] ?? json['cantidad'] ?? 0).toInt();

    return ProductoData(
      codigo: codigo,
      descripcion: descripcion,
      cantidadEsperada: cantidad,
      cantidadEscaneada: 0,
    );
  }
}

class ProductoEscaneadoPrecargado {
  final String codigo;
  final int cantidad;

  ProductoEscaneadoPrecargado({
    required this.codigo,
    required this.cantidad,
  });
}