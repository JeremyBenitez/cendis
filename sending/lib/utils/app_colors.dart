import 'package:flutter/material.dart';

class AppColors {
  static const Color rojo = Color(0xFFD51F2A);
  static const Color azul = Color(0xFF28336C);
  static const Color azulClaro = Color(0xFF3D4A8F);
  static const Color grisFondo = Color(0xFFF5F5F5);
  
  static LinearGradient gradienteFondo = LinearGradient(
    colors: [azul, azulClaro, rojo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient gradienteBoton = LinearGradient(
    colors: [rojo, azul],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static LinearGradient gradienteBotonInvertido = LinearGradient(
    colors: [azul, rojo],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}