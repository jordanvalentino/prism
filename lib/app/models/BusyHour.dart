import 'package:flutter/material.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/models/Model.dart';
import 'package:kilat/app/views/custom_materials/custom_time.dart';

import 'package:kilat/constants.dart' as cons;

class BusyHour extends Model implements Comparable<BusyHour> {
  int day;
  TimeOfDay timeStart;
  TimeOfDay timeEnd;
  int accountId;
  bool isActive;

  // getters setters
  String get dayString => cons.days[day - 1];
  String get timeStartString => _timeToString(timeStart);
  String get timeEndString => _timeToString(timeEnd);

  double get duration {
    double diffHour = (timeEnd.hour - timeStart.hour).abs().toDouble();
    double diffMin = (timeEnd.minute - timeStart.minute) / 60.0;

    return diffHour + diffMin;
  }

  // constructors
  @override
  BusyHour(
      {this.day,
      this.timeStart,
      this.timeEnd,
      this.accountId,
      this.isActive = true})
      : super();

  @override
  BusyHour.fromJson(Map<String, dynamic> json)
      : day = json['day'],
        timeStart = _stringToTime(json['time_start']),
        timeEnd = _stringToTime(json['time_end']),
        accountId = json['account_id'],
        isActive = json['is_active'] == 1,
        super.fromJson(json);

  // methods
  @override
  Map<String, dynamic> toJson() => {
        'day': day,
        'time_start': timeStartString,
        'time_end': timeEndString,
        'account_id': accountId,
        'is_active': isActive,
      }..addAll(super.toJson());

  void replaceWith(BusyHour busy) {
    day = busy.day;
    timeStart = busy.timeStart;
    timeEnd = busy.timeEnd;
    isActive = busy.isActive;

    update();
  }

  bool hasCollisionWithEvents(List<Event> events) =>
      events
          .where((ev) =>
              (!ev.isDeleted) &&
              (ev.day == day) &&
              ((CustomTime.fromTimeOfDay(ev.timeStart) >=
                          CustomTime.fromTimeOfDay(timeStart) &&
                      CustomTime.fromTimeOfDay(ev.timeStart) <
                          CustomTime.fromTimeOfDay(timeEnd)) ||
                  (CustomTime.fromTimeOfDay(ev.timeEnd) >
                          CustomTime.fromTimeOfDay(timeStart) &&
                      CustomTime.fromTimeOfDay(ev.timeEnd) <=
                          CustomTime.fromTimeOfDay(timeEnd))))
          .length >
      0;

  bool hasCollisionWithBusys(List<BusyHour> busys, BusyHour exception) =>
      busys
          .where((bs) =>
              (bs != this) &&
              (bs != exception) &&
              (!bs.isDeleted) &&
              (bs.isActive) &&
              (bs.day == day) &&
              ((CustomTime.fromTimeOfDay(bs.timeStart) >=
                          CustomTime.fromTimeOfDay(timeStart) &&
                      CustomTime.fromTimeOfDay(bs.timeStart) <
                          CustomTime.fromTimeOfDay(timeEnd)) ||
                  (CustomTime.fromTimeOfDay(bs.timeEnd) >
                          CustomTime.fromTimeOfDay(timeStart) &&
                      CustomTime.fromTimeOfDay(bs.timeEnd) <=
                          CustomTime.fromTimeOfDay(timeEnd))))
          .length >
      0;

  // statics
  static TimeOfDay _stringToTime(String timeString) {
    int hour = int.parse(timeString.split(':')[0]);
    int minute = int.parse(timeString.split(':')[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _timeToString(TimeOfDay time) {
    return time.toString().substring(10, 15);
  }

  // operators
  @override
  int compareTo(BusyHour other) {
    int dayDiff = (day * 1440) - (other.day * 1440);
    int hourDiff = (timeStart.hour * 60) - (other.timeStart.hour * 60);
    int minDiff = timeStart.minute - other.timeStart.minute;
    return dayDiff + hourDiff + minDiff;
  }
}
