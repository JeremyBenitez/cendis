// lib/screens/scanning/scanning_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/tienda.dart';
import '../../models/producto_escaneado.dart';
import '../../models/nota_response.dart';
import '../verification_screen.dart';
import '../../widgets/response_dialog.dart';
import 'scanning_controller.dart';
import 'widgets/scanning_list.dart';
import 'widgets/scanning_buttons.dart';
import 'modals/cantidad_incorrecta_modal.dart';
import 'modals/ajuste_manual_modal.dart';
import 'widgets/scanning_header.dart';

class ScanningScreen extends StatefulWidget {
  final String noteId;
  final Tienda tienda;
  final String usuario;
  final String operacion;
  final List<ProductoData>? productosNota;
  final List<ProductoEscaneado>? productosPrecargados;

  const ScanningScreen({
    super.key,
    required this.noteId,
    required this.tienda,
    required this.usuario,
    required this.operacion,
    this.productosNota,
    this.productosPrecargados,
  });

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  late ScanningController _controller;
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final FocusNode _codigoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cantidadController.text = '1';
    _controller = ScanningController(
      noteId: widget.noteId,
      tienda: widget.tienda,
      usuario: widget.usuario,
      productosNota: widget.productosNota,
      productosPrecargados: widget.productosPrecargados,
    );

    // ✅ Limpiar código automáticamente cuando el PDA escanea
    _codigoController.addListener(() {
      final rawValue = _codigoController.text;
      if (rawValue.contains('/')) {
        final partes = rawValue.split('/');
        final codigoLimpio = partes[0].trim();
        _codigoController.text = codigoLimpio;

        if (partes.length > 1) {
          final cantidadDetectada = int.tryParse(partes[1].trim());
          if (cantidadDetectada != null && cantidadDetectada > 0) {
            _cantidadController.text = cantidadDetectada.toString();
            print('📌 Cantidad automática: $cantidadDetectada');
          }
        }
        print('📌 Escaneo - Código limpio: "$codigoLimpio"');
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _codigoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _cantidadController.dispose();
    _codigoFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _escanearYMostrarResultado(String codigo, int cantidad) async {
    final result = await _controller.escanearProducto(codigo, cantidad);
    if (!mounted) return;

    if (result['success'] == true) {
      _codigoController.clear();
      _cantidadController.text = '1';
      _codigoFocusNode.requestFocus();
      ResponseDialog.showSuccess(
        context: context,
        title: '¡Producto Agregado!',
        message: '$codigo x $cantidad unidades',
      );
    } else {
      final mensaje = result['message'] as String? ?? 'Error al escanear producto';
      final cantidadCorrecta = result['cantidad_correcta'];
      
      // ✅ Si el backend devuelve cantidad_correcta, mostrar modal de cantidad incorrecta
      if (cantidadCorrecta != null && cantidadCorrecta is int && cantidadCorrecta > 0) {
        print('🎯 Mostrando modal cantidad incorrecta - Esperado: $cantidadCorrecta');
        mostrarModalCantidadIncorrecta(
          context: context,
          codigo: codigo,
          cantidadEscaneada: cantidad,
          cantidadEsperada: cantidadCorrecta,
          onValidar: () => _escanearYMostrarResultado(codigo, cantidadCorrecta),
          onAjusteManual: () => mostrarAjusteManual(
            context: context,
            codigo: codigo,
            cantidadEsperada: cantidadCorrecta,
            onAceptar: (nuevaCantidad) => _forzarEscanearYMostrarResultado(codigo, nuevaCantidad),
          ),
        );
        return;
      }
      
      final mensajeLower = mensaje.toLowerCase();

      if (mensajeLower.contains('no existe') ||
          mensajeLower.contains('inválido') ||
          mensajeLower.contains('no pertenece') ||
          mensajeLower.contains('no encontrado')) {
        ResponseDialog.showWarning(
          context: context,
          title: 'Código no válido',
          message: mensaje,
        );
      } else if (mensajeLower.contains('contado en su totalidad') ||
          mensajeLower.contains('ya fue contado') ||
          mensajeLower.contains('completado')) {
        ResponseDialog.showInfo(
          context: context,
          title: 'Producto completado',
          message: mensaje,
        );
      } else if (mensajeLower.contains('servidor') ||
          mensajeLower.contains('error')) {
        ResponseDialog.showError(
          context: context,
          title: 'Error del servidor',
          message: mensaje,
        );
      } else {
        ResponseDialog.showWarning(
          context: context,
          title: 'Error',
          message: mensaje,
        );
      }
    }
  }

  Future<void> _forzarEscanearYMostrarResultado(String codigo, int cantidad) async {
    final result = await _controller.forzarEscaneo(codigo, cantidad);
    if (!mounted) return;

    if (result['success'] == true) {
      _codigoController.clear();
      _cantidadController.text = '1';
      _codigoFocusNode.requestFocus();
      ResponseDialog.showSuccess(
        context: context,
        title: '¡Producto Agregado!',
        message: '$codigo x $cantidad unidades',
      );
    } else {
      final mensaje = result['message'] as String? ?? 'Error al escanear producto';
      ResponseDialog.showWarning(
        context: context,
        title: 'Error',
        message: mensaje,
      );
    }
  }

  void _handleLoad() async {
    String codigoRaw = _codigoController.text.trim();
    int cantidad = int.tryParse(_cantidadController.text.trim()) ?? 1;

    print('========== HANDLE LOAD ==========');
    print('📌 Código: "$codigoRaw"');
    print('📌 Cantidad: $cantidad');

    if (codigoRaw.isEmpty) {
      ResponseDialog.showWarning(
        context: context,
        title: 'Campo vacío',
        message: 'Por favor, ingrese un código',
      );
      return;
    }

    if (cantidad <= 0) {
      ResponseDialog.showWarning(
        context: context,
        title: 'Cantidad inválida',
        message: 'Ingrese una cantidad válida mayor a 0',
      );
      return;
    }

    // ✅ Siempre enviar al backend, él decide si es correcto o no
    print('✅ Enviando al backend...');
    _escanearYMostrarResultado(codigoRaw, cantidad);
  }

  void _handleSave() {
    if (_controller.isEmpty) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          noteId: widget.noteId,
          tienda: widget.tienda,
          usuario: widget.usuario,
          operacion: widget.operacion,
          productosEscaneados: _controller.productos,
          productosEsperados: _controller.productosEsperadosMap,
          totalBultos: _controller.totalBultos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text('Escaneo - ${widget.noteId}'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.azul,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                ScanningHeader(
                  codigoController: _codigoController,
                  cantidadController: _cantidadController,
                  codigoFocusNode: _codigoFocusNode,
                  onAgregar: _handleLoad,
                  isLoading: _controller.isLoading,
                ),
                Expanded(child: ScanningList()),
                ScanningButtons(
                  isEmpty: _controller.isEmpty,
                  onGuardar: _handleSave,
                ),
              ],
            ),
            if (_controller.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}