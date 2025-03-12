import 'dart:convert';
import 'package:http/http.dart';
import 'package:coffee_card/models/user_model.dart';

String urlAddress = "http://10.0.2.2:5000/api/users";

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
