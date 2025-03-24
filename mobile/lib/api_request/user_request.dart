import 'dart:convert';
import 'package:http/http.dart';
import 'package:coffee_card/models/user_model.dart';

String urlAddress = "http://10.32.19.48:5000/api/users";

Future<UserModel> getUser({required String userId}) async {
  try {
    final url = Uri.parse('$urlAddress/$userId');
    final response = await get(url);

    if (response.statusCode == 200) {
      final res = UserModel.fromJson(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching user: $e');
  }
}

Future<List<UserModel>> getAllUsers() async {
  try {
    final url = Uri.parse('$urlAddress/');
    final response = await get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching user: $e');
  }
}
