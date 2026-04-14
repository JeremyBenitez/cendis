import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import '../models/producto_escaneado.dart';
import 'verification_screen.dart';

class ScanningScreen extends StatefulWidget {
  final String noteId;
  final Tienda tienda;

  const ScanningScreen({super.key, required this.noteId, required this.tienda});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  bool _isPdaMode = false;
  List<ProductoEscaneado> _productos = [];

  int get totalProductos => _productos.length;

  void _handleToggleMode() {
    setState(() {
      _isPdaMode = !_isPdaMode;
      if (_isPdaMode) {
        _codigoController.clear();
      }
    });
  }

  void _handleLoad() {
    final String codigo = _codigoController.text.trim();
    final int? cantidad = int.tryParse(_cantidadController.text.trim());

    if (codigo.isNotEmpty && cantidad != null && cantidad > 0) {
      setState(() {
        final int existingIndex = _productos.indexWhere(
          (p) => p.codigo == codigo,
        );
        if (existingIndex >= 0) {
          _productos[existingIndex].cantidad += cantidad;
        } else {
          _productos.add(ProductoEscaneado(codigo: codigo, cantidad: cantidad));
        }
        _codigoController.clear();
        _cantidadController.text = '1';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese un código y cantidad válida'),
          backgroundColor: AppColors.rojo,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleRemove(String codigo) {
    setState(() {
      _productos.removeWhere((p) => p.codigo == codigo);
    });
  }

  void _handleSave() {
    if (_productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos escaneados para guardar'),
          backgroundColor: AppColors.rojo,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Simulación de base de datos - Productos esperados por nota
    final Map<String, int> productosEsperados = {
      '123122131': 10,
      '2132132132': 5,
      'ABC123': 3,
      'XYZ789': 7,
      'DEF456': 4,
      'GHI789': 6,
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          noteId: widget.noteId,
          tienda: widget.tienda,
          productosEscaneados: _productos,
          productosEsperados: productosEsperados,
        ),
      ),
    );
  }

  void _handleClear() {
    if (_productos.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Limpiar todo'),
        content: const Text(
          '¿Está seguro de limpiar todos los productos escaneados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _productos.clear();
                _codigoController.clear();
                _cantidadController.text = '1';
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rojo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cantidadController.text = '1';
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Escaneo - ${widget.noteId}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.azul,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Tarjeta de escaneo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Campo Código
                        TextField(
                          controller: _codigoController,
                          enabled: !_isPdaMode,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Código',
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            hintText: _isPdaMode
                                ? 'Esperando escaneo PDA...'
                                : 'Ingrese código',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
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
                            isDense: true,
                            suffixIcon: IconButton(
                              onPressed: _handleToggleMode,
                              icon: Icon(
                                _isPdaMode
                                    ? Icons.qr_code_scanner
                                    : Icons.keyboard,
                                size: 18,
                                color: _isPdaMode
                                    ? AppColors.rojo
                                    : AppColors.azul,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Fila Cantidad + Botón
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
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
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
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: _handleLoad,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.gradienteBoton,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Agregar',
                                        style: TextStyle(
                                          fontSize: 13,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tabla de productos escaneados
                  SizedBox(
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // Encabezado
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.azul,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(9),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Código',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Cantidad',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    'Acción',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Lista de productos
                          Expanded(
                            child: _productos.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay productos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _productos.length,
                                    itemBuilder: (context, index) {
                                      final producto = _productos[index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                              width: 40,
                                              child: IconButton(
                                                onPressed: () => _handleRemove(
                                                  producto.codigo,
                                                ),
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  size: 16,
                                                  color: AppColors.rojo,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
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
                  const SizedBox(height: 20),
                  SafeArea(
                    top: false,
                    bottom: true,
                    minimum: const EdgeInsets.only(bottom: 32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _productos.isNotEmpty
                                  ? _handleClear
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.rojo,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Limpiar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _productos.isNotEmpty
                                  ? _handleSave
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.azul,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}