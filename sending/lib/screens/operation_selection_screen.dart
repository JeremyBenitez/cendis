// ignore_for_file: strict_top_level_inference, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sending/class/LocalStorage.dart';
import 'package:sending/services/depositos_service.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import 'orders_list_screen.dart';

class OperationSelectionScreen extends StatefulWidget {
  final String usuario;
  final Tienda tienda;

  const OperationSelectionScreen({
    super.key,
    required this.usuario,
    required this.tienda,
  });

  @override
  State<OperationSelectionScreen> createState() =>
      _OperationSelectionScreenState();
}

class _OperationSelectionScreenState extends State<OperationSelectionScreen> {
  String? _selectedOperation;
  List<dynamic> listaDepositos = [];
  Map<String, dynamic>? depositoSeleccionado; // Cambiado de String a Map

  final List<Map<String, dynamic>> _operations = [
    {
      'id': 'recepcion',
      'title': 'Recepción',
      'description': 'Gestionar entrada de mercancía',
      'icon': Icons.inventory_2,
      'color': AppColors.azul,
    },
    {
      'id': 'pedidos',
      'title': 'Pedidos',
      'description': 'Gestionar salida de productos',
      'icon': Icons.local_shipping,
      'color': AppColors.rojo,
    },
  ];

  void _handleContinue() {
    if (_selectedOperation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrdersListScreen(
            usuario: widget.usuario,
            tienda: widget.tienda,
            operationType: _selectedOperation!,
          ),
        ),
      );
    }
  }

  //mostrar modal
  mostrarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Variable local para el depósito seleccionado dentro del diálogo
        Map<String, dynamic>? depositoLocal = depositoSeleccionado;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'Depósito de origen',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      text:
                          'Seleccione el depósito en el cual se recibirán las notas para ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: widget.tienda.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.azul,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<Map<String, dynamic>>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Depósito',
                      labelStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: depositoLocal,
                    hint: const Text('Seleccione un depósito'),
                    items: listaDepositos.map((deposito) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: deposito,
                        child: Text(
                          deposito['nombre'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (nuevoDeposito) async {
                      // Actualizar el estado local del diálogo
                      setDialogState(() {
                        depositoLocal = nuevoDeposito;
                      });

                      // También actualizar el estado del widget padre si es necesario
                      setState(() {
                        depositoSeleccionado = nuevoDeposito;
                      });

                      await LocalStorage.setJson('deposito', nuevoDeposito!);
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rojo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azul,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: depositoLocal == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          _handleContinue();
                        },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  depositos() async {
    try {
      final DepositosService depositosService = DepositosService();

      var response = await depositosService.getDepositos();

      if (response['status']) {
        if (response["data"].isNotEmpty) {
          setState(() {
            listaDepositos = response['data'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['mensaje'] ?? 'No se encontraron depósitos.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }

        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['mensaje'] ?? 'Error desconocido al obtener depósitos.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    depositos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con animación
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  children: [
                    // Avatar o ícono de usuario
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradienteBoton,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.azul.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azul,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.usuario,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.azul.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.store, size: 14, color: AppColors.azul),
                          const SizedBox(width: 4),
                          Text(
                            widget.tienda.nombre,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.azul,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Subtítulo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Seleccione el tipo de operación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tarjetas de operación
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    itemCount: widget.tienda.nombre == "IMPORTADORA"
                        ? _operations.length
                        : _operations.length - 1,
                    itemBuilder: (context, index) {
                      final operation = _operations[index];
                      final isSelected = _selectedOperation == operation['id'];

                      return widget.tienda.nombre == "IMPORTADORA" &&
                              operation['id'] == 'recepcion'
                          ? Container()
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  if (operation['id'] == 'pedidos') {
                                    mostrarModal(context);
                                  }

                                  setState(() {
                                    _selectedOperation = operation['id'];
                                  });

                                  HapticFeedback.lightImpact();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? (operation['color'] as Color)
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  (operation['color'] as Color)
                                                      .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Contenido principal
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Ícono
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                gradient: isSelected
                                                    ? LinearGradient(
                                                        colors: [
                                                          operation['color']
                                                              as Color,
                                                          (operation['color']
                                                                  as Color)
                                                              .withOpacity(0.7),
                                                        ],
                                                      )
                                                    : LinearGradient(
                                                        colors: [
                                                          Colors.grey.shade300,
                                                          Colors.grey.shade200,
                                                        ],
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Icon(
                                                operation['icon'] as IconData,
                                                size: 28,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Textos
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    operation['title']
                                                        as String,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isSelected
                                                          ? operation['color']
                                                                as Color
                                                          : Colors
                                                                .grey
                                                                .shade800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    operation['description']
                                                        as String,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Indicador de selección
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color:
                                                    operation['color'] as Color,
                                                size: 28,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ),

              if (widget.tienda.nombre != "IMPORTADORA")
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedOperation != null
                          ? _handleContinue
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _selectedOperation != null
                              ? AppColors.gradienteBoton
                              : null,
                          color: _selectedOperation != null
                              ? null
                              : Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
