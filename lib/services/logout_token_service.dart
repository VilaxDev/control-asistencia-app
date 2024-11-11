import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:power/api.dart';

class LogoutTokenService {
  // Petición PUT para deshacer el token
  Future<String?> updateToken(int idUsuario, BuildContext context) async {
    var url = Uri.parse('${AppConfig.baseUrl}/update/token/usuario/$idUsuario');

    print("Haciendo petición PUT a: $url");

    var response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print("Respuesta recibida con código: ${response.statusCode}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Respuesta exitosa: $data");

      if (data['type'] == 'success') {
        return "Salida actualizada: ${data['message']}";
      } else {
        return "Error: ${data['message']}";
      }
    } else if (response.statusCode == 400) {
      var data = jsonDecode(response.body);
      print("Error con el código 400: $data");
      return "Error: ${data['message']}";
    } else {
      print("Error inesperado con código: ${response.statusCode}");
      return "Error al actualizar salida: ${response.statusCode}";
    }
  }
}
