import 'dart:async';

import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/models/Events.dart';
import 'package:kilat/app/networks/event_provider.dart';

class EventRepository {
  final EventProvider eventProvider;

  EventRepository(this.eventProvider);

  Future<List<Event>> fetchAll(int accountId) {
    return eventProvider.fetchAll(accountId);
  }

  Future<int> add(Event event) {
    return eventProvider.add(event);
  }

  Future<bool> edit(Event event) {
    return eventProvider.edit(event);
  }

  Future<bool> delete(int id) {
    return eventProvider.delete(id);
  }
}
