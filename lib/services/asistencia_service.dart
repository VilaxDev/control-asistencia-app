import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:AsistePro/api.dart';

class AsistenciaService {
  // Petición POST para registrar la hora de entrada
  Future<String?> registerEntrada(int colaboradorId, String currentTime,
      String currentDate, BuildContext context) async {
    var url = Uri.parse('${AppConfig.baseUrl}/asistencias/register');
    var response = await http.post(
      url,
      body: jsonEncode({
        'colaborador_id': colaboradorId,
        'hora_entrada': currentTime,
        'fecha': currentDate,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['type'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_asistencia', data['id_asistencia']);

        return "Entrada registrada: ${data['message']}";
      } else {
        return "Error: ${data['message']}";
      }
    } else if (response.statusCode == 400) {
      var data = jsonDecode(response.body);
      return "Error: ${data['message']}";
    } else {
      return "Error al registrar entrada: ${response.statusCode}";
    }
  }

  // Petición PUT para actualizar la hora de salida
  Future<String?> updateSalida(String currentTime, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idAsistencia = prefs.getInt('id_asistencia');

    if (idAsistencia == null) {
      return "Error: id_asistencia no encontrado en SharedPreferences.";
    }

    var url =
        Uri.parse('${AppConfig.baseUrl}/asistencias/update/$idAsistencia');
    var response = await http.put(
      url,
      body: jsonEncode({
        'hora_salida': currentTime,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['type'] == 'success') {
        await prefs.remove('id_asistencia');
        return "Salida actualizada: ${data['message']}";
      } else {
        return "Error: ${data['message']}";
      }
    } else if (response.statusCode == 400) {
      var data = jsonDecode(response.body);
      return "Error: ${data['message']}";
    } else {
      return "Error al actualizar salida: ${response.statusCode}";
    }
  }
}
