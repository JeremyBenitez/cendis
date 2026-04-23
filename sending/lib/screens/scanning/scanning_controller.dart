// lib/screens/scanning/scanning_controller.dart
import 'package:flutter/material.dart';
import '../../models/tienda.dart';
import '../../models/producto_escaneado.dart';
import '../../services/escaneo_service.dart';
import '../../models/nota_response.dart';

class ScanningController extends ChangeNotifier {
  final EscaneoService _escaneoService = EscaneoService();

  String noteId;
  Tienda tienda;
  String usuario;
  List<ProductoData>? productosNota;

  bool isLoading = false;
  List<ProductoEscaneado> productos = [];
  Map<String, bool> productosValidados = {};
  int bultos = 0;
  String? errorMessage;

  ScanningController({
    required this.noteId,
    required this.tienda,
    required this.usuario,
    this.productosNota,
    List<ProductoEscaneado>? productosPrecargados,
  }) {
    print('📦 productosNota en controller: ${productosNota?.length ?? 0}');
    print('📦 productosEsperadosMap: $productosEsperadosMap');

    if (productosPrecargados != null && productosPrecargados.isNotEmpty) {
      _cargarPrecargados(productosPrecargados);
    }
  }

  void _cargarPrecargados(List<ProductoEscaneado> precargados) {
    productos = precargados
        .where((p) => p.cantidad > 0)
        .map(
          (p) => ProductoEscaneado(
            codigo: _normalizeCodigo(p.codigo),
            cantidad: p.cantidad,
          ),
        )
        .toList();

    for (final producto in productos) {
      productosValidados[producto.codigo] = true;
    }

    bultos = productos.length;
    notifyListeners();
  }

  String _limpiarCodigo(String codigo) {
    print('🔥 _limpiarCodigo ENTRADA: "$codigo"');
    String limpio = codigo.trim();

    if (limpio.contains('\\')) {
      limpio = limpio.split('\\').first;
      print('🔥 Quitó \\: "$limpio"');
    }
    if (limpio.contains('/')) {
      limpio = limpio.split('/').first;
      print('🔥 Quitó /: "$limpio"');
    }
    if (limpio.contains('|')) {
      limpio = limpio.split('|').first;
      print('🔥 Quitó |: "$limpio"');
    }
    if (limpio.contains(' ')) {
      limpio = limpio.split(' ').first;
      print('🔥 Quitó espacio: "$limpio"');
    }

    print('🔥 _limpiarCodigo SALIDA: "$limpio"');
    return limpio;
  }

  String _normalizeCodigo(String codigo) {
    print('🔥 _normalizeCodigo ENTRADA: "$codigo"');
    final resultado = _limpiarCodigo(codigo).toUpperCase();
    print('🔥 _normalizeCodigo SALIDA: "$resultado"');
    return resultado;
  }

  Map<String, int> get productosEsperadosMap {
    final map = <String, int>{};
    for (final producto in productosNota ?? []) {
      map[_normalizeCodigo(producto.codigo)] = producto.cantidadEsperada;
    }
    return map;
  }

  int? getCantidadEsperada(String codigo) {
    return productosEsperadosMap[_normalizeCodigo(codigo)];
  }

  bool existeCodigo(String codigo) {
    return productosEsperadosMap.containsKey(_normalizeCodigo(codigo));
  }

  // ✅ Método para obtener cantidad ya escaneada de un código
  int obtenerCantidadEscaneada(String codigo) {
    final codigoNormalizado = _normalizeCodigo(codigo);
    final producto = productos.firstWhere(
      (p) => _normalizeCodigo(p.codigo) == codigoNormalizado,
      orElse: () => ProductoEscaneado(codigo: '', cantidad: 0),
    );
    return producto.cantidad;
  }

  // ✅ Escaneo normal (force: 'no') - valida contra cantidad esperada
  Future<Map<String, dynamic>> escanearProducto(
    String codigoRaw,
    int cantidad,
  ) async {
    final codigo = _normalizeCodigo(codigoRaw);
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final response = await _escaneoService.escanearProducto(
      cantidad: cantidad,
      codigo: codigo,
      documento: noteId,
      tienda: tienda.nombre,
      force: 'no',
      usuario: usuario,
    );

    isLoading = false;
    notifyListeners();

    if (response.success) {
      _agregarProducto(codigo, cantidad);
      return {'success': true, 'message': response.message};
    } else {
      final mensaje = response.message ?? 'Error al escanear producto';
      return {
        'success': false,
        'message': mensaje,
        'cantidad_correcta': response.cantidadCorrecta,
      };
    }
  }

  // ✅ Escaneo forzado (force: 'yes') - guarda aunque no coincida
  Future<Map<String, dynamic>> forzarEscaneo(
    String codigoRaw,
    int cantidad,
  ) async {
    final codigo = _normalizeCodigo(codigoRaw);
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final response = await _escaneoService.escanearProducto(
      cantidad: cantidad,
      codigo: codigo,
      documento: noteId,
      tienda: tienda.nombre,
      force: 'yes',
      usuario: usuario,
    );

    isLoading = false;
    notifyListeners();

    if (response.success) {
      _agregarProducto(codigo, cantidad);
      return {'success': true, 'message': response.message};
    } else {
      final mensaje = response.message ?? 'Error al escanear producto';
      return {
        'success': false,
        'message': mensaje,
        'cantidad_correcta': response.cantidadCorrecta,
      };
    }
  }

  void _agregarProducto(String codigo, int cantidad) {
    final codigoNormalizado = _normalizeCodigo(codigo);
    final existingIndex = productos.indexWhere(
      (p) => _normalizeCodigo(p.codigo) == codigoNormalizado,
    );

    if (existingIndex >= 0) {
      productos[existingIndex].cantidad += cantidad;
    } else {
      productos.add(
        ProductoEscaneado(codigo: codigoNormalizado, cantidad: cantidad),
      );
    }
    productosValidados[codigoNormalizado] = true;
    bultos++;

    notifyListeners();
  }

  void limpiarTodo() {
    productos.clear();
    productosValidados.clear();
    bultos = 0;
    errorMessage = null;
    notifyListeners();
  }

  void eliminarProducto(String codigo) {
    final codigoNormalizado = _normalizeCodigo(codigo);
    productos.removeWhere(
      (p) => _normalizeCodigo(p.codigo) == codigoNormalizado,
    );
    productosValidados.remove(codigoNormalizado);
    notifyListeners();
  }

  int get totalUnidades =>
      productos.fold(0, (sum, item) => sum + item.cantidad);
  int get totalBultos => bultos;
  bool get isEmpty => productos.isEmpty;
}