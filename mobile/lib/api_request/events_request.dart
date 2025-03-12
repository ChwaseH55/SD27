import 'dart:convert';
import 'package:coffee_card/models/events_model.dart';
import 'package:http/http.dart';
import 'dart:developer';
import 'package:coffee_card/api_request/config.dart';

String urlAddress = "http://10.0.2.2:5000/api/events";


Future<void> createEvent(
    String eventName,
    String eventDate,
    String eventLocation,
    String eventType,
    bool requiresRegistration,
    int createdByUserId,
    String eventDescription) async {
  try {
    final response = await post(
      Uri.parse('$urlAddress/'),
      headers: {"Content-Type": "application/json"},
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
    final response = await get(Uri.parse(urlAddress));

    if (response.statusCode == 200) {
      
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map JSON list to a list of Post objects
      return jsonList.map((json) => EventsModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch events: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching posts: $e');
  }
}

Future<EventsModel> getEventById(String id) async {
  try {
    final response = await get(Uri.parse("$urlAddress/$id"));
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

Future<void> updateEvent(int id, String eventName,
    String eventDescription, String eventDate, String eventLocation) async {
  try {
    final response = await put(
      Uri.parse("$urlAddress/$id"),
      headers: <String, String>{"Content-Type": "application/json"},
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
  final response = await delete(Uri.parse("$urlAddress/$id"));
  return response.statusCode == 200;
}
