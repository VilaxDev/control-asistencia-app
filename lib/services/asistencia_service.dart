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

    // Imprimir la URL y los parámetros
    print('URL: $url');
    print('Parametros enviados:');
    print('colaborador_id: $colaboradorId');
    print('hora_entrada: $currentTime');
    print('fecha: $currentDate');

    var response = await http.post(
      url,
      body: jsonEncode({
        'colaborador_id': colaboradorId,
        'hora_entrada': currentTime,
        'fecha': currentDate,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    // Verificar si la respuesta fue exitosa
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['type'] == 'success') {
        // Guardar el ID de asistencia en SharedPreferences y verificar
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_asistencia', data['id_asistencia']);

        // Imprimir si se guardó correctamente el ID de asistencia
        print('ID de asistencia guardado: ${data['id_asistencia']}');

        return "Entrada registrada: ${data['message']}";
      } else {
        return "${data['message']}";
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
    // Obtener el ID de asistencia desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idAsistencia = prefs.getInt('id_asistencia');

    // Verificar si el id_asistencia existe en SharedPreferences
    if (idAsistencia == null) {
      return "Error: id_asistencia no encontrado en SharedPreferences.";
    }

    // Imprimir la URL y los parámetros enviados
    var url =
        Uri.parse('${AppConfig.baseUrl}/asistencias/update/$idAsistencia');
    print('URL: $url');
    print('Parámetros enviados:');
    print('hora_salida: $currentTime');

    // Realizar la solicitud PUT para actualizar la hora de salida
    var response = await http.put(
      url,
      body: jsonEncode({
        'hora_salida': currentTime,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    // Verificar si la respuesta es exitosa
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['type'] == 'success') {
        // Eliminar el ID de asistencia de SharedPreferences y verificar
        await prefs.remove('id_asistencia');

        // Imprimir confirmación de eliminación del ID de asistencia
        print('ID de asistencia eliminado de SharedPreferences.');

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
