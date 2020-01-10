import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' show Client;
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/models/Events.dart';
import 'package:kilat/constants.dart' as cons;

import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;

class EventProvider {
  final Client client;

  EventProvider(this.client);

  Future<List<Event>> fetchAll(int accountId) async {
    try {
      String url = cons.url + 'event';
      dynamic data = {
        'function': 'fetch_all',
        'account_id': accountId.toString(),
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Iterable json = body['data'];
          List<Event> events =
              json.map((event) => Event.fromJson(event)).toList();

          return events;
        } else
          return Future.error(body['error']);
      }
    } catch (e) {
      print("Event FetchAll: $e");
    }
  }

  Future<int> add(Event event) async {
    try {
      String url = cons.url + 'event';
      dynamic data = {'function': 'add', 'event': jsonEncode(event.toJson())};

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          return body['data'];
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }

  Future<bool> edit(Event event) async {
    try {
      String url = cons.url + 'event';
      dynamic data = {'function': 'edit', 'event': jsonEncode(event.toJson())};

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          return Future.value(true);
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }

  Future<bool> delete(int id) async {
    try {
      String url = cons.url + 'event';
      dynamic data = {'function': 'delete', 'id': id.toString()};

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          return Future.value(true);
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }
}
