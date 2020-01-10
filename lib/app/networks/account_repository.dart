import 'dart:async';

import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/models/EventSetting.dart';
import 'package:kilat/app/models/TaskSetting.dart';
import 'package:kilat/app/networks/account_provider.dart';

class AccountRepository {
  final AccountProvider accountProvider;
  Account account = Account();

  AccountRepository(this.accountProvider);

  Future<Map<String, dynamic>> signin(Account account) {
    return accountProvider.signin(account);
  }

  Future<bool> edit(Account account) {
    return accountProvider.edit(account);
  }

  Future<List<EventSetting>> fetchEventSetting(int sysId, int userId) {
    return accountProvider.fetchEventSetting(sysId, userId);
  }

  Future<List<TaskSetting>> fetchTaskSetting(int sysId, int userId) {
    return accountProvider.fetchTaskSetting(sysId, userId);
  }

  Future<bool> canSignup(String email) {
    return accountProvider.canSignup(email);
  }

  Future<Map<String, dynamic>> signup(Account account) {
    return accountProvider.signup(account);
  }

  Future<bool> updateEventSetting(EventSetting evset) {
    return accountProvider.updateEventSetting(evset);
  }

  Future<bool> updateTaskSetting(TaskSetting taset) {
    return accountProvider.updateTaskSetting(taset);
  }
}
