// lib/screens/scanning/widgets/scanning_buttons.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class ScanningButtons extends StatelessWidget {
  final bool isEmpty;
  final VoidCallback onGuardar;

  const ScanningButtons({
    super.key,
    required this.isEmpty,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEmpty ? null : onGuardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azul,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}