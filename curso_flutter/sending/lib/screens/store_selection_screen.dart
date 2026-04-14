import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../models/tienda.dart';
import 'login_screen.dart';

class StoreSelectionScreen extends StatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen>
    with SingleTickerProviderStateMixin {
  final List<Tienda> tiendas = [
    Tienda(id: 1, nombre: "Tienda Central - Lima"),
    Tienda(id: 2, nombre: "Tienda Norte - Trujillo"),
    Tienda(id: 3, nombre: "Tienda Sur - Arequipa"),
    Tienda(id: 4, nombre: "Tienda Este - Huancayo"),
    Tienda(id: 5, nombre: "Tienda Oeste - Chiclayo"),
    Tienda(id: 6, nombre: "Tienda Costa Verde"),
    Tienda(id: 7, nombre: "Tienda San Isidro"),
    Tienda(id: 8, nombre: "Tienda Miraflores"),
    Tienda(id: 9, nombre: "Tienda Surco"),
    Tienda(id: 10, nombre: "Tienda La Molina"),
    Tienda(id: 11, nombre: "Tienda Barranco"),
    Tienda(id: 12, nombre: "Tienda Jesús María"),
    Tienda(id: 13, nombre: "Tienda Pueblo Libre"),
    Tienda(id: 14, nombre: "Tienda Lince"),
    Tienda(id: 15, nombre: "Tienda Magdalena"),
  ];

  String _searchTerm = '';
  Tienda? _selectedStore;
  late AnimationController _animationController;

  List<Tienda> get _filteredStores {
    if (_searchTerm.isEmpty) return tiendas;
    return tiendas
        .where((store) =>
            store.nombre.toLowerCase().contains(_searchTerm.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          decoration: BoxDecoration(
            gradient: AppColors.gradienteFondo,
          ),
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
                    // Header con animación
                    FadeTransition(
                      opacity: _animationController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        )),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cendin',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sistema de gestión logística avanzada',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Buscador mejorado
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: FadeTransition(
                        opacity: _animationController,
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
                              prefixIcon: Icon(Icons.search, color: AppColors.azul),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Lista de tiendas mejorada
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: FadeTransition(
                          opacity: _animationController,
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
                              child: _filteredStores.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                        final isSelected = _selectedStore?.id == store.id;
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
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
                                                    ? Colors.white.withOpacity(0.2)
                                                    : AppColors.azul.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
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
                                              borderRadius: BorderRadius.circular(12),
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
                    ),
                    // Botón Continuar mejorado
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _selectedStore != null
                                  ? _handleContinue
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.azul,
                                disabledBackgroundColor: Colors.grey.withOpacity(0.4),
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