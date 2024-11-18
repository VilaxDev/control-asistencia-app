import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:AsistePro/api.dart';

class JustificacionService {
  Future<void> justifyAttendance({
    required String colaboradorId,
    required String motivo,
    required String descripcion,
  }) async {
    final url = Uri.parse(
        '${AppConfig.baseUrl}/justificacion/asistencia/colaborador/$colaboradorId');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'motivo': motivo,
        'descripcion': descripcion,
      }),
    );

    // Verificar el código de estado de la respuesta
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa (status 200)
      final message = responseData['message'];
      final type = responseData['type'];

      if (type == 'success') {
        // Manejar el caso de éxito
        print('Éxito: $message');
      } else if (type == 'danger') {
        // Manejar el caso de error si el tipo es 'danger'
        print('Error: $message');
        throw message; // Lanza solo el mensaje, no una excepción genérica
      }
    } else if (response.statusCode == 404) {
      // Si la respuesta es 404 (no encontrado)
      final message = responseData['message'] ?? 'No encontrado';
      final type = responseData['type'] ?? 'danger';

      // Mostrar el mensaje de error correspondiente
      throw message; // Lanza solo el mensaje de error
    } else {
      // Si el código de estado es diferente de 200 y 404, manejar el error general
      final message = responseData['message'] ?? 'Error desconocido';
      throw message; // Lanza solo el mensaje
    }
  }
}
