import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import '../models/producto_escaneado.dart';
import 'scanning/scanning_screen.dart';
import 'orders_list_screen.dart';
import '../services/escaneo_service.dart';

class VerificationScreen extends StatefulWidget {
  final String noteId;
  final Tienda tienda;
  final String usuario;
  final String operacion;
  final List<ProductoEscaneado> productosEscaneados;
  final Map<String, int> productosEsperados;
  final int totalBultos;

  const VerificationScreen({
    super.key,
    required this.noteId,
    required this.tienda,
    required this.usuario,
    required this.operacion,
    required this.productosEscaneados,
    required this.productosEsperados,
    required this.totalBultos,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;

  int get totalUnidades => widget.productosEscaneados.fold(0, (sum, item) => sum + item.cantidad);

  Future<void> _volverAEscanear() async {
    setState(() {
      _isLoading = true;
    });

    final escaneoService = EscaneoService();
    final response = await escaneoService.procesarNota(
      filtro: widget.noteId,
      usuario: widget.usuario,
      originDeposito: '',
      tienda: widget.tienda.nombre,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanningScreen(
            noteId: widget.noteId,
            tienda: widget.tienda,
            usuario: widget.usuario,
            operacion: widget.operacion,
            productosNota: response.productos,
          ),
        ),
      );
    } else if (response.productosPrecargadosList.isNotEmpty) {
      final productosPrecargados = response.productosPrecargadosList
          .map((p) => ProductoEscaneado(codigo: p.codigo, cantidad: p.cantidad))
          .toList();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanningScreen(
            noteId: widget.noteId,
            tienda: widget.tienda,
            usuario: widget.usuario,
            operacion: widget.operacion,
            productosNota: response.productos,
            productosPrecargados: productosPrecargados,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar la nota. Intenta nuevamente.'),
          backgroundColor: AppColors.rojo,
        ),
      );
    }
  }

  void _irAPedidos() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersListScreen(
          usuario: widget.usuario,
          tienda: widget.tienda,
          operationType: widget.operacion,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Verificación'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.azul,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Cuadro de resumen
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'N° Nota:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          widget.noteId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tienda:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          widget.tienda.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bultos:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          '${widget.totalBultos}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.azul,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total de unidades:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          '$totalUnidades',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.azul,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Mensaje de éxito centrado
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 50,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '¡Movimiento exitoso!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azul,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Se han registrado ${widget.totalBultos} bultos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Botones
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Botón "Volver a escanear"
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _volverAEscanear,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Volver a escanear',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón "Ir a pedidos"
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _irAPedidos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azul,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Ir a pedidos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}