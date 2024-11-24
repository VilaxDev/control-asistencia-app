import 'package:AsistePro/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordService with ChangeNotifier {
  Future<Map<String, dynamic>> verifyEmail(String email) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/verificar/email'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'message': data['message']};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['error']};
    }
  }

  Future<Map<String, dynamic>> updatePassword(
      String email, String newPassword) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/password/update'),
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'message': data['message']};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['error']};
    }
  }
}
