import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' show Client;
import 'package:kilat/app/models/Category.dart';
import 'package:kilat/app/models/Categories.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/constants.dart' as cons;

class CategoryProvider {
  final Client client;

  CategoryProvider(this.client);

  Future<Categories> fetchAll(int accountId) async {
    try {
      String url = cons.url + 'category';
      dynamic data = {
        'function': 'fetch_all',
        'account_id': accountId.toString()
      };

      final response = await client.post(Uri.encodeFull(url), body: data);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['errno'] == 0) {
          Iterable json = body['data'];
          List<Category> cats =
              json.map((cat) => Category.fromJson(cat)).toList();

          return Categories.fromList(cats);
        } else
          return Future.error(body['error']);
      }
    } on SocketException catch (e) {
      return Future.error(dialogs.socketExceptionMessage(e));
    }
  }

  Future<int> add(Category cat) async {
    try {
      String url = cons.url + 'category';
      dynamic data = {'function': 'add', 'category': jsonEncode(cat.toJson())};

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

  Future<bool> edit(Category cat) async {
    try {
      String url = cons.url + 'category';
      dynamic data = {'function': 'edit', 'category': jsonEncode(cat.toJson())};

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
      String url = cons.url + 'category';
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
