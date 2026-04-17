import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import '../models/producto_escaneado.dart';
import '../services/escaneo_service.dart';
import '../models/nota_response.dart';
import 'verification_screen.dart';
import '../widgets/response_dialog.dart';

class ScanningScreen extends StatefulWidget {
  final String noteId;
  final Tienda tienda;
  final String usuario;
  final List<ProductoData>? productosNota;
  final List<ProductoEscaneado>? productosPrecargados;

  const ScanningScreen({
    super.key,
    required this.noteId,
    required this.tienda,
    required this.usuario,
    this.productosNota,
    this.productosPrecargados,
  });

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final FocusNode _codigoFocusNode = FocusNode();
  final EscaneoService _escaneoService = EscaneoService();

  bool _isPdaMode = true;
  bool _isLoading = false;
  List<ProductoEscaneado> _productos = [];
  Map<String, bool> _productosValidados = {};

  int get totalProductos => _productos.length;

  Map<String, int> get _productosEsperadosMap {
    final map = <String, int>{};
    for (final producto in widget.productosNota ?? []) {
      map[producto.codigo] = producto.cantidadEsperada;
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _cantidadController.text = '1';

    if (widget.productosPrecargados != null &&
        widget.productosPrecargados!.isNotEmpty) {
      _productos = List.from(widget.productosPrecargados!);
      for (final producto in _productos) {
        _productosValidados[producto.codigo] = true;
      }
      print('📦 Productos precargados: ${_productos.length}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ResponseDialog.showInfo(
          context: context,
          title: 'Nota ya procesada',
          message:
              'Esta nota ya fue procesada anteriormente. Se han cargado los productos ya escaneados.',
          buttonText: 'Continuar',
        );
      });
    }

    print(
      '📦 Productos esperados en esta nota: ${widget.productosNota?.length ?? 0}',
    );

