import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

/// Example event class.
class Event {
  final String title;
  final int id;

  const Event(this.title, this.id);

  @override
  String toString() => title;
}

class EventProvider extends ChangeNotifier {
  final LinkedHashMap<DateTime, List<Event>> _events =
      LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  UnmodifiableMapView<DateTime, List<Event>> get events =>
      UnmodifiableMapView(_events);

  void addEvent(DateTime date, String title, int id) {
    if (!_events.containsKey(date)) {
      _events[date] = [];
    }
    _events[date]!.add(Event(title, id));
    notifyListeners(); // Notify listeners to rebuild UI
  }

  void removEvent(DateTime date, int id) {
    if (!_events.containsKey(date)) {
      _events[date] = [];
    }
    _events[date]!.removeWhere((event) => event.id == id);
    notifyListeners(); // Notify listeners to rebuild UI
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
