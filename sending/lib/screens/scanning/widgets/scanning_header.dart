// lib/screens/scanning/widgets/scanning_header.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class ScanningHeader extends StatelessWidget {
  final TextEditingController codigoController;
  final TextEditingController cantidadController;
  final FocusNode codigoFocusNode;
  final VoidCallback onAgregar;
  final bool isLoading;

  const ScanningHeader({
    super.key,
    required this.codigoController,
    required this.cantidadController,
    required this.codigoFocusNode,
    required this.onAgregar,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: codigoController,
            focusNode: codigoFocusNode,
            enabled: true,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Código',
              labelStyle: TextStyle(color: Colors.grey.shade600),
              hintText: 'Escribe o escanea el código',
              hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.azul, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.azul, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: isLoading ? null : onAgregar,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradienteBoton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Agregar',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}