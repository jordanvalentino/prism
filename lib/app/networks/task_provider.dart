import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' show Client;
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/models/Tasks.dart';
import 'package:kilat/constants.dart' as cons;

import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;

class TaskProvider {
  final Client client;

  TaskProvider(this.client);

  Future<List<Task>> fetchAll(int accountId) async {
    try {
      String url = cons.url + 'task';
      dynamic data = {
        'function': 'fetch_all',
        'account_id': accountId.toString(),
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Iterable json = body['data'];
          List<Task> tasks = json.map((task) => Task.fromJson(task)).toList();

          return tasks;
        } else
          return Future.error(body['error']);
      }
    } catch (e) {
      print("Task FetchAll: $e");
    }
  }

  Future<int> add(Task task) async {
    try {
      String url = cons.url + 'task';
      dynamic data = {'function': 'add', 'task': jsonEncode(task.toJson())};

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

  Future<bool> edit(Task task) async {
    try {
      String url = cons.url + 'task';
      dynamic data = {'function': 'edit', 'task': jsonEncode(task.toJson())};

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
      String url = cons.url + 'task';
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
