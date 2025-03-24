import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

String baseUrl = "http://10.32.19.48:5000/api/scores"; 
 String url = "http://your-server-ip:port"; // Replace with actual server URL

  Future<void> createScore(
      String eventId, List<String> userIds, File imageFile) async {
    var url = Uri.parse("$baseUrl/scores");
    var request = http.MultipartRequest("POST", url);
    request.fields["eventid"] = eventId;
    request.fields["userids"] = userIds.join(",");
    
    request.files.add(
      await http.MultipartFile.fromPath(
        "scoreimage",
        imageFile.path,
        contentType: MediaType("image", "jpeg"),
      ),
    );
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return jsonDecode(responseData);
    } 
  }

  Future<void> updateScore(
      String scoreId, String? eventId, File? imageFile) async {
    var url = Uri.parse("$baseUrl/scores/$scoreId");
    var body = {"eventid": eventId};
    if (imageFile != null) {
      body["scoreimage"] = base64Encode(imageFile.readAsBytesSync());
    }

    var response = await http.put(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } 
  }

  Future<bool> approveScore(String scoreId) async {
    var url = Uri.parse("$baseUrl/scores/approve");
    var response = await http.put(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"scoreid": scoreId}));
    return response.statusCode == 200;
  }

  Future<bool> rejectScore(String scoreId) async {
    var url = Uri.parse("$baseUrl/scores/not-approve");
    var response = await http.put(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"scoreid": scoreId}));
    return response.statusCode == 200;
  }

  Future<List<dynamic>?> getAllScores() async {
    var url = Uri.parse("$baseUrl/scores");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getScoreById(String scoreId) async {
    var url = Uri.parse("$baseUrl/scores/$scoreId");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<bool> deleteScore(String scoreId) async {
    var url = Uri.parse("$baseUrl/scores/$scoreId");
    var response = await http.delete(url);
    return response.statusCode == 200;
  }

