import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import '../models/producto_escaneado.dart';

class VerificationScreen extends StatefulWidget {
  final String noteId;
  final Tienda tienda;
  final List<ProductoEscaneado> productosEscaneados;
  final Map<String, int> productosEsperados; // Simula BD: {codigo: cantidadEsperada}

  const VerificationScreen({
    super.key,
    required this.noteId,
    required this.tienda,
    required this.productosEscaneados,
    required this.productosEsperados,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late List<Map<String, dynamic>> _verificaciones;
  bool _ajusteManual = false;

  @override
  void initState() {
    super.initState();
    _verificarProductos();
  }

  void _verificarProductos() {
    _verificaciones = widget.productosEscaneados.map((producto) {
      final esperado = widget.productosEsperados[producto.codigo] ?? 0;
      final coincide = producto.cantidad == esperado;
      return {
        'codigo': producto.codigo,
        'cantidadEscaneada': producto.cantidad,
        'cantidadEsperada': esperado,
        'coincide': coincide,
      };
    }).toList();
  }

  bool get _todoCoincide => _verificaciones.every((v) => v['coincide'] == true);

  int get _totalBultos => widget.productosEscaneados.length;
  int get _totalUnidades => widget.productosEscaneados.fold(0, (sum, p) => sum + p.cantidad);

  void _mostrarModalNoCoincide() {
    final noCoinciden = _verificaciones.where((v) => v['coincide'] == false).toList();

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
                            item['codigo'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Esc: ${item['cantidadEscaneada']}',
                            style: TextStyle(color: AppColors.rojo),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Esp: ${item['cantidadEsperada']}',
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
              'Total de bultos: $_totalBultos',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Total de unidades: $_totalUnidades',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _ajusteManual = true;
              });
            },
            child: const Text('Ajuste manual'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarResumen();
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

  void _mostrarResumen() {
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
            Text('N° Nota: ${widget.noteId}'),
            const SizedBox(height: 8),
            Text('Tienda: ${widget.tienda.nombre}'),
            const SizedBox(height: 8),
            const Divider(),
            Text('Total de bultos: $_totalBultos',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Total de unidades: $_totalUnidades',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (!_todoCoincide)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.rojo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: AppColors.rojo),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Se realizaron ajustes manuales',
                        style: TextStyle(fontSize: 12, color: AppColors.rojo),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Vuelve a OrdersListScreen
              Navigator.pop(context); // Vuelve a OrdersListScreen (si es necesario)
            },
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
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
                    Text(widget.noteId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total bultos:', style: TextStyle(color: Colors.grey.shade600)),
                    Text('$_totalBultos', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total unidades:', style: TextStyle(color: Colors.grey.shade600)),
                    Text('$_totalUnidades', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul)),
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
                    // Encabezado
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
                    // Lista de productos
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _verificaciones.length,
                        itemBuilder: (context, index) {
                          final item = _verificaciones[index];
                          final coincide = item['coincide'] as bool;
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
                                    item['codigo'],
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item['cantidadEscaneada'].toString(),
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
                                    item['cantidadEsperada'].toString(),
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
                      if (!_todoCoincide && !_ajusteManual) {
                        _mostrarModalNoCoincide();
                      } else {
                        _mostrarResumen();
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
}