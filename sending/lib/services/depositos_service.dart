import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sending/class/RespuestaApiHelper.dart';
import 'package:sending/config/api_config.dart';

class DepositosService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<dynamic> manejarErroresHttp(Object e) async {
    if (e is SocketException) {
      print("SocketException: $e");
      return await RespuestaApiHelper.procesarRespuesta({
        "status": "errorCatch",
        "mensaje":
            "Sin conexión a internet. Verifica tu red e inténtalo nuevamente.",
      });
    }

    if (e is TimeoutException) {
      print("TimeoutException: $e");
      return await RespuestaApiHelper.procesarRespuesta({
        "status": "errorCatch",
        "mensaje":
            "La solicitud tardó demasiado. Inténtalo nuevamente en unos momentos.",
      });
    }

    if (e is FormatException) {
      print("FormatException: $e");
      return await RespuestaApiHelper.procesarRespuesta({
        "status": "errorCatch",
        "mensaje":
            "Ocurrió un error inesperado al procesar la respuesta del servidor.",
      });
    }

    print("Error general: $e");
    return await RespuestaApiHelper.procesarRespuesta({
      "status": "errorCatch",
      "mensaje":
          "No se pudo completar la solicitud. Inténtalo nuevamente más tarde.",
    });
  }

  Future<dynamic> respuestaError(http.Response response) async {
    return await RespuestaApiHelper.procesarRespuesta({
      "status": "error",
      "statusCode": response.statusCode,
      "mensaje": "⚠️ Servidor no disponible. Intenta más tarde.",
    });
  }

  Future<dynamic> getDepositos() async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.depositos}');
      final response = await http.get(url).timeout(Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return await RespuestaApiHelper.procesarRespuesta({
            "status": "success",
            "data": jsonDecode(response.body),
            "mensaje": "Depósitos obtenidos exitosamente",
          });
        } else {
          return await RespuestaApiHelper.procesarRespuesta({
            "status": "success",
            "data": [],
            "mensaje": "No se encontraron depósitos",
          });
        }
      }

      return await respuestaError(response);
    } catch (e) {
      return await manejarErroresHttp(e);
    }
  }
}
