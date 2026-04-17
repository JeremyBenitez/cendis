class RespuestaApiHelper {

  static Future<Map<String, dynamic>> procesarRespuesta(Map<String, dynamic> response) async {
    
    if (response["status"] == "success") {

      return {
        "status": true,
        "mensaje": response["mensaje"] ?? "Operación exitosa",
        "data": response["data"],
      };

    }

    if (response["status"] == "error") {
      

      return {
        "status": false,
        "statusCode": response["statusCode"],
        "mensaje": response["mensaje"] ?? "Ocurrió un error en la solicitud",
        "data": null,
      };

    }

    if (response["status"] == "errorCatch") {

      return {
        "status": false,
        "mensaje": response["mensaje"] ?? "Ocurrió un error inesperado",
        "data": null,
      };

    }

    /*if (response["status"] == "unauthorized") {

      await LocalStorage.remove("dataToken");
      await LocalStorage.remove("dataUsuario");

      return {
        "status": false,
        "tokenExpirado": true,
        "mensaje": (response["mensaje"] ?? "Sesión expirada").toString(),
        "data": null,
      };
    }*/

    return {
      "status": false,
      "mensaje": "Respuesta no reconocida",
      "data": null,
    };
    
  }
}