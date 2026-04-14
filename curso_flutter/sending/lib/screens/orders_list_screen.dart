import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import '../models/nota_pedido.dart';
import 'scanning_screen.dart';

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
  String _searchTerm = '';
  bool _isSyncing = false;
  List<NotaPedido> _orders = mockOrders;
  
  int _currentPage = 1;
  int _itemsPerPage = 20;
  int _totalPages = 1;
  int _totalItems = 0;

  List<NotaPedido> get _filteredOrders {
    if (_searchTerm.isEmpty) return _orders;
    return _orders.where((order) =>
        order.id.toLowerCase().contains(_searchTerm.toLowerCase()) ||
        order.fecha.contains(_searchTerm)).toList();
  }

  List<NotaPedido> get _paginatedOrders {
    final filtered = _filteredOrders;
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

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSyncing = false);
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _handleNoteClick(String noteId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner, size: 48, color: AppColors.azul),
              const SizedBox(height: 16),
              const Text(
                'Empezar a escanear',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azul),
              ),
              const SizedBox(height: 8),
              Text(
                'Haz click para comenzar el conteo de productos para esta nota de entrega',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScanningScreen(
                              noteId: noteId,
                              tienda: widget.tienda,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azul,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Comenzar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paginatedOrders = _paginatedOrders;
    final hasItems = paginatedOrders.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(  // Scroll general de la pantalla
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
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.azul),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.tienda.nombre,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _handleSync,
                              icon: Icon(Icons.sync, color: AppColors.azul, size: 22),
                            ),
                            IconButton(
                              onPressed: _handleLogout,
                              icon: Icon(Icons.logout, color: AppColors.rojo, size: 22),
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar por N° nota o fecha...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
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
                          borderSide: const BorderSide(color: AppColors.azul, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  // Tabla - SIN altura fija
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Encabezado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.azul,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(child: Text('N° Nota', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                                Expanded(child: Text('Fecha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                              ],
                            ),
                          ),
                          // Lista de pedidos
                          !hasItems
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text(
                                        _searchTerm.isEmpty
                                            ? 'No hay pedidos disponibles'
                                            : 'No se encontraron resultados',
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: paginatedOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = paginatedOrders[index];
                                    return InkWell(
                                      onTap: () => _handleNoteClick(order.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.grey.shade200),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                order.id,
                                                style: const TextStyle(fontSize: 13, color: AppColors.azul),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                order.fecha,
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          // Paginador
                          if (hasItems)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: _currentPage > 1 ? _goToPreviousPage : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _currentPage > 1 ? AppColors.azul.withOpacity(0.1) : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.chevron_left,
                                            size: 18,
                                            color: _currentPage > 1 ? AppColors.azul : Colors.grey.shade400,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Anterior',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _currentPage > 1 ? AppColors.azul : Colors.grey.shade400,
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
                                    onTap: _currentPage < _totalPages ? _goToNextPage : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _currentPage < _totalPages ? AppColors.azul.withOpacity(0.1) : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Siguiente',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _currentPage < _totalPages ? AppColors.azul : Colors.grey.shade400,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 18,
                                            color: _currentPage < _totalPages ? AppColors.azul : Colors.grey.shade400,
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
                  const SizedBox(height: 12), // Espacio final
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isSyncing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}