import 'package:flutter/material.dart';
import 'package:power/models/user_info_model.dart';
import 'package:power/pages/profile_page.dart';
import 'package:power/services/asistencia_service.dart';
import 'package:power/services/user_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _responseMessage = "";
  int? _colaboradorId;
  bool _isDiaLaboral = false; // Nueva variable para controlar si es día laboral
  List<String> _diasLaborales = []; // Para almacenar los días laborales

  final AsistenciaService _asistenciaService = AsistenciaService();
  final UserService _userService = UserService();

  // Obtener el día actual en español y en minúsculas
  String _getCurrentDay() {
    DateTime now = DateTime.now();
    // Convertir el día de la semana a español
    Map<int, String> diasSemana = {
      1: 'lunes',
      2: 'martes',
      3: 'miercoles',
      4: 'jueves',
      5: 'viernes',
      6: 'sábado',
      7: 'domingo',
    };
    return diasSemana[now.weekday] ?? '';
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // Cargar la información del usuario
  void loadUserInfo() async {
    UserInfoModel? userInfo = await _userService.getUserInfo();

    if (userInfo != null) {
      print("Usuario: ${userInfo.user.nombre}");
      print("Colaborador ID: ${userInfo.colaborador.id}");
      print("Dias Laborales: ${userInfo.horario.diasLaborales}");

      String diaActual = _getCurrentDay();
      print("Día actual: $diaActual");

      // Verificar si el día actual está en la lista de días laborales
      bool esDiaLaboral = userInfo.horario.diasLaborales.contains(diaActual);
      print("¿Es día laboral?: $esDiaLaboral");

      setState(() {
        _colaboradorId = userInfo.colaborador.id;
        _diasLaborales = userInfo.horario.diasLaborales;
        _isDiaLaboral = esDiaLaboral;
      });
    } else {
      print("No hay información de usuario guardada.");
    }
  }

  // Obtener la hora actual formateada como "HH:mm:ss"
  String _getCurrentTime() {
    DateTime now = DateTime.now();
    return DateFormat('HH:mm:ss').format(now);
  }

  // Obtener la fecha actual en formato "yyyy-MM-dd"
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  // Registrar la entrada
  void registerEntrada() async {
    if (_colaboradorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Error: Colaborador no encontrado en SharedPreferences.")));
      return;
    }

    String currentTime = _getCurrentTime();
    String currentDate = _getCurrentDate();

    String? result = await _asistenciaService.registerEntrada(
        _colaboradorId!, currentTime, currentDate, context);

    // Mostrar el mensaje del resultado
    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  // Actualizar la salida
  void updateSalida() async {
    String currentTime = _getCurrentTime();

    String? result =
        await _asistenciaService.updateSalida(currentTime, context);

    // Mostrar el mensaje del resultado
    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Inicio",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: 20, color: Colors.blue[800]),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: _isDiaLaboral ? _buildWorkdayView() : _buildNonWorkdayView(),
      ),
    );
  }

  Widget _buildWorkdayView() {
    return Column(
      children: [
        // Estado del día
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Día Laboral Activo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                "Bienvenido a la aplicación",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),

        // Botones de registro
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.login,
                title: "Registrar\nEntrada",
                color: Colors.green[400]!,
                onPressed: registerEntrada,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildActionButton(
                icon: Icons.logout,
                title: "Actualizar\nSalida",
                color: Colors.orange[400]!,
                onPressed: updateSalida,
              ),
            ),
          ],
        ),
        SizedBox(height: 25),

        // Mensaje de respuesta
        if (_responseMessage.isNotEmpty)
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _responseMessage,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNonWorkdayView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_off_outlined,
                  size: 60,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Hoy no es un día laboral",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Tus días laborales son:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _diasLaborales
                    .map((dia) => Chip(
                          label: Text(
                            dia,
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                          backgroundColor: Colors.blue[50],
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          padding: EdgeInsets.all(15),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
