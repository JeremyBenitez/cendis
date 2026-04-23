import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sending/class/LocalStorage.dart';
import 'package:sending/screens/operation_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import 'login_screen.dart';
import '../services/tienda_service.dart';
import '../widgets/error_connection_widget.dart';

class StoreSelectionScreen extends StatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen>
    with SingleTickerProviderStateMixin {
  final TiendaService _tiendaService = TiendaService();
  List<Tienda> tiendas = [];
  String _searchTerm = '';
  Tienda? _selectedStore;
  late AnimationController _animationController;
  bool _isLoading = true;
  String? _errorMessage;

  List<Tienda> get _filteredStores {
    if (_searchTerm.isEmpty) return tiendas;
    return tiendas
        .where(
          (store) =>
              store.nombre.toLowerCase().contains(_searchTerm.toLowerCase()),
        )
        .toList();
  }

  Future<void> comprobarSesion() async {
    await _cargarTiendas();

    if (await LocalStorage.getJson('usuario') != null) {
      Map<String, dynamic>? usuario = await LocalStorage.getJson('usuario');

      for (var tienda in tiendas) {
        if (tienda.localidad == usuario!['localidad']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OperationSelectionScreen(
                usuario: usuario["Usuario"],
                tienda: Tienda(
                  id: tienda.id,
                  nombre: tienda.nombre,
                  localidad: tienda.localidad,
                ),
              ),
            ),
          );
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    comprobarSesion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarTiendas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _tiendaService.getTiendas();

      setState(() {
        _isLoading = false;
        if (response.success) {
          tiendas = response.tiendas.map((t) => t.toTienda()).toList();
        } else {
          // Si el mensaje del servicio contiene texto técnico, lo reemplazamos
          final msg = response.message ?? 'Error al cargar tiendas';
          if (msg.contains('Connection') ||
              msg.contains('connection') ||
              msg.contains('failed')) {
            _errorMessage = 'Verifica tu conexión a internet.';
          } else {
            _errorMessage = msg;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Verifica tu conexión a internet.'; // ✅ Forzado
      });
    }
  }

  Future<void> _handleContinue() async {
    if (_selectedStore != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedStore', _selectedStore!.toJson().toString());
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(tiendaSeleccionada: _selectedStore!),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.gradienteFondo),
          child: Stack(
            children: [
              // Burbujas decorativas
              Positioned(
                top: 60,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                right: 30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Contenido principal
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cendis',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Centro de distribucion',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Buscador
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchTerm = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar tienda...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.azul,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Lista de tiendas
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: CircularProgressIndicator(
                                        color: AppColors.azul,
                                      ),
                                    ),
                                  )
                                : _errorMessage != null
                                ? ErrorConnectionWidget(
                                    onRetry: _cargarTiendas,
                                    message: _errorMessage,
                                  )
                                : _filteredStores.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.store_outlined,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No se encontraron tiendas',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _filteredStores.length,
                                    itemBuilder: (context, index) {
                                      final store = _filteredStores[index];
                                      final isSelected =
                                          _selectedStore?.id == store.id;
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: isSelected
                                              ? AppColors.azul
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : Colors.grey.shade200,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.2,
                                                    )
                                                  : AppColors.azul.withOpacity(
                                                      0.1,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.store,
                                              size: 20,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.azul,
                                            ),
                                          ),
                                          title: Text(
                                            store.nombre,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade800,
                                            ),
                                          ),
                                          trailing: isSelected
                                              ? Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: AppColors.azul,
                                                  ),
                                                )
                                              : null,
                                          onTap: () {
                                            setState(() {
                                              _selectedStore = store;
                                            });
                                            HapticFeedback.lightImpact();
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          dense: false,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Botón Continuar
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _selectedStore != null
                              ? _handleContinue
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.azul,
                            disabledBackgroundColor: Colors.grey.withOpacity(
                              0.4,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
