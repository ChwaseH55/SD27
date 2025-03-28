import 'dart:convert';
import 'package:coffee_card/api_request/notifications.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'dart:developer';
import 'package:coffee_card/api_request/config.dart';

String urlAddress = "https://sd27-87d55.web.app/api/events";
const FlutterSecureStorage _storage = FlutterSecureStorage();

Future<void> createEvent(
    String eventName,
    String eventDate,
    String eventLocation,
    String eventType,
    bool requiresRegistration,
    int createdByUserId,
    String eventDescription) async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await post(
      Uri.parse('$urlAddress/'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${token!}'
      },
      body: jsonEncode({
        "event_name": eventName,
        "event_date": eventDate,
        "event_location": eventLocation,
        "event_type": eventType,
        "requires_registration": requiresRegistration,
        "created_by_user_id": createdByUserId,
        "event_description": eventDescription,
      }),
    );

    if (response.statusCode == 200) {
      final res = EventsModel.fromJson(json.decode(response.body));
      String id = res.eventid.toString();
      await Notifications.intsance.sendNotification(
          'Events', eventName,  'events:$id');

      log('Post created successfully: ${response.body}');
    } else {
      log('Error creating post: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<List<EventsModel>> getAllEvents() async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await get(Uri.parse(urlAddress),
        headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map JSON list to a list of Post objects
      return jsonList.map((json) => EventsModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch events: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching events: $e');
  }
}

Future<EventsModel> getEventById(String id) async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await get(Uri.parse("$urlAddress/$id"),
        headers: {'Authorization': 'Bearer ${token!}'});
    if (response.statusCode == 200) {
      final res = EventsModel.fromJson(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to fetch event: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching events: $e');
  }
}

Future<void> updateEvent(int id, String eventName, String eventDescription,
    String eventDate, String eventLocation) async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await put(
      Uri.parse("$urlAddress/$id"),
      headers: <String, String>{
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${token!}'
      },
      body: jsonEncode({
        "event_name": eventName,
        "event_description": eventDescription,
        "event_date": eventDate,
        "event_location": eventLocation,
      }),
    );

    if (response.statusCode == 200) {
      log('Event updated successfully: ${response.body}');
    } else {
      log('Error updating event: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<bool> deleteEvent(int id) async {
  final token = await _storage.read(key: 'token');
  final response = await delete(Uri.parse("$urlAddress/$id"),
      headers: {'Authorization': 'Bearer ${token!}'});
  return response.statusCode == 200;
}

Future<void> registerForEvent(String eventId, String userId) async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await post(
      Uri.parse('$urlAddress/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token!}'
      },
      body: jsonEncode({'eventid': eventId, 'userid': userId}),
    );
    if (response.statusCode == 200) {
      log('Registered successfully: ${response.body}');
    } else {
      log('Error registering: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<bool> unregisterFromEvent(String eventId, String userId) async {
  final token = await _storage.read(key: 'token');
  final response = await delete(
    Uri.parse('$urlAddress/unregister/$eventId/$userId'),
    headers: {'Authorization': 'Bearer ${token!}'},
  );
  if (response.statusCode == 200) {
    log('Unregister successfully: ${response.body}');
    return true;
  } else {
    throw Exception('Failed to check registration status');
  }
}

Future<List<EventsModel>> getUserRegisteredEvents(String userId) async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await get(Uri.parse('$urlAddress/my-events/$userId'),
        headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map JSON list to a list of Post objects
      return jsonList.map((json) => EventsModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch registered events: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching registered events: $e');
  }
}

Future<bool> isUserRegisteredForEvent(String eventId, String userId) async {
  try {
    final token = await _storage.read(key: 'token');
    final response = await get(
        Uri.parse('$urlAddress/is-registered/$eventId/$userId'),
        headers: {'Authorization': 'Bearer ${token!}'});
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString())['registered'].toString();
      return data == 'true';
    } else {
      throw Exception('Failed check: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error checking: $e');
  }
}