    if (_isPdaMode) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _codigoFocusNode.requestFocus();
      });
    }

    _codigoController.addListener(() {
      if (_isPdaMode && _codigoController.text.isNotEmpty) {
        FocusScope.of(context).nextFocus();
      }
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _cantidadController.dispose();
    _codigoFocusNode.dispose();
    super.dispose();
  }

  void _handleToggleMode() {
    setState(() {
      _isPdaMode = !_isPdaMode;
      _codigoController.clear();

      if (_isPdaMode) {
        _codigoFocusNode.requestFocus();
      }
    });
  }

  void _mostrarModalCantidadIncorrecta({
    required String codigo,
    required int cantidadEscaneada,
    required int cantidadEsperada,
  }) {
    showDialog(
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
              Text('La cantidad escaneada no coincide con lo esperado'),
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _abrirAjusteManual(codigo, cantidadEsperada);
              },
              child: const Text('Cambiar manualmente'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });

                final response = await _escaneoService.escanearProducto(
                  cantidad: cantidadEscaneada,
                  codigo: codigo,
                  documento: widget.noteId,
                  tienda: widget.tienda.nombre,
                  force: 'no',
                  usuario: widget.usuario,
                );

                setState(() {
                  _isLoading = false;
                });

                if (response.success) {
                  _agregarProductoConCantidad(
                    codigo,
                    cantidadEscaneada,
                    validado: true,
                  );
                } else {
                  if (response.cantidadCorrecta != null) {
                    _mostrarModalCantidadIncorrecta(
                      codigo: codigo,
                      cantidadEscaneada: cantidadEscaneada,
                      cantidadEsperada: response.cantidadCorrecta!,
                    );
                  } else {
                    ResponseDialog.showError(
                      context: context,
                      title: 'Error del servidor',
                      message:
                          response.message ?? 'Ocurrió un error inesperado',
                      buttonText: 'Entendido',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.azul),
              child: const Text('Validar'),
            ),
          ],
        );
      },
    );
  }

  void _abrirAjusteManual(String codigo, int cantidadEsperada) {
    final cantidadInicial = cantidadEsperada == 0 ? 1 : cantidadEsperada;

    final TextEditingController ajusteController = TextEditingController(
      text: cantidadInicial.toString(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Ajuste manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Código: $codigo'),
              const SizedBox(height: 12),
              if (cantidadEsperada == 0)
                const Text(
                  'Este código ya fue completado.\nPuedes agregar unidades adicionales:',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              TextField(
                controller: ajusteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nueva cantidad',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nuevaCantidad = int.tryParse(ajusteController.text) ?? 1;
                if (nuevaCantidad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La cantidad debe ser mayor a 0'),
                      backgroundColor: AppColors.rojo,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _enviarConForce(codigo, nuevaCantidad);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.azul),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _enviarConForce(String codigo, int nuevaCantidad) async {
    print('🚨 ENVIANDO CON force = yes 🚨');
    print('Código: $codigo, Nueva cantidad: $nuevaCantidad');

    setState(() {
      _isLoading = true;
    });

    final response = await _escaneoService.escanearProducto(
      cantidad: nuevaCantidad,
      codigo: codigo,
      documento: widget.noteId,
      tienda: widget.tienda.nombre,
      force: 'yes',
      usuario: widget.usuario,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      ResponseDialog.showSuccess(
        context: context,
        title: '¡Producto Actualizado!',
        message: response.message ?? 'Producto actualizado correctamente',
        buttonText: 'Continuar',
      );
      _agregarProductoConCantidad(codigo, nuevaCantidad, validado: true);
    } else {
      if (response.cantidadCorrecta != null) {
        _mostrarModalCantidadIncorrecta(
          codigo: codigo,
          cantidadEscaneada: nuevaCantidad,
          cantidadEsperada: response.cantidadCorrecta!,
        );
      } else {
        ResponseDialog.showError(
          context: context,
          title: 'Error del servidor',
          message: response.message ?? 'Ocurrió un error inesperado',
          buttonText: 'Entendido',
        );
      }
    }
  }

  void _agregarProductoConCantidad(
    String codigo,
    int cantidad, {
    bool validado = true,
  }) {
    print('📦 Agregando producto: $codigo x $cantidad (validado: $validado)');
    print('📦 Productos actuales antes: ${_productos.length}');

    setState(() {
      final existingIndex = _productos.indexWhere((p) => p.codigo == codigo);
      if (existingIndex >= 0) {
        print('📦 Producto ya existe, sumando cantidad');
        _productos[existingIndex].cantidad += cantidad;
      } else {
        print('📦 Producto nuevo, agregando');
        _productos.add(ProductoEscaneado(codigo: codigo, cantidad: cantidad));
      }
      _productosValidados[codigo] = validado;
      _codigoController.clear();
      _cantidadController.text = '1';

      if (_isPdaMode) {
        _codigoFocusNode.requestFocus();
      }
    });

    print('📦 Productos actuales después: ${_productos.length}');
    print('📦 Validados: $_productosValidados');

    ResponseDialog.showSuccess(
      context: context,
      title: '¡Producto Agregado!',
      message: '$codigo x $cantidad unidades',
      buttonText: 'Continuar',
    );
  }

  void _handleLoad() async {
    print('🚨🚨🚨 _handleLoad fue llamado 🚨🚨🚨');

    final String codigo = _codigoController.text.trim();
    final int? cantidad = int.tryParse(_cantidadController.text.trim());

    print('========== HANDLE LOAD ==========');
    print('🔍 Código ingresado: "$codigo"');
    print('🔍 Cantidad ingresada: $cantidad');
    print('🔍 Productos esperados map: $_productosEsperadosMap');
    print('================================');

    if (codigo.isEmpty) {
      ResponseDialog.showWarning(
        context: context,
        title: 'Campo vacío',
        message: 'Por favor, ingrese un código',
        buttonText: 'Entendido',
      );
      return;
    }

    if (cantidad == null || cantidad <= 0) {
      ResponseDialog.showWarning(
        context: context,
        title: 'Cantidad inválida',
        message: 'Por favor, ingrese una cantidad válida mayor a 0',
        buttonText: 'Entendido',
      );
      return;
    }

    final cantidadEsperada = _productosEsperadosMap[codigo];

    if (cantidadEsperada != null && cantidad != cantidadEsperada) {
      print('⚠️ Cantidad incorrecta: $cantidad vs $cantidadEsperada');
      _mostrarModalCantidadIncorrecta(
        codigo: codigo,
        cantidadEscaneada: cantidad,
        cantidadEsperada: cantidadEsperada,
      );
      return;
    }

    if (cantidadEsperada == null) {
      print(
        '⚠️ Código no encontrado localmente, se enviará a la API para validación',
      );
    } else {
      print('✅ Cantidad correcta, enviando a API...');
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _escaneoService.escanearProducto(
      cantidad: cantidad,
      codigo: codigo,
      documento: widget.noteId,
      tienda: widget.tienda.nombre,
      force: 'no',
      usuario: widget.usuario,
    );

    setState(() {
      _isLoading = false;
    });

    print('📥 Respuesta escaneo - success: ${response.success}');
    print('📥 Mensaje: ${response.message}');
    print('📥 Cantidad correcta sugerida: ${response.cantidadCorrecta}');

    if (response.success) {
      _agregarProductoConCantidad(codigo, cantidad, validado: true);
    } else {
      if (response.cantidadCorrecta != null) {
        _mostrarModalCantidadIncorrecta(
          codigo: codigo,
          cantidadEscaneada: cantidad,
          cantidadEsperada: response.cantidadCorrecta!,
        );
      } else if (response.message != null &&
          (response.message!.contains('contado en su totalidad') ||
              response.message!.contains('ya fue contado'))) {
        _mostrarModalCantidadIncorrecta(
          codigo: codigo,
          cantidadEscaneada: cantidad,
          cantidadEsperada: 0,
        );
      } else {
        ResponseDialog.showError(
          context: context,
          title: 'Error del servidor',
          message: response.message ?? 'Ocurrió un error inesperado',
          buttonText: 'Entendido',
        );
      }
    }
  }

  void _handleRemove(String codigo) {
    setState(() {
      _productos.removeWhere((p) => p.codigo == codigo);
      _productosValidados.remove(codigo);
    });
  }

  void _handleSave() {
    if (_productos.isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          noteId: widget.noteId,
          tienda: widget.tienda,
          productosEscaneados: _productos,
          productosEsperados: _productosEsperadosMap,
        ),
      ),
    );
  }

  void _handleClear() async {
    if (_productos.isEmpty) return;

    final confirmado = await ResponseDialog.showConfirm(
      context: context,
      title: 'Limpiar todo',
      message: '¿Está seguro de limpiar todos los productos escaneados?',
      confirmText: 'Sí, limpiar',
      cancelText: 'Cancelar',
    );

    if (confirmado == true) {
      setState(() {
        _productos.clear();
        _productosValidados.clear();
        _codigoController.clear();
        _cantidadController.text = '1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Escaneo - ${widget.noteId}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.azul,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codigoController,
                            focusNode: _codigoFocusNode,
                            enabled: true,
                            readOnly: _isPdaMode,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Código',
                              labelStyle: TextStyle(
                                color: _isPdaMode
                                    ? AppColors.rojo.withOpacity(0.7)
                                    : Colors.grey.shade600,
                              ),
                              hintText: _isPdaMode
                                  ? 'Presiona el botón físico para escanear'
                                  : 'Escribe o escanea el código',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: _isPdaMode
                                    ? AppColors.rojo.withOpacity(0.5)
                                    : Colors.grey.shade400,
                                fontStyle: FontStyle.italic,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.azul,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              suffixIcon: IconButton(
                                onPressed: _handleToggleMode,
                                icon: Icon(
                                  _isPdaMode
                                      ? Icons.qr_code_scanner
                                      : Icons.keyboard,
                                  size: 20,
                                  color: _isPdaMode
                                      ? AppColors.rojo
                                      : AppColors.azul,
                                ),
                                tooltip: _isPdaMode
                                    ? 'Cambiar a modo manual'
                                    : 'Cambiar a modo escáner',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _cantidadController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Cantidad',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.azul,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              print('🔴🔴🔴 BOTÓN AGREGAR PRESIONADO 🔴🔴🔴');
                              if (!_isLoading) {
                                _handleLoad();
                              }
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradienteBoton,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Agregar',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.azul,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(11),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Código',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Cantidad',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(
                                '',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _productos.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay productos escaneados',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _productos.length,
                                itemBuilder: (context, index) {
                                  final producto = _productos[index];
                                  final bool validado =
                                      _productosValidados[producto.codigo] ??
                                      false;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade100,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            producto.codigo,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            producto.cantidad.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: validado
                                              ? const SizedBox.shrink() // ✅ No mostrar nada si está validado
                                              : const Icon(
                                                  Icons.cancel,
                                                  size: 18,
                                                  color: AppColors.rojo,
                                                ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: _productos.isNotEmpty ? _handleSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azul,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
