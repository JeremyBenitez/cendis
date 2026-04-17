import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import '../models/producto_escaneado.dart';

class VerificationScreen extends StatelessWidget {
  final String noteId;
  final Tienda tienda;
  final List<ProductoEscaneado> productosEscaneados;
  final Map<String, int> productosEsperados;

  const VerificationScreen({
    super.key,
    required this.noteId,
    required this.tienda,
    required this.productosEscaneados,
    required this.productosEsperados,
  });

  // Total de unidades = suma de todas las cantidades escaneadas
  int get totalUnidades => productosEscaneados.fold(0, (sum, item) => sum + item.cantidad);

  @override
  Widget build(BuildContext context) {
    // Filtrar productos que no coinciden
    final noCoinciden = productosEscaneados.where((producto) {
      final esperado = productosEsperados[producto.codigo] ?? 0;
      return producto.cantidad != esperado;
    }).toList();

    final todoCoincide = noCoinciden.isEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Verificación'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.azul,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Resumen
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
                    Text('N° Nota:', style: TextStyle(color: Colors.grey.shade600)),
                    Text(noteId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tienda:', style: TextStyle(color: Colors.grey.shade600)),
                    Text(tienda.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total de unidades:', style: TextStyle(color: Colors.grey.shade600)),
                    Text(
                      '$totalUnidades',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tabla de verificación
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.azul,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('Código', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                          Expanded(child: Text('Escaneado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                          Expanded(child: Text('Esperado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                          SizedBox(width: 40, child: Text('Estado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: productosEscaneados.length,
                        itemBuilder: (context, index) {
                          final producto = productosEscaneados[index];
                          final esperado = productosEsperados[producto.codigo] ?? 0;
                          final coincide = producto.cantidad == esperado;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    producto.codigo,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    producto.cantidad.toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: coincide ? Colors.grey.shade800 : AppColors.rojo,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    esperado.toString(),
                                    style: const TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Icon(
                                    coincide ? Icons.check_circle : Icons.cancel,
                                    size: 20,
                                    color: coincide ? Colors.green : AppColors.rojo,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botones
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Volver a escaneo
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Seguir escaneando'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!todoCoincide) {
                        _mostrarModalInconsistencia(context, noCoinciden);
                      } else {
                        _mostrarResumen(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azul,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Guardar y salir', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModalInconsistencia(BuildContext context, List<ProductoEscaneado> noCoinciden) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.rojo, size: 28),
            const SizedBox(width: 8),
            const Text('Inconsistencia detectada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Las siguientes cantidades no coinciden con lo esperado:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: noCoinciden.length,
                itemBuilder: (context, index) {
                  final item = noCoinciden[index];
                  final esperado = productosEsperados[item.codigo] ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.codigo,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Esc: ${item.cantidad}',
                            style: TextStyle(color: AppColors.rojo),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Esp: $esperado',
                            style: TextStyle(color: AppColors.azul),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Total de unidades: $totalUnidades',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ajustar manualmente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarResumen(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azul,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _mostrarResumen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Resumen de operación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('N° Nota: $noteId'),
            const SizedBox(height: 8),
            Text('Tienda: ${tienda.nombre}'),
            const SizedBox(height: 8),
            const Divider(),
            Text(
              'Total de unidades: $totalUnidades',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Vuelve a OrdersListScreen
              Navigator.pop(context); // Cierra VerificationScreen
            },
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );
  }
}