import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:kilat/app/models/Model.dart';
import 'package:kilat/constants.dart' as cons;

class Activity extends Model implements Comparable {
  String title;
  DateTime date;
  TimeOfDay timeStart;
  TimeOfDay timeEnd;
  DateTime dateCreated;
  int sysRank;
  int userRank;
  // int categoryId;
  int accountId;

  // getters setters
  int get day => date.weekday;
  String get dayString => cons.days[day - 1];

  DateTime get dateOnly => DateTime.parse(dateString);
  String get dateString => _dateToString(date);
  String get dateCreatedString => _dateToString(dateCreated);

  String get timeStartString => _timeToString(timeStart);
  String get timeEndString => _timeToString(timeEnd);

  int get week =>
      (((DateUtil().daysPastInYear(date.month, date.day, date.year) +
                  ((DateTime(date.year, 1, 1).weekday - DateTime.monday) -
                      1)) ~/
              7) %
          52) +
      1;

  double get dateRange {
    DateTime start = dateCreated;
    DateTime end = date;
    Duration duration = Duration(
      hours: timeStart.hour,
      minutes: timeStart.minute,
    );

    return start.difference(end.add(duration)).abs().inHours / 24.0;
  }

  // constructors
  Activity(
      {this.title = "Untitled",
      this.date,
      this.timeStart,
      this.timeEnd,
      this.dateCreated,
      // this.categoryId,
      this.accountId})
      : sysRank = null,
        userRank = null,
        super();

  @override
  Activity.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        date = DateTime.parse(json['date']),
        timeStart = json.containsKey('time_start')
            ? _stringToTime(json['time_start'])
            : _stringToTime(json['time']),
        timeEnd = json.containsKey('time_end')
            ? (json['time_end'] != null
                ? _stringToTime(json['time_end'])
                : null)
            : null,
        dateCreated = DateTime.parse(json['date_created']),
        sysRank = json['sys_rank'],
        userRank = json['user_rank'],
        // categoryId = json['category_id'],
        accountId = json['account_id'],
        super.fromJson(json);

  // methods
  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'date': dateString,
        'time_start': timeStartString,
        'time_end': timeEnd != null ? timeEndString : null,
        'date_created': dateCreatedString,
        'sys_rank': sysRank,
        'user_rank': userRank,
        // 'category_id': categoryId,
        'account_id': accountId,
      }..addAll(super.toJson());

  @override
  void delete() {
    sysRank = null;
    userRank = null;
    super.delete();
  }

  // statics
  static TimeOfDay _stringToTime(String timeString) {
    int hour = int.parse(timeString.split(':')[0]);
    int minute = int.parse(timeString.split(':')[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _timeToString(TimeOfDay time) =>
      time.toString().substring(10, 15);

  static String _dateToString(DateTime date) => date.toString().split(' ')[0];

  // operators
  @override
  int compareTo(dynamic other) {
    int dateDiff = date.difference(other.date).inDays * 1440;
    int hourDiff = (timeStart.hour - other.timeStart.hour) * 60;
    int minDiff = timeStart.minute - other.timeStart.minute;

    return dateDiff + hourDiff + minDiff;
  }
}
