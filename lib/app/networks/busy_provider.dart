import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' show Client;
import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/models/BusyHours.dart';
import 'package:kilat/constants.dart' as cons;

import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;

class BusyProvider {
  final Client client;

  BusyProvider(this.client);

  Future<List<BusyHour>> fetchAll(int accountId) async {
    try {
      String url = cons.url + 'busyhour';
      dynamic data = {
        'function': 'fetch_all',
        'account_id': accountId.toString()
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Iterable json = body['data'];
          List<BusyHour> busys =
              json.map((busy) => BusyHour.fromJson(busy)).toList();

          return busys;
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      print("Busy FetchAll: $e");
    }
  }

  Future<int> add(BusyHour busy) async {
    try {
      String url = cons.url + 'busyhour';
      dynamic data = {
        'function': 'add',
        'busy_hour': jsonEncode(busy.toJson())
      };

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

  Future<bool> edit(BusyHour busy) async {
    try {
      String url = cons.url + 'busyhour';
      dynamic data = {
        'function': 'edit',
        'busy_hour': jsonEncode(busy.toJson())
      };

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
      String url = cons.url + 'busyhour';
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
