import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:AsistePro/models/user_info_model.dart';

class UserService {
  // Obtener información del usuario desde SharedPreferences
  Future<UserInfoModel?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoString = prefs.getString('userInfo');

    if (userInfoString != null) {
      Map<String, dynamic> userInfoMap = jsonDecode(userInfoString);
      return UserInfoModel.fromJson(userInfoMap);
    }
    return null;
  }
}
