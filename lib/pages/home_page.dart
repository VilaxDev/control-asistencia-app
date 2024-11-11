import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool _isDiaEvento = false;
  List<String> _diasLaborales = []; // Para almacenar los días laborales
  List<Evento> _eventosHoy = [];
  int _selectedIndex = 0;

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
      6: 'sabado',
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
      print("Periodo Año:  ${userInfo.periodo.anio}");
      print("Fecha Inicio:  ${userInfo.periodo.fechaInicio}");
      print("Fecha fin:  ${userInfo.periodo.fechaFin}");
      print("Eventos:  ${userInfo.eventos}");

      String diaActual = _getCurrentDay();
      print("Día actual: $diaActual");

      // Verificar si el día actual está en la lista de días laborales
      bool esDiaLaboral = userInfo.horario.diasLaborales.contains(diaActual);
      print("¿Es día laboral?: $esDiaLaboral");

      // Verificar si hay eventos para la fecha actual
      DateTime now = DateTime.now();
      List<Evento> eventosHoy = userInfo.eventos.where((evento) {
        return evento.fecha.year == now.year &&
            evento.fecha.month == now.month &&
            evento.fecha.day == now.day;
      }).toList();

      setState(() {
        _colaboradorId = userInfo.colaborador.id;
        _diasLaborales = userInfo.horario.diasLaborales;
        _isDiaLaboral = esDiaLaboral;
        _isDiaEvento = eventosHoy.isNotEmpty;
        _eventosHoy = eventosHoy;
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
      showErrorSnackBar(
          "Error: Colaborador no encontrado en SharedPreferences.");
      return;
    }

    String currentTime = _getCurrentTime();
    String currentDate = _getCurrentDate();

    String? result = await _asistenciaService.registerEntrada(
        _colaboradorId!, currentTime, currentDate, context);

    if (result != null) {
      showRegisteredEntradaSnackBar(result);
    }
  }

  void showRegisteredEntradaSnackBar(String message) {
    // Verificar si el mensaje es un error o éxito
    bool isError = message.startsWith("Error:");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.only(bottom: 15.0, left: 16.0, right: 16.0),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.only(bottom: 15.0, left: 16.0, right: 16.0),
      ),
    );
  }

  // Actualizar la salida
  void updateSalida() async {
    String currentTime = _getCurrentTime();

    String? result =
        await _asistenciaService.updateSalida(currentTime, context);

    if (result != null) {
      showUpdatedSalidaSnackBar(result);
    }
  }

  void showUpdatedSalidaSnackBar(String message) {
    // Verificar si el mensaje es un error
    bool isError = message.startsWith("Error:");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.only(bottom: 15.0, left: 16.0, right: 16.0),
      ),
    );
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
        automaticallyImplyLeading: false,
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
        child: _isDiaEvento
            ? _buildEventView()
            : (_isDiaLaboral ? _buildWorkdayView() : _buildNonWorkdayView()),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0 ? Colors.blue[600]! : Colors.grey[400]!,
                  // Cambiar color según selección
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  'assets/images/icons/home.svg', // Ruta de tu archivo SVG
                  height: 24, // Ajusta el tamaño del ícono
                  width: 24,
                ),
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1 ? Colors.blue[600]! : Colors.grey[400]!,
                  // Cambiar color según selección
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  'assets/images/icons/user.svg', // Ruta de tu archivo SVG
                  height: 24, // Ajusta el tamaño del ícono
                  width: 24,
                ),
              ),
              label: 'Perfil',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.blue[600],
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Actualizar el índice seleccionado
            });

            if (index == 1) {
              // Usamos PageRouteBuilder para controlar la animación de transición
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProfilePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var opacity =
                        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut, // Curva suave para la transición
                    ));

                    // Aplicamos la animación de desvanecimiento
                    return FadeTransition(opacity: opacity, child: child);
                  },
                ),
              );
            }
            // Puedes agregar más navegación para los otros índices cuando
            // tengas las otras páginas listas
          },
        ),
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

  Widget _buildEventView() {
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
                  color: Colors.amber[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event,
                  size: 60,
                  color: Colors.amber[700],
                ),
              ),
              SizedBox(height: 25),
              Text(
                "¡Hoy es un día de evento!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: _eventosHoy
                    .map((evento) => Container(
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                evento.descripcion,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                DateFormat('dd/MM/yyyy').format(evento.fecha),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
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
