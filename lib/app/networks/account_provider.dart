import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' show Client;
import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/models/EventSetting.dart';
import 'package:kilat/app/models/TaskSetting.dart';
import 'package:kilat/constants.dart' as cons;

import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;

class AccountProvider {
  final Client client;

  AccountProvider(this.client);

  Future<Map<String, dynamic>> signin(Account account) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {
        'function': 'signin',
        'account': jsonEncode(account.toJson())
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Map<String, dynamic> json = body['data'];
          return json;
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }

  Future<bool> edit(Account account) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {
        'function': 'edit',
        'account': jsonEncode(account.toJson())
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

  Future<List<EventSetting>> fetchEventSetting(int sysId, int userId) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {
        'function': 'fetch_event_setting',
        'sys_id': sysId.toString(),
        'user_id': userId.toString()
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Iterable json = body['data'];
          List<EventSetting> evsets =
              json.map((evset) => EventSetting.fromJson(evset)).toList();
          return evsets;
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }

  Future<List<TaskSetting>> fetchTaskSetting(int sysId, int userId) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {
        'function': 'fetch_task_setting',
        'sys_id': sysId.toString(),
        'user_id': userId.toString()
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Iterable json = body['data'];
          List<TaskSetting> tasks =
              json.map((task) => TaskSetting.fromJson(task)).toList();
          return tasks;
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }

  Future<bool> canSignup(String email) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {'function': 'can_signup', 'email': email};

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0)
          return Future.value(true);
        else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }

  Future<Map<String, dynamic>> signup(Account account) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {
        'function': 'signup',
        'account': jsonEncode(account.toJson()),
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Map<String, dynamic> json = body['data'];
          return json;
        } else
          return Future.error(body['error']);
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> updateEventSetting(EventSetting evset) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {
        'function': 'update_event_setting',
        'event_setting': jsonEncode(evset.toJson()),
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

  Future<bool> updateTaskSetting(TaskSetting taset) async {
    try {
      String url = cons.url + 'account';
      dynamic data = {
        'function': 'update_task_setting',
        'task_setting': jsonEncode(taset.toJson()),
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
}
