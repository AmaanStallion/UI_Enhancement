import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // static const _phoneKey = 'logged_in_phone';
  // String? userId = prefs.getString('mobileNo');

  // static Future<void> savePhone(String phone) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_phoneKey, phone);
  // }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mobileNo');
  }

  // static Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_phoneKey);
  // }

  // static Future<bool> isLoggedIn() async {
  //   return (await getPhone()) != null;
  // }
}
