import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:power/api.dart';
import 'package:power/models/user_info_model.dart';
import 'package:power/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:power/pages/login_page.dart';
import 'package:power/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int? colaboradorId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void loadUserInfo() async {
    try {
      UserInfoModel? userInfo = await UserService().getUserInfo();
      if (userInfo != null) {
        setState(() {
          colaboradorId = userInfo.colaborador.id;
        });
        await updateColaboradorData();
      } else {
        navigateToLogin();
      }
    } catch (e) {
      print("Error loading user info: $e");
      navigateToLogin();
    }
  }

  Future<void> updateColaboradorData() async {
    if (colaboradorId == null) {
      print("⚠️ No colaborador ID available");
      navigateToLogin();
      return;
    }

    print("📍 Iniciando actualización para colaborador ID: $colaboradorId");

    try {
      var url = Uri.parse(
          '${AppConfig.baseUrl}/datos/update/colaborador/$colaboradorId');
      print("🌐 URL de petición: $url");

      var response =
          await http.post(url, headers: {'Content-Type': 'application/json'});
      print("📢 Status code respuesta: ${response.statusCode}");
      print("📄 Respuesta raw: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("🔄 Datos decodificados: $data");

        if (data['message'] == "Datos actualizados correctamente") {
          print("✅ Mensaje de éxito recibido");

          UserInfoModel userInfo = UserInfoModel.fromJson(data);
          print("👤 Usuario parseado: ${userInfo.toString()}");

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userInfo', jsonEncode(userInfo.toJson()));

          // Verificar que se guardó correctamente
          String? savedData = prefs.getString('userInfo');
          print("💾 Datos guardados en SharedPreferences: $savedData");

          if (savedData != null) {
            print("✅ Datos guardados exitosamente");
          } else {
            print("⚠️ Error: Los datos no se guardaron correctamente");
          }

          navigateToHome();
        } else {
          print("❌ Error: Mensaje de actualización incorrecto");
          showError("Error al actualizar datos");
        }
      } else {
        print("❌ Error: Status code inválido ${response.statusCode}");
        showError("Error de servidor");
      }
    } catch (e) {
      print("❌ Error en actualización: $e");
      print("📍 Stack trace: ${StackTrace.current}");
      showError("Error de conexión");
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLogin = prefs.getBool('isLogin') ?? false;
      print('IsLogin: $isLogin');

      if (isLogin) {
        loadUserInfo();
      } else {
        navigateToLogin();
      }
    } catch (e) {
      print("Error checking login status: $e");
      navigateToLogin();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading ? CircularProgressIndicator() : Container(),
      ),
    );
  }
}
