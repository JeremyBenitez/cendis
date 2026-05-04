import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ✅ Enum declarado fuera de la clase (top-level)
enum ResponseType {
  success,   // Éxito (verde)
  warning,   // Advertencia (naranja)
  info,      // Información (azul)
  error,     // Error (rojo) - solo para errores de servidor/BD
}

class ResponseDialog {
  /// Mostrar diálogo de respuesta
  static Future<void> show({
    required BuildContext context,
    required ResponseType type,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    if (!context.mounted) return;

    final config = <ResponseType, Map<String, dynamic>>{
      ResponseType.success: {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'iconColor': Colors.green,
        'defaultButtonText': 'Continuar',
      },
      ResponseType.warning: {
        'color': Colors.orange,
        'icon': Icons.warning_amber_rounded,
        'iconColor': Colors.orange,
        'defaultButtonText': 'Entendido',
      },
      ResponseType.info: {
        'color': AppColors.azul,
        'icon': Icons.info_outline,
        'iconColor': AppColors.azul,
        'defaultButtonText': 'Entendido',
      },
      ResponseType.error: {
        'color': AppColors.rojo,
        'icon': Icons.error_outline,
        'iconColor': AppColors.rojo,
        'defaultButtonText': 'Cerrar',
      },
    };

    final cfg = config[type]!;
    final btnText = buttonText ?? cfg['defaultButtonText'];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: (cfg['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cfg['icon'] as IconData,
                    size: 40,
                    color: cfg['iconColor'] as Color,
                  ),
                ),
                const SizedBox(height: 16),
                // Título
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cfg['color'] as Color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Mensaje
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      if (onPressed != null && context.mounted) {
                        onPressed();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cfg['color'] as Color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      btnText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // ✅ Letra blanca
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Método rápido para éxito
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    if (!context.mounted) return;
    await show(
      context: context,
      type: ResponseType.success,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Método rápido para advertencia
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    if (!context.mounted) return;
    await show(
      context: context,
      type: ResponseType.warning,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Método rápido para información
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    if (!context.mounted) return;
    await show(
      context: context,
      type: ResponseType.info,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Método rápido para error (solo errores de servidor/BD)
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    if (!context.mounted) return;
    await show(
      context: context,
      type: ResponseType.error,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Método para confirmación (con dos botones)
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    if (!context.mounted) return null;
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                cancelText ?? 'Cancelar',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azul,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                confirmText ?? 'Confirmar',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // ✅ Letra blanca
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}