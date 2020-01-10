import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/models/Activities.dart';
import 'package:kilat/app/models/BusyHours.dart';
import 'package:kilat/app/models/Categories.dart';
import 'package:kilat/app/models/EventSetting.dart';
import 'package:kilat/app/models/Preference.dart';
import 'package:kilat/app/models/TaskSetting.dart';

Account account = Account();
Activities activities = Activities();
BusyHours busys = BusyHours();
Categories categories = Categories();
EventSetting evsetSys = EventSetting();
EventSetting evsetUser = EventSetting();
TaskSetting tasetSys = TaskSetting();
TaskSetting tasetUser = TaskSetting();

Preference pref = Preference();

// ----------------------------- DATE TIME --------------------------- //
DateTime today = getToday();
DateTime thisMonday = getThisMonday();
DateTime lastMonday = thisMonday.subtract(Duration(days: 7));
DateTime nextMonday = thisMonday.add(Duration(days: 7));

DateTime getToday() {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);

  return today; // 00:00:00
}

// this monday = today minus difference between monday and today
DateTime getThisMonday() {
  DateTime thisMonday =
      today.subtract(Duration(days: (DateTime.monday - today.weekday).abs()));

  return thisMonday; // 00:00:00
}
