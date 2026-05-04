import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ErrorConnectionWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  final TextStyle? messageTextStyle;

  const ErrorConnectionWidget({
    super.key,
    required this.onRetry,
    this.message,
    this.messageTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.rojo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off,
                size: 40,
                color: AppColors.rojo,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin conexión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.azul,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'No se pudo conectar al servidor.',
              style:
                  messageTextStyle ??
                  TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
