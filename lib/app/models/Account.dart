import 'package:kilat/app/models/EventSetting.dart';
import 'package:kilat/app/models/Model.dart';
import 'package:kilat/app/models/TaskSetting.dart';
import 'package:kilat/globals.dart' as globals;

class Account extends Model {
  String email;
  String _password;
  String name;
  DateTime birthday;
  String gender;
  int _evsetSysId;
  int _tasetSysId;
  int _evsetUserId;
  int _tasetUserId;
  String evsetType;
  String tasetType;

  // getters setters
  set password(String pass) => _password = pass;
  int get evsetSysId => _evsetSysId;
  int get tasetSysId => _tasetSysId;
  int get evsetUserId => _evsetUserId;
  int get tasetUserId => _tasetUserId;

  int get age => DateTime.now().difference(birthday).inDays ~/ 360;
  EventSetting get evset =>
      (evsetType == 'sys') ? globals.evsetSys : globals.evsetUser;
  TaskSetting get taset =>
      (tasetType == 'sys') ? globals.tasetSys : globals.tasetUser;

  // constructors
  @override
  Account(
      {this.email,
      this.name,
      this.birthday,
      this.gender,
      this.evsetType,
      this.tasetType})
      : _password = null,
        _evsetSysId = null,
        _tasetSysId = null,
        _evsetUserId = null,
        _tasetUserId = null,
        super();

  @override
  Account.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        name = json['name'],
        birthday = DateTime.parse(json['birthday']),
        gender = json['gender'],
        _evsetSysId = json['evset_sys_id'],
        _tasetSysId = json['taset_sys_id'],
        _evsetUserId = json['evset_user_id'],
        _tasetUserId = json['taset_user_id'],
        evsetType = json['evset_type'],
        tasetType = json['taset_type'],
        super.fromJson(json);

  // methods
  @override
  Map<String, dynamic> toJson() => {
        'email': email,
        'password': _password,
        'name': name,
        'birthday': _dateToString(birthday),
        'gender': gender,
        'evset_type': evsetType,
        'taset_type': tasetType,
      }..addAll(super.toJson());

  void save() {
    globals.pref.save('account', this);

    globals.evsetSys.save('evsetSys');
    globals.evsetUser.save('evsetUser');

    globals.tasetSys.save('tasetSys');
    globals.tasetUser.save('tasetUser');
  }

  Future load() async {
    await globals.pref.load('account').then((json) async {
      super.loadJson(json);
      email = json['email'];
      name = json['name'];
      birthday = DateTime.parse(json['birthday']);
      gender = json['gender'];
      _evsetSysId = json['evset_sys_id'];
      _tasetSysId = json['taset_sys_id'];
      _evsetUserId = json['evset_user_id'];
      _tasetUserId = json['taset_user_id'];
      evsetType = json['evset_type'];
      tasetType = json['taset_type'];

      await globals.evsetSys.load('evsetSys');
      await globals.evsetUser.load('evsetUser');

      await globals.tasetSys.load('tasetSys');
      await globals.tasetUser.load('tasetUser');
    });
  }

  void remove() {
    globals.pref.remove('account');

    globals.evsetSys.remove('evsetSys');
    globals.evsetUser.remove('evsetUser');

    globals.tasetSys.remove('tasetSys');
    globals.tasetUser.remove('tasetUser');
  }

  // statics
  static String _dateToString(DateTime date) => date.toString().split(' ')[0];
}
