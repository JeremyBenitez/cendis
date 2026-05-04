// lib/screens/scanning/widgets/scanning_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../scanning_controller.dart';

class ScanningList extends StatelessWidget {
  const ScanningList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScanningController>(
      builder: (context, controller, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.azul,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Código', style: TextStyle(color: Colors.white))),
                    Expanded(flex: 1, child: Text('Cantidad', style: TextStyle(color: Colors.white), textAlign: TextAlign.center)),
                    SizedBox(width: 50, child: Text('', style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
              Expanded(
                child: controller.productos.isEmpty
                    ? const Center(child: Text('No hay productos escaneados', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: controller.productos.length,
                        itemBuilder: (context, index) {
                          final producto = controller.productos[index];
                          final validado = controller.productosValidados[producto.codigo] ?? false;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(producto.codigo, style: const TextStyle(fontSize: 12))),
                                Expanded(
                                  flex: 1,
                                  child: Text(producto.cantidad.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: validado
                                      ? const SizedBox.shrink()
                                      : const Icon(Icons.cancel, size: 18, color: AppColors.rojo),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}