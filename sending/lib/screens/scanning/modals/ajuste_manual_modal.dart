// lib/screens/scanning/modals/ajuste_manual_modal.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

Future<void> mostrarAjusteManual({
  required BuildContext context,
  required String codigo,
  required int cantidadEsperada,
  required void Function(int nuevaCantidad) onAceptar,
}) async {
  final cantidadInicial = cantidadEsperada == 0 ? 1 : cantidadEsperada;
  final ajusteController = TextEditingController(text: cantidadInicial.toString());

  // ✅ Solo mostrar el mensaje de "completado" si la cantidad esperada es 0
  final bool estaCompletado = cantidadEsperada == 0;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(estaCompletado ? 'Ajuste manual - Producto completado' : 'Ajuste manual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Código: $codigo'),
            const SizedBox(height: 12),
            if (estaCompletado)
              const Text(
                'Este código ya fue completado.\nPuedes agregar unidades adicionales:',
                style: TextStyle(fontSize: 12, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            TextField(
              controller: ajusteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nueva cantidad',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final nuevaCantidad = int.tryParse(ajusteController.text) ?? 1;
                    if (nuevaCantidad <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La cantidad debe ser mayor a 0'), backgroundColor: AppColors.rojo),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    onAceptar(nuevaCantidad);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}