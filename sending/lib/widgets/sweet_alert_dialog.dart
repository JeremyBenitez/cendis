import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SweetAlertDialog {
  /// Modal de advertencia (warning)
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? detailTitle,
    String? detailValue1,
    String? detailValue2,
    String? button1Text,
    VoidCallback? onButton1Pressed,
    String? button2Text,
    VoidCallback? onButton2Pressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de advertencia
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.rojo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: AppColors.rojo,
                  ),
                ),
                const SizedBox(height: 16),
                // Título
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.rojo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Mensaje
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                if (detailTitle != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          detailTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (detailValue1 != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (detailValue1 != null)
                                Column(
                                  children: [
                                    const Text(
                                      'Escaneado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      detailValue1,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.rojo,
                                      ),
                                    ),
                                  ],
                                ),
                              if (detailValue1 != null && detailValue2 != null)
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.grey,
                                ),
                              if (detailValue2 != null)
                                Column(
                                  children: [
                                    const Text(
                                      'Esperado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      detailValue2,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.azul,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Botones
                Row(
                  children: [
                    if (button1Text != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              onButton1Pressed ?? () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.azul),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            button1Text,
                            style: TextStyle(color: AppColors.azul),
                          ),
                        ),
                      ),
                    if (button1Text != null && button2Text != null)
                      const SizedBox(width: 12),
                    if (button2Text != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              onButton2Pressed ?? () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.azul,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            button2Text,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Modal de éxito (success)
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (buttonText != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          onButtonPressed ?? () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(color: Colors.white),
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

  /// Modal de error
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.rojo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: AppColors.rojo,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.rojo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (buttonText != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          onButtonPressed ?? () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rojo,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(color: Colors.white),
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

  /// Modal informativo
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.azul.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 40,
                    color: AppColors.azul,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azul,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (buttonText != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          onButtonPressed ?? () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azul,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(color: Colors.white),
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

  /// Modal de confirmación (info)
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.azul.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 40,
                    color: AppColors.azul,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azul,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(cancelText ?? 'Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azul,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(confirmText ?? 'Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
