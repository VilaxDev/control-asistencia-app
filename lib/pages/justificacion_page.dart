import 'package:flutter/material.dart';
import 'package:AsistePro/models/user_info_model.dart';
import 'package:AsistePro/services/justificacion_service.dart';
import 'package:AsistePro/services/user_service.dart';

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
      appBar: AppBar(
        title: const Text('Justificar Asistencia'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motivo de la Justificación',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField(
                  value: _selectedReason,
                  items: _reasons
                      .map((reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Motivo',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.blue[600]!, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.blue[600]!, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.blue[600]!, width: 2.5),
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Seleccione un motivo' : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Ingrese una descripción detallada',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.blue[600]!, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.blue[600]!, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.blue[600]!, width: 2.5),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese una descripción'
                      : null,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Enviar Justificación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
}
