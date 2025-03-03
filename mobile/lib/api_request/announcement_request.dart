import 'dart:convert';
import 'dart:developer';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:http/http.dart';

String urlAddress =
    "http://10.0.2.2:5000/api/announcements"; // Replace with your backend URL

// Create an announcement
Future<void> createAnnouncement(
    String title, String content, int userId) async {
  try {
    final response = await post(
      Uri.parse(urlAddress),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "content": content,
        "userid": userId,
      }),
    );

    if (response.statusCode == 200) {
      log('Announcement created successfully: ${response.body}');
    } else {
      log('Error creating Announcement: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

// Get all announcements
Future<List<AnnouncementModel>> getAllAnnouncements() async {
  try {
    final response = await get(Uri.parse(urlAddress));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map JSON list to a list of Post objects
      return jsonList.map((json) => AnnouncementModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch announcement: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching announcement: $e');
  }
}

// Get a single announcement by ID
Future<AnnouncementModel> getAnnouncementById(String id) async {
  try {
    final response = await get(Uri.parse("$urlAddress/$id"));
    if (response.statusCode == 200) {
      final res = AnnouncementModel.fromJson(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to fetch announcement: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching announcement: $e');
  }
}

// Update an announcement
Future<void> updateAnnouncement(int id, String title, String content) async {
  try {
    final response = await put(
      Uri.parse("$urlAddress/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "content": content,
      }),
    );

    if (response.statusCode == 200) {
      log('Announcement updated successfully: ${response.body}');
    } else {
      log('Error updating announcement: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

// Delete an announcement
Future<bool> deleteAnnouncement(int id) async {
  final response = await delete(Uri.parse("$urlAddress/$id"));
  return response.statusCode == 200;
}
