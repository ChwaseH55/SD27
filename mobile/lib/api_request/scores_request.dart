import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:coffee_card/models/scores_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

String baseUrl = "https://sd27-87d55.web.app/api/scores";
const FlutterSecureStorage _storage = FlutterSecureStorage();

/// Upload a score with an image

Future<bool> uploadScore({
  required String eventId,
  required List<String> userIds,
  required String scoreImage,
  List<String>? scores,
}) async {
  try {
    var url = Uri.parse("$baseUrl/");

   final token = await _storage.read(key: 'token');
    final response = await post(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${token!}'
      },
      body: jsonEncode({
        "eventid": eventId,
        "userids": userIds.join(','),
        "scoreimage": scoreImage,
        "scores": scores!.join(','),
        "status": 'pending',
        "submissiondaete": DateTime.now().millisecondsSinceEpoch,
        
      }),
    );
    log("Sending Request to: $url");
    log("Event ID: $eventId");
    log("User IDs: $userIds");
    log("Scores: $scores");
    // Handle response
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      log("Success: ${jsonResponse['message']}");
      return true;
    } else {
      log("Error: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    throw Exception("Error updating score: $e");
  }
}

/// Update a score (only if it's not approved)
Future<Map<String, dynamic>> updateScore({
  required String scoreId,
  String? eventId,
  File? scoreImage,
}) async {
  try {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception("Authorization token is missing");

    final url = Uri.parse("$baseUrl/$scoreId");

    var request = http.MultipartRequest("PUT", url);
    request.headers['Authorization'] = 'Bearer $token';

    // Attach optional fields
    if (eventId != null) request.fields['eventid'] = eventId;
    if (scoreImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'scoreimage',
        scoreImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else if (response.statusCode == 403) {
      throw Exception("Cannot update an approved score.");
    } else {
      throw Exception("Failed to update score: ${response.reasonPhrase}");
    }
  } catch (e) {
    throw Exception("Error updating score: $e");
  }
}

Future<bool> approveScore(String scoreId) async {
  try {
    final token = await _storage.read(key: 'token');
    var url = Uri.parse("$baseUrl/approve");
    var response = await http.put(url,
        headers: <String, String>{
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${token!}'
        },
        body: jsonEncode(<String, dynamic>{"scoreid": scoreId}));
    if (response.statusCode == 200) {
      log('Post approved successfully: ${response.body}');
      return true;
    } else {
      log('Error approving post: ${response.body}');
      return false;
    }
  } catch (e) {
    throw Exception('Error approving score: $e');
  }
}

Future<bool> rejectScore(String scoreId) async {
  try {
    final token = await _storage.read(key: 'token');
    var url = Uri.parse("$baseUrl/not-approve");
    var response = await http.put(url,
        headers: <String, String>{
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${token!}'
        },
        body: jsonEncode(<String, dynamic>{"scoreid": scoreId}));
    if (response.statusCode == 200) {
      log('Post rejected successfully: ${response.body}');
      return true;
    } else {
      log('Error rejecting post: ${response.body}');
      return false;
    }
  } catch (e) {
    throw Exception('Error rejecting score: $e');
  }
}

Future<List<ScoresModel>?> getAllScores() async {
  try {
    final token = await _storage.read(key: 'token');

    var url = Uri.parse("$baseUrl/scores");
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ScoresModel.fromJson(json)).toList();
    } else {
      return null;
    }
  } catch (e) {
    throw Exception('Error fetching all Scores: $e');
  }
}

Future<List<ScoresModel>?> getApprovedScores() async {
  try {
    final token = await _storage.read(key: 'token');

    var url = Uri.parse("$baseUrl/scores/approved");
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ScoresModel.fromJson(json)).toList();
    } else {
      return null;
    }
  } catch (e) {
    throw Exception('Error fetching approved Scores: $e');
  }
}

Future<List<ScoresModel>?> getDeniedScores() async {
  try {
    final token = await _storage.read(key: 'token');

    var url = Uri.parse("$baseUrl/scores/not-approved");
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ScoresModel.fromJson(json)).toList();
    } else {
      return null;
    }
  } catch (e) {
    throw Exception('Error fetching not approved Scores: $e');
  }
}

Future<List<ScoresModel>?> getPlayerScores(String id) async {
  try {
    final token = await _storage.read(key: 'token');

    var url = Uri.parse("$baseUrl/scores/player/$id");
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ScoresModel.fromJson(json)).toList();
    } else {
      return null;
    }
  } catch (e) {
    throw Exception('Error fetching not approved Scores: $e');
  }
}

Future<List<ScoresModel>?> getScoresAdmin(String id) async {
  try {
    final token = await _storage.read(key: 'token');

    var url = Uri.parse("$baseUrl/scores/approved-by/$id");
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ScoresModel.fromJson(json)).toList();
    } else {
      return null;
    }
  } catch (e) {
    throw Exception('Error fetching approved admin scores: $e');
  }
}

Future<List<ScoresModel>?> getPendingScores() async {
  try {
    final token = await _storage.read(key: 'token');

    var url = Uri.parse("$baseUrl/pending");
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ScoresModel.fromJson(json)).toList();
    } else {
      return null;
    }
  } catch (e) {
    throw Exception('Error fetching pending Scores: $e');
  }
}

Future<ScoresModel> getScoreById(String scoreId) async {
  final token = await _storage.read(key: 'token');
  var url = Uri.parse("$baseUrl/scores/$scoreId");
  var response =
      await http.get(url, headers: {'Authorization': 'Bearer ${token!}'});
  if (response.statusCode == 200) {
    return ScoresModel.fromJson(json.decode(response.body));
  } else {
    throw Exception(
        'Failed to fetch posts and replies: ${response.statusCode}');
  }
}

Future<bool> deleteScore(String scoreId) async {
  try {
    final token = await _storage.read(key: 'token');
    var url = Uri.parse("$baseUrl/scores/$scoreId");
    var response =
        await http.delete(url, headers: {'Authorization': 'Bearer ${token!}'});
    if (response.statusCode == 200) {
      log('Post deleted successfully: ${response.body}');
      return true;
    } else {
      log('Error deleting post: ${response.body}');
      return false;
    }
  } catch (e) {
    throw Exception('Error fetching post and replies: $e');
  }
}
