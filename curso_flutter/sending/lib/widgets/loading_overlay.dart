import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final bool show;

  const LoadingOverlay({
    super.key,
    required this.show,
    this.message = 'Sincronizando datos...',
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: show ? 1 : 0,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.azul,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.azul,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}