import 'dart:math';

import 'package:AsistePro/pages/login_page.dart';
import 'package:AsistePro/services/reset_password_service.dart';
import 'package:flutter/material.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _captchaController = TextEditingController();
  final _passwordController = TextEditingController();
  String _captchaCode = '';
  String _verifiedEmail = '';
  bool _isCaptchaVerified = false;
  bool _isEmailVerified = false;

  final ResetPasswordService _authService = ResetPasswordService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recuperación de Contraseña',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Espacio para imagen
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/icons/reset_password.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Email input
                if (!_isEmailVerified)
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.blue[400]!, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.red[400]!, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu correo electrónico';
                      }
                      return null;
                    },
                  ),

                // CAPTCHA section con la lógica original
                if (_isEmailVerified && !_isCaptchaVerified)
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Text(
                          'Tu código CAPTCHA es: $_captchaCode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _captchaController,
                        decoration: InputDecoration(
                          labelText: 'Código CAPTCHA',
                          prefixIcon: Icon(Icons.security_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.blue[400]!, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el código CAPTCHA';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                // Password input con la lógica original
                if (_isCaptchaVerified)
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.blue[400]!, width: 2),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nueva contraseña';
                      }
                      return null;
                    },
                  ),

                SizedBox(height: 20),

                // Botón con la lógica original
                Container(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isEmailVerified
                        ? _isCaptchaVerified
                            ? _resetPassword
                            : _verifyCaptcha
                        : _sendCaptcha,
                    child: Text(
                      _isEmailVerified
                          ? _isCaptchaVerified
                              ? 'Restablecer Contraseña'
                              : 'Verificar CAPTCHA'
                          : 'Iniciar Recuperación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendCaptcha() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      _authService.verifyEmail(email).then((result) {
        if (result['success']) {
          setState(() {
            _verifiedEmail = email;
            _isEmailVerified = true;
            _captchaCode = _generateCaptchaCode(); // Generar el código CAPTCHA
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el código CAPTCHA')),
        );
      });
    }
  }

  void _verifyCaptcha() {
    if (_formKey.currentState!.validate()) {
      final captchaInput = _captchaController.text;
      if (captchaInput == _captchaCode) {
        setState(() {
          _isCaptchaVerified = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Código CAPTCHA incorrecto')),
        );
      }
    }
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      final newPassword = _passwordController.text;
      _authService.updatePassword(_verifiedEmail, newPassword).then((result) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      result['message'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[400],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al restablecer la contraseña')),
        );
      });
    }
  }

  String _generateCaptchaCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }
}
