import 'package:flutter/material.dart';
import 'package:sending/class/LocalStorage.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import 'scanning_screen.dart';
import 'store_selection_screen.dart';
import '../services/pedido_service.dart';
import '../services/auth_service.dart';
import '../services/escaneo_service.dart';
import '../models/pedido_response.dart';
import '../models/producto_escaneado.dart';
import '../widgets/sweet_alert_dialog.dart';

class OrdersListScreen extends StatefulWidget {
  final String usuario;
  final Tienda tienda;
  final String operationType;

  const OrdersListScreen({
    super.key,
    required this.usuario,
    required this.tienda,
    required this.operationType,
  });

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {

  final PedidoService _pedidoService = PedidoService();
  final AuthService _authService = AuthService();
  final EscaneoService _escaneoService = EscaneoService();

  String _searchTerm = '';
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;

  List<PedidoData> _pedidos = [];

  int _currentPage = 1;
  int _itemsPerPage = 20;
  int _totalPages = 1;
  int _totalItems = 0;

  List<PedidoData> get _filteredPedidos {
    if (_searchTerm.isEmpty) return _pedidos;
    return _pedidos
        .where(
          (pedido) =>
              pedido.id.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              pedido.fecha.contains(_searchTerm),
        )
        .toList();
  }

  List<PedidoData> get _paginatedPedidos {
    final filtered = _filteredPedidos;
    _totalItems = filtered.length;
    _totalPages = (_totalItems / _itemsPerPage).ceil();

    if (_currentPage > _totalPages && _totalPages > 0) {
      _currentPage = _totalPages;
    }
    if (_currentPage < 1) {
      _currentPage = 1;
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= _totalItems) {
      return [];
    }

    return filtered.sublist(
      startIndex,
      endIndex > _totalItems ? _totalItems : endIndex,
    );
  }

  String get _pageInfo {
    if (_totalItems == 0) return '0 de 0';
    final start = (_currentPage - 1) * _itemsPerPage + 1;
    final end = (_currentPage * _itemsPerPage) > _totalItems
        ? _totalItems
        : (_currentPage * _itemsPerPage);
    return '$start - $end de $_totalItems';
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    print('🔍 Cargando pedidos para tienda: ${widget.tienda.nombre}');

    final response = await _pedidoService.getPedidos(widget.tienda.nombre);

    print('📊 Respuesta success: ${response.success}');
    print('📊 Pedidos recibidos: ${response.pedidos.length}');

    setState(() {
      _isLoading = false;
      if (response.success) {
        _pedidos = response.pedidos;
        _currentPage = 1;
        print('✅ Pedidos cargados exitosamente: ${_pedidos.length}');
        if (_pedidos.isNotEmpty) {
          print(
            '📋 Primer pedido: ID=${_pedidos[0].id}, Fecha=${_pedidos[0].fecha}',
          );
        }
      } else {
        _errorMessage = response.message ?? 'Error al cargar pedidos';
        print('❌ Error: $_errorMessage');
      }
    });
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    await _cargarPedidos();
    setState(() => _isSyncing = false);
  }

  void _handleLogout() async {

    await _authService.logout();
    await LocalStorage.remove('usuario');
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StoreSelectionScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleNoteClick(String noteId) async {
    setState(() {
      _isSyncing = true;
    });

    print('📤 Procesando nota: $noteId');

    final response = await _escaneoService.procesarNota(
      filtro: noteId,
      usuario: widget.usuario,
      originDeposito: '',
      tienda: widget.tienda.nombre,
    );

    setState(() {
      _isSyncing = false;
    });

    // Caso 1: Éxito - nota nueva con productos
    if (response.success && mounted) {
      print('✅ Nota procesada exitosamente');
      print('📦 Productos: ${response.productos.length}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanningScreen(
            noteId: noteId,
            tienda: widget.tienda,
            usuario: widget.usuario,
            productosNota: response.productos,
          ),
        ),
      );
    }
    // Caso 2: Nota duplicada con productos precargados
    else if (response.productosPrecargadosList.isNotEmpty && mounted) {
      print('⚠️ Nota duplicada - Productos precargados: ${response.productosPrecargadosList.length}');

      final productosPrecargados = response.productosPrecargadosList.map((p) =>
          ProductoEscaneado(codigo: p.codigo, cantidad: p.cantidad)).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanningScreen(
            noteId: noteId,
            tienda: widget.tienda,
            usuario: widget.usuario,
            productosNota: response.productos,
            productosPrecargados: productosPrecargados,
          ),
        ),
      );
    }
    // Caso 3: Error
    else {
      final errorMsg = response.message ?? 'Error al cargar la nota';
      print('❌ Error: $errorMsg');

      SweetAlertDialog.showError(
        context: context,
        title: 'Error',
        message: errorMsg,
        buttonText: 'Entendido',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  @override
  Widget build(BuildContext context) {
    final paginatedPedidos = _paginatedPedidos;
    final hasItems = paginatedPedidos.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pedidos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azul,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.tienda.nombre,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _handleSync,
                            icon: Icon(
                              Icons.sync,
                              color: AppColors.azul,
                              size: 22,
                            ),
                          ),
                          IconButton(
                            onPressed: _handleLogout,
                            icon: Icon(
                              Icons.logout,
                              color: AppColors.rojo,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Buscador
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                        _currentPage = 1;
                      });
                    },
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Buscar por N° nota o fecha...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.azul,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                // Tabla de pedidos
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.azul,
                              ),
                            )
                          : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.rojo,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _cargarPedidos,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.azul,
                                    ),
                                    child: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            )
                          : _pedidos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No hay pedidos disponibles',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.azul,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(7),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'N° Nota',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Fecha',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: paginatedPedidos.length,
                                    itemBuilder: (context, index) {
                                      final pedido = paginatedPedidos[index];
                                      return InkWell(
                                        onTap: () =>
                                            _handleNoteClick(pedido.id),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  pedido.id,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.azul,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  pedido.fecha,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (paginatedPedidos.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: _currentPage > 1
                                              ? _goToPreviousPage
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _currentPage > 1
                                                  ? AppColors.azul.withOpacity(
                                                      0.1,
                                                    )
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.chevron_left,
                                                  size: 18,
                                                  color: _currentPage > 1
                                                      ? AppColors.azul
                                                      : Colors.grey.shade400,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Anterior',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _currentPage > 1
                                                        ? AppColors.azul
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _pageInfo,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.azul,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _currentPage < _totalPages
                                              ? _goToNextPage
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _currentPage < _totalPages
                                                  ? AppColors.azul.withOpacity(
                                                      0.1,
                                                    )
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Siguiente',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        _currentPage <
                                                            _totalPages
                                                        ? AppColors.azul
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.chevron_right,
                                                  size: 18,
                                                  color:
                                                      _currentPage < _totalPages
                                                      ? AppColors.azul
                                                      : Colors.grey.shade400,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSyncing)
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