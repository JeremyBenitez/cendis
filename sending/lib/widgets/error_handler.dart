import 'package:flutter/material.dart';
import 'package:sending/utils/app_colors.dart';
import '../widgets/error_connection_widget.dart';

class ErrorHandler {
  /// Muestra el widget de error de conexión en el lugar apropiado
  static Widget buildErrorWidget({
    required String? errorMessage,
    required VoidCallback onRetry,
    Widget? child,
  }) {
    if (errorMessage != null &&
        (errorMessage.contains('Connection') ||
            errorMessage.contains('connection') ||
            errorMessage.contains('failed') ||
            errorMessage.contains('conexión') ||
            errorMessage.contains('internet'))) {
      return ErrorConnectionWidget(
        onRetry: onRetry,
        message: 'Verifica tu conexión a internet.',
      );
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.azul),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    return child ?? const SizedBox.shrink();
  }
}
