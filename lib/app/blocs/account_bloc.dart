import 'dart:async';

import 'package:kilat/app/blocs/bloc.dart';
import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/models/EventSetting.dart';
import 'package:kilat/app/models/TaskSetting.dart';
import 'package:kilat/app/networks/account_repository.dart';
import 'package:kilat/globals.dart' as globals;

class AccountBloc extends Bloc {
  final AccountRepository _accountRepository;

  AccountBloc(this._accountRepository);

  @override
  init() {}

  @override
  void dispose() {}

  Future<bool> signin(Account account) async {
    try {
      // reset global account
      globals.account = Account();

      await _accountRepository.signin(account).then((json) {
        globals.account = Account.fromJson(json);
      });

      return Future.value(true);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> fetchEventSetting(int sysId, int userId) async {
    await _accountRepository.fetchEventSetting(sysId, userId).then((value) {
      globals.evsetSys = value[0];
      globals.evsetUser = value[1];
    });
  }

  Future<void> fetchTaskSetting(int sysId, int userId) async {
    await _accountRepository.fetchTaskSetting(sysId, userId).then((value) {
      globals.tasetSys = value[0];
      globals.tasetUser = value[1];
    });
  }

  Future<bool> canSignup(Account account) {
    return _accountRepository.canSignup(account.email);
  }

  Future<bool> signup(Account account) async {
    try {
      // reset global account
      globals.account = Account();

      account.update();
      await _accountRepository.signup(account).then((json) {
        globals.account = Account.fromJson(json);
      });

      return Future.value(true);
    } catch (e) {
      return Future.error(e);
    }
  }

  synchronize() {
    if (globals.account.isUpdated)
      _accountRepository.edit(globals.account).then((_) {
        globals.account.updated();
      }).catchError((e) {
        print(e);
      });

    if (globals.evsetSys.isUpdated)
      _accountRepository.updateEventSetting(globals.evsetSys).then((_) {
        globals.evsetSys.updated();
      }).catchError((e) {
        print(e);
      });

    if (globals.evsetUser.isUpdated)
      _accountRepository.updateEventSetting(globals.evsetUser).then((_) {
        globals.evsetUser.updated();
      }).catchError((e) {
        print(e);
      });

    if (globals.tasetSys.isUpdated)
      _accountRepository.updateTaskSetting(globals.tasetSys).then((_) {
        globals.tasetSys.updated();
      }).catchError((e) {
        print(e);
      });

    if (globals.tasetUser.isUpdated)
      _accountRepository.updateTaskSetting(globals.tasetUser).then((_) {
        globals.tasetUser.updated();
      }).catchError((e) {
        print(e);
      });
  }

  Future updateSettings() async {
    globals.activities.events.updateWeight();
    globals.activities.tasks.updateWeight();
  }
}
