import 'package:flutter/material.dart';

class CustomTime extends TimeOfDay {
  CustomTime({hour, minute}) : super(hour: hour, minute: minute);

  CustomTime.fromTimeOfDay(TimeOfDay time)
      : super(hour: time.hour, minute: time.minute);

  CustomTime add(Duration duration) {
    int hour = super.hour + duration.inHours;
    int minute = super.minute + (duration.inMinutes % 60);

    if (minute > 59) {
      hour += minute ~/ 60;
      minute %= 60;
    }

    if (hour > 23) {
      hour %= 24;
    }

    return CustomTime(hour: hour, minute: minute);
  }

  CustomTime subtract(Duration duration) {
    int hour = super.hour - duration.inHours;
    int minute = super.minute - (duration.inMinutes % 60);

    if (minute < 0) {
      minute += 60;
      hour -= 1;
    }

    if (hour < 0) {
      hour += 24;
    }

    return CustomTime(hour: hour, minute: minute);
  }

  bool operator ==(other) =>
      super.hour == other.hour && super.minute == other.minute;

  bool operator >(other) =>
      (super.hour > other.hour) ||
      (super.hour == other.hour && super.minute > other.minute);
  bool operator <(other) =>
      (super.hour < other.hour) ||
      (super.hour == other.hour && super.minute < other.minute);

  bool operator >=(other) =>
      (super.hour > other.hour) ||
      (super.hour == other.hour && super.minute >= other.minute);
  bool operator <=(other) =>
      (super.hour < other.hour) ||
      (super.hour == other.hour && super.minute <= other.minute);
}

List<TimeOfDay> compareStartEndTime(
    String type, TimeOfDay startTime, TimeOfDay endTime) {
  CustomTime start = CustomTime(hour: startTime.hour, minute: startTime.minute);
  CustomTime end = CustomTime(hour: endTime.hour, minute: endTime.minute);

  switch (type) {
    case 'start':
      if (startTime.hour == endTime.hour &&
          startTime.minute >= endTime.minute) {
        end = start.add(Duration(minutes: 10));
      } else if (startTime.hour > endTime.hour) {
        end = start.add(Duration(minutes: 10));
      }
      break;
    case 'end':
      if (endTime.hour < startTime.hour) {
        start = end.subtract(Duration(minutes: 10));
      } else if (endTime.hour == startTime.hour &&
          endTime.minute <= startTime.minute) {
        start = end.subtract(Duration(minutes: 10));
      }
      break;
    default:
      break;
  }

  return [start, end];
}
