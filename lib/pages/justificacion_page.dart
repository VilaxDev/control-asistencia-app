import 'package:flutter/material.dart';
import 'package:AsistePro/models/user_info_model.dart';
import 'package:AsistePro/services/justificacion_service.dart';
import 'package:AsistePro/services/user_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JustificacionPage extends StatefulWidget {
  const JustificacionPage({super.key});

  @override
  State<JustificacionPage> createState() => _JustificacionPageState();
}

class _JustificacionPageState extends State<JustificacionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedReason;
  int? _colaboradorId;
  final UserService _userService = UserService();

  final List<String> _reasons = [
    'Enfermedad',
    'Permiso Personal',
    'Falla de Transporte',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // Cargar la información del usuario
  void loadUserInfo() async {
    UserInfoModel? userInfo = await _userService.getUserInfo();

    if (userInfo != null) {
      print("Colaborador ID: ${userInfo.colaborador.id}");
      setState(() {
        _colaboradorId = userInfo.colaborador.id;
      });
    } else {
      print("No hay información de usuario guardada.");
    }
  }

// Función para mostrar el SnackBar con icono dependiendo del tipo
  void _showSnackBar(String message, String type) {
    Icon icon;
    Color backgroundColor;

    // Decidir el icono y color según el tipo
    if (type == 'success') {
      icon = const Icon(Icons.check_circle, color: Colors.white);
      backgroundColor = Colors.green;
    } else {
      icon = const Icon(Icons.error, color: Colors.white);
      backgroundColor = Colors.red;
    }

    // Mostrar el SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            icon,
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_colaboradorId == null) {
        _showSnackBar('No se ha cargado el ID del colaborador', 'danger');
        return;
      }

      final description = _descriptionController.text;
      final justificacionService = JustificacionService(); // Create an instance

      try {
        // Intentar justificar la asistencia
        await justificacionService.justifyAttendance(
          colaboradorId: _colaboradorId.toString(),
          motivo: _selectedReason!,
          descripcion: description,
        );

        // Si es exitoso
        _showSnackBar('Justificación enviada con éxito', 'success');
        _descriptionController.clear();
        setState(() {
          _selectedReason = null;
        });
      } catch (e) {
        // Si ocurre un error
        _showSnackBar(e.toString(), 'danger');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[50]!,
                    Colors.blue[100]!,
                  ],
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Justificar\nAsistencia',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              )
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.notifications_outlined,
                                color: Colors.blue[800]),
                            onPressed: () {
                              // Notification logic
                            },
                          ),
                        )
                      ],
                    ).animate().slideX(duration: 400.ms, begin: -0.1),

                    SizedBox(height: 30),

                    // Form Card
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reason Dropdown
                            Text(
                              'Motivo de Justificación',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            DropdownButtonFormField(
                              value: _selectedReason,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.blue[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                              ),
                              items: _reasons
                                  .map((reason) => DropdownMenuItem(
                                        value: reason,
                                        child: Text(reason),
                                      ))
                                  .toList(),
                              validator: (value) =>
                                  value == null ? 'Seleccione un motivo' : null,
                              onChanged: (value) {
                                setState(() {
                                  _selectedReason = value as String?;
                                });
                              },
                            ),

                            SizedBox(height: 20),

                            // Description Field
                            Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.blue[50],
                                hintText: 'Escriba su justificación...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.all(15),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Ingrese una descripción'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),

                    SizedBox(height: 30),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Enviar Justificación',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ).animate().slideY(duration: 400.ms, begin: 0.2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
