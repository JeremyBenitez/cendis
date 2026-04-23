// lib/screens/scanning/modals/cantidad_incorrecta_modal.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

Future<void> mostrarModalCantidadIncorrecta({
  required BuildContext context,
  required String codigo,
  required int cantidadEscaneada,
  required int cantidadEsperada,
  required Future<void> Function() onValidar,
  required VoidCallback onAjusteManual,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cantidad Incorrecta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('La cantidad escaneada no coincide con lo esperado'),
            const SizedBox(height: 12),
            Text('Código: $codigo'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Escaneado'),
                    Text(
                      '$cantidadEscaneada',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rojo,
                      ),
                    ),
                  ],
                ),
                const Text('vs'),
                Column(
                  children: [
                    const Text('Esperado'),
                    Text(
                      '$cantidadEsperada',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azul,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              // ✅ Botón "Cambiar manualmente" a la IZQUIERDA (primero)
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onAjusteManual();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cambiar'),
                ),
              ),
              const SizedBox(width: 12),
              // ✅ Botón "Validar" a la DERECHA (segundo)
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await onValidar();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Validar'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}