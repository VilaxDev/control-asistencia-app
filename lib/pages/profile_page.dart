import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:power/pages/home_page.dart';
import 'package:power/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_info_model.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService =
      UserService(); // Servicio para manejar datos del usuario
  Future<UserInfoModel?>? _userInfoFuture;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _loadUserInfo();
  }

  Future<UserInfoModel?> _loadUserInfo() async {
    try {
      return await _userService.getUserInfo();
    } catch (e) {
      print("Error cargando información del usuario: $e");
      return null;
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.logout_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sesión Cerrada Correctamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print("Error durante el logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Mi Perfil",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red[400]),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<UserInfoModel?>(
        future: _userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text(
                    "Error al cargar el perfil",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[300],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final userInfo = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header con avatar
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            "${userInfo.user.nombre[0]}${userInfo.user.apellidos[0]}",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "${userInfo.user.nombre} ${userInfo.user.apellidos}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Chip(
                          label: Text(
                            "${userInfo.user.rol}",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.blue[50],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Información del usuario
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Información Personal",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.email,
                          title: "Correo Electrónico",
                          value: userInfo.user.email,
                        ),
                        SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.badge,
                          title: "ID de Colaborador",
                          value: userInfo.colaborador.id.toString(),
                        ),
                        SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.badge,
                          title: "Periodo",
                          value: userInfo.periodo.anio.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "No se encontró información de perfil",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
        },
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
          currentIndex: 1,
          selectedItemColor: Colors.blue[600],
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Actualizar el índice seleccionado
            });

            if (index == 0) {
              // Usamos PageRouteBuilder para controlar la animación de transición
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomePage(),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
