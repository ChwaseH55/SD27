import 'dart:convert';
import 'dart:developer';
import 'package:coffee_card/api_request/notifications.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

String homeAddress = "http://11.22.13.70:5000/api/announcements";
String urlAddress = "https://sd27-87d55.web.app/api/announcements";
const FlutterSecureStorage _storage = FlutterSecureStorage();
// Replace with your backend URL

// Create an announcement
Future<void> createAnnouncement(
    String title, String content, String userId) async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await post(
      Uri.parse(urlAddress),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${token!}'
      },
      body: jsonEncode({
        "title": title,
        "content": content,
        "userid": userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode ==  201) {
      final res = AnnouncementModel.fromJson(json.decode(response.body));
      String id = res.announcementid.toString();
      await Notifications.intsance
          .sendNotification('Announcements', title, 'announcements:$id');
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
    final token = await _storage.read(key: 'token');
    final response = await get(Uri.parse(urlAddress),
        headers: {'Authorization': 'Bearer ${token!}'});

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
    final token = await _storage.read(key: 'token');
    final response = await get(Uri.parse("$urlAddress/$id"),
        headers: {'Authorization': 'Bearer ${token!}'});
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
    final token = await _storage.read(key: 'token');
    final response = await put(
      Uri.parse("$urlAddress/$id"),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${token!}'
      },
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
  final token = await _storage.read(key: 'token');
  final response = await delete(Uri.parse("$urlAddress/$id"),
      headers: {'Authorization': 'Bearer ${token!}'});
  return response.statusCode == 200;
}
