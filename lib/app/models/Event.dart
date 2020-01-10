import 'package:kilat/app/models/Activity.dart';
import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/models/SmartEvent.dart';
import 'package:kilat/app/views/custom_materials/custom_time.dart';

class Event extends Activity implements Comparable {
  int participant;
  int involvement;

  // getters setters
  double get duration {
    double diffHour = (timeEnd.hour - timeStart.hour).abs().toDouble();
    double diffMin = (timeEnd.minute - timeStart.minute) / 60.0;

    return diffHour + diffMin;
  }

  // constructors
  @override
  Event(
      {title,
      date,
      timeStart,
      timeEnd,
      dateCreated,
      categoryId,
      accountId,
      this.participant,
      this.involvement})
      : super(
          title: title,
          date: date,
          timeStart: timeStart,
          timeEnd: timeEnd,
          dateCreated: dateCreated,
          // categoryId: categoryId,
          accountId: accountId,
        );

  @override
  Event.fromJson(Map<String, dynamic> json)
      : involvement = json['involvement'],
        participant = json['participant'],
        super.fromJson(json);

  // methods
  @override
  Map<String, dynamic> toJson() => {
        'participant': participant,
        'involvement': involvement,
      }..addAll(super.toJson());

  void replaceWith(Event event) {
    title = event.title;
    date = event.date;
    timeStart = event.timeStart;
    timeEnd = event.timeEnd;
    dateCreated = event.dateCreated;
    participant = event.participant;
    involvement = event.involvement;
    // categoryId = event.categoryId;

    update();
  }

  SmartEvent toSmartObject() => SmartEvent(
      origin: this,
      id: id,
      dateRange: dateRange,
      duration: duration,
      participant: participant.toDouble(),
      involvement: involvement.toDouble(),
      sysRank: sysRank,
      userRank: userRank);

  bool hasCollisionWithEvents(List<Event> events, Event exception) =>
      events
          .where((ev) =>
              (ev != this) &&
              (ev != exception) &&
              (!ev.isDeleted) &&
              (ev.dateString == dateString) &&
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

  bool hasCollisionWithBusys(List<BusyHour> busys) =>
      busys
          .where((bs) =>
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

  // operators
  @override
  int compareTo(dynamic other) {
    int dateDiff = date.difference(other.date).inDays * 1440;
    int hourDiff = (timeStart.hour - other.timeStart.hour) * 60;
    int minDiff = timeStart.minute - other.timeStart.minute;

    return dateDiff + hourDiff + minDiff;
  }
}
