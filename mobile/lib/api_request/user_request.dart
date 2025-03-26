import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:coffee_card/models/user_model.dart';

String urlAddress = "https://sd27-87d55.web.app/api/users";
String devAddress = "http://11.22.13.70:5000/api/users/";
const FlutterSecureStorage _storage = FlutterSecureStorage();

Future<UserModel> getSingleUser({required String userId}) async {
  try {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$devAddress/$userId');
    final response =
        await get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final res = UserModel.fromJson(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  } catch (e,stackTrace) {
     log('Stack Trace: $stackTrace');
    throw Exception('Error fetching user: $e');
  }
}

Future<List<UserModel>> getAllUsers() async {
  try {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$urlAddress/');
    final response =
        await get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching users: $e');
  }
}
