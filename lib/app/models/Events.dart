import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/models/EventSetting.dart';
import 'package:kilat/app/models/SmartEvent.dart';
import 'package:kilat/app/views/custom_materials/custom_time.dart';
import 'package:kilat/globals.dart' as globals;

class Events {
  List<Event> _events;
  List<SmartEvent> _smarts;

  // getters setters
  List<Event> get all => _events;
  List<Event> get list => _events.where((ev) => !ev.isDeleted).toList();
  set oldList(List<Event> newList) => _events = newList;

  List<Event> get online => all.where((ev) => ev.id != null).toList();
  List<Event> get offline => all.where((ev) => ev.id == null).toList();
  List<Event> get updated => online.where((ev) => ev.isUpdated).toList();

  List<Event> get thisWeek => list
      .where((ev) =>
          (ev.date.isAfter(globals.thisMonday.subtract(Duration(days: 1))) &&
              ev.date.isBefore(globals.nextMonday)))
      .toList();

  List<Event> get lastWeek => list
      .where((ev) =>
          (ev.date.isAfter(globals.lastMonday.subtract(Duration(days: 1))) &&
              ev.date.isBefore(globals.thisMonday)))
      .toList();

  // constructors
  Events() {
    _events = new List<Event>();
  }

  Events.fromList(List<Event> list) : _events = list;

  // methods
  void add(Event event) {
    all.add(event);

    List<Event> weekly = list.where((ev) => ev.week == event.week).toList();
    rank(weekly);
    all.sort((a, b) => a.compareTo(b));
  }

  void update(Event old, Event replacement) {
    int oldWeek = old.week;
    int newWeek = replacement.week;

    list.singleWhere((ev) => ev == old).replaceWith(replacement);

    // re-rank new weekly schedule
    List<Event> weekly =
        list.where((ev) => ev.week == replacement.week).toList();
    rank(weekly);

    // re-rank old weekly schedule if not the same as new week and not in the past week
    if ((oldWeek != newWeek) && old.date.isAfter(globals.thisMonday)) {
      List<Event> weekly = list.where((ev) => ev.week == oldWeek).toList();
      rank(weekly);
    }

    all.sort((a, b) => a.compareTo(b));
  }

  void delete(Event event) {
    list.singleWhere((ev) => ev == event).delete();

    List<Event> weekly = list.where((ev) => ev.week == event.week).toList();
    if (weekly.length > 0) rank(weekly);
  }

  void save() {
    globals.pref.save('events', _events);
  }

  Future load() async {
    await globals.pref.load('events').then((json) {
      _events = List<Event>.from(json.map((m) => Event.fromJson(m)));
    });
  }

  void remove() {
    globals.pref.remove('events');
  }

  // custom methods
  void _convertToSmarts(List<Event> weekly) {
    _smarts = new List<SmartEvent>();

    weekly.forEach((ev) {
      _smarts.add(ev.toSmartObject());
    });
  }

  void _standardizeSmarts() {
    // standardize all attribute-values (maximize function)
    List<double> ranges =
        _standardize(_smarts.map((ev) => ev.dateRange).toList());
    List<double> durations =
        _standardize(_smarts.map((ev) => ev.duration).toList());
    List<double> participants =
        _standardize(_smarts.map((ev) => ev.participant).toList());
    List<double> involvements =
        _standardize(_smarts.map((ev) => ev.involvement).toList());

    for (int i = 0; i < _smarts.length; i++) {
      _smarts[i].dateRange = ranges[i];
      _smarts[i].duration = durations[i];
      _smarts[i].participant = participants[i];
      _smarts[i].involvement = involvements[i];
    }
  }

  List<double> _standardize(List<double> values) {
    double maxValue = values.reduce(max);
    double minValue = values.reduce(min);

    List<double> standards = List<double>();
    values.forEach((val) {
      standards.add((val - minValue) / (maxValue - minValue) * 100.0);
    });

    return standards;
  }

  // ------------------------------------------------------------------ //
  // -------------------------- SMART RANK ---------------------------- //
  // ------------------------------------------------------------------ //
  void rank(List<Event> weekly) {
    _convertToSmarts(weekly);
    _standardizeSmarts();
    _scoreSmarts();
    _rankWeekly(weekly);

    _smarts.clear();
  }

  void _scoreSmarts() {
    // determine which event setting to use
    EventSetting evset = globals.account.evset;

    for (int i = 0; i < _smarts.length; i++) {
      _smarts[i].dateRange *= evset.wDateRange;
      _smarts[i].duration *= evset.wDuration;
      _smarts[i].participant *= evset.wParticipant;
      _smarts[i].involvement *= evset.wInvolvement;
    }
  }

  void _rankWeekly(List<Event> weekly) {
    // bigest score get 1st rank
    _smarts.sort(
        (smart2, smart1) => smart1.totalScore.compareTo(smart2.totalScore));

    for (int i = 0; i < _smarts.length; i++) {
      for (int j = 0; j < weekly.length; j++) {
        if (_smarts[i].origin == weekly[j]) {
          weekly[j].sysRank = i + 1;
          weekly[j].update();
          break;
        }
      }
    }
  }

  // ------------------------------------------------------------------ //
  // -------------------------- RESCHEDULE ---------------------------- //
  // ------------------------------------------------------------------ //
  List<Map<String, dynamic>> reschedule(Event event) {
    List<Event> sameWeek = list
        .where((ev) =>
            (ev.week == event.week) &&
            (ev.date
                .add(Duration(
                    hours: ev.timeStart.hour, minutes: ev.timeStart.minute))
                .isAfter(event.date.add(Duration(
                    hours: event.timeEnd.hour,
                    minutes: event.timeEnd.minute)))))
        .toList()
          ..insert(0, event);

    _convertToSmarts(sameWeek);
    _standardizeSmarts();
    _scoreSmarts();
    _reRankWeekly(sameWeek);

    // get before and after schedule
    Event current = sameWeek.singleWhere((ev) => ev == event);
    Event above =
        sameWeek.singleWhere((ev) => ev.sysRank == (current.sysRank - 1),
            orElse: () => Event(
                  date: event.date.add(Duration(days: 1)),
                  timeStart: TimeOfDay(hour: 7, minute: 0),
                  timeEnd: TimeOfDay(hour: 7, minute: 0),
                ));
    Event below = sameWeek.singleWhere(
        (ev) => ev.sysRank == (current.sysRank + 1),
        orElse: () => Event(
              date: event.date.add(Duration(days: (7 - event.date.weekday))),
              timeStart: TimeOfDay(hour: 23, minute: 59),
              timeEnd: TimeOfDay(hour: 23, minute: 59),
            ));

    List<Map<String, dynamic>> scheduleMaps;

    // determine earliest and latest time to schedule based on participant
    int minHour, maxHour;
    if (current.participant <= 3) {
      minHour = 7;
      maxHour = 22;
    } else if (current.participant > 3) {
      minHour = 9;
      maxHour = 17;
    }

    // if current gets the lowest priority
    // if (below == null) {
    //   int startDay;
    //   int startHour, endHour;
    //   int startMin, endMin;

    //   startDay = above.date.weekday;
    //   startHour = above.timeEnd.hour;
    //   endHour = startHour + current.duration.toInt();
    //   startMin = above.timeEnd.minute;
    //   endMin = startMin += ((current.duration % 1) * 60).toInt();

    //   if (startHour >= maxHour ||
    //       endHour > maxHour ||
    //       (endHour >= maxHour && endMin > 0)) {
    //     startDay += 1;
    //     startHour = minHour;
    //     startMin = 0;
    //   } else if (startHour < minHour) {
    //     startHour = minHour;
    //     startMin = 0;
    //   }

    //   DateTime dateStart = above.date.add(Duration(
    //       days: startDay - above.date.weekday,
    //       hours: startHour,
    //       minutes: startMin));
    //   DateTime dateEnd =
    //       dateStart.add(Duration(minutes: (current.duration * 60).toInt()));

    //   scheduleMaps = [
    //     {
    //       'available': null,
    //       'dateStart': dateStart,
    //       'dateEnd': dateEnd,
    //     }
    //   ];
    // } else {}

    Event before = ((above.compareTo(below)) <= 0) ? above : below;
    Event after = (before == above) ? below : above;

    List<BusyHour> busys = globals.busys.list
        .where((bs) =>
            ((bs.day >= before.day) && (bs.day <= after.day)) &&
            ((CustomTime.fromTimeOfDay(bs.timeStart) >=
                    CustomTime.fromTimeOfDay(before.timeEnd) &&
                (CustomTime.fromTimeOfDay(bs.timeEnd) <=
                    CustomTime.fromTimeOfDay(after.timeStart)))))
        .toList();

    scheduleMaps =
        _recommendedSchedules(busys, current, before, after, minHour, maxHour);

    if (scheduleMaps.length > 0) {
      for (int i = 0; i < scheduleMaps.length; i++) {
        DateTime start = scheduleMaps[i]['dateStart'];
        DateTime end = scheduleMaps[i]['dateEnd'];

        Event reEvent = Event()..replaceWith(event);
        reEvent.date = DateTime(start.year, start.month, start.day);
        reEvent.dateCreated = event.date;
        reEvent.timeStart = TimeOfDay(hour: start.hour, minute: start.minute);
        reEvent.timeEnd = TimeOfDay(hour: end.hour, minute: end.minute);

        scheduleMaps[i].addAll({'event': reEvent});
      }
    }

    return scheduleMaps;
  }

  void _reRankWeekly(List<Event> weekly) {
    // reTotalScore: without date range criteria
    _smarts.sort(
        (smart2, smart1) => smart1.reTotalScore.compareTo(smart2.reTotalScore));

    for (int i = 0; i < _smarts.length; i++) {
      for (int j = 0; j < weekly.length; j++) {
        if (_smarts[i].origin == weekly[j]) {
          weekly[j].sysRank = i + 1;
          weekly[j].update();
          break;
        }
      }
    }
  }

  List<Map<String, dynamic>> _recommendedSchedules(List<BusyHour> busys,
      Event current, Event before, Event after, int minHour, int maxHour) {
    List<Map<String, dynamic>> schedules = List<Map<String, dynamic>>();

    int startDay, endDay;
    int startHour, endHour;
    int startMin, endMin;
    double day, hour, minute;

    if (busys.length == 0) {
      // schedule after - schedule before
      startDay = before.day;
      endDay = after.day;
      startHour = before.timeEnd.hour;
      endHour = after.timeStart.hour;
      startMin = before.timeEnd.minute;
      endMin = after.timeStart.minute;

      _processSchedule(startDay, endDay, startHour, endHour, startMin, endMin,
          maxHour, minHour, current, schedules);
    } else {
      for (int i = 0; i <= busys.length; i++) {
        if (i == 0) {
          // first busy hour - schedule before
          startDay = before.day;
          endDay = busys[i].day;
          startHour = before.timeEnd.hour;
          endHour = busys[i].timeStart.hour;
          startMin = before.timeEnd.minute;
          endMin = busys[i].timeStart.minute;
        } else if (i == busys.length) {
          // schedule after - last busy hour
          startDay = busys[i - 1].day;
          endDay = after.day;
          startHour = busys[i - 1].timeEnd.hour;
          endHour = after.timeStart.hour;
          startMin = busys[i - 1].timeEnd.minute;
          endMin = after.timeStart.minute;
        } else {
          // busy hour (n) - busy hour (n-1)
          startDay = busys[i - 1].day;
          endDay = busys[i].day;
          startHour = busys[i - 1].timeEnd.hour;
          endHour = busys[i].timeStart.hour;
          startMin = busys[i - 1].timeEnd.minute;
          endMin = busys[i].timeStart.minute;
        }

        _processSchedule(startDay, endDay, startHour, endHour, startMin, endMin,
            maxHour, minHour, current, schedules);
      }
    }

    return schedules;
  }

  void _processSchedule(startDay, endDay, startHour, endHour, startMin, endMin,
      maxHour, minHour, current, schedules) {
    // recommended schedule must start after `minHour` and ended before `maxHour`
    if (startHour >= maxHour) {
      startDay += 1;
      startHour = minHour;
      startMin = 0;
    }
    if (endHour > maxHour || (endHour >= maxHour && endMin > 0)) {
      endHour = maxHour;
      endMin = 0;
    }

    double day = (endDay - startDay) * 24.0;
    double hour = (endHour - startHour).toDouble();
    double minute = (endMin - startMin) / 60.0;

    // if available duration long enough
    if ((day + hour + minute) > current.duration) {
      DateTime dateStart = current.date.add(Duration(
          days: startDay - current.date.weekday,
          hours: startHour,
          minutes: startMin));
      DateTime dateEnd =
          dateStart.add(Duration(minutes: (current.duration * 60).toInt()));

      schedules.add({
        'available': double.parse(
            (day + hour + minute).toStringAsFixed(2)), // 2 decimal places
        'dateStart': dateStart,
        'dateEnd': dateEnd,
      });
    }
  }

  // ------------------------------------------------------------------ //
  // ------------------------ WEIGHT UPDATE --------------------------- //
  // ------------------------------------------------------------------ //
  void updateWeight() async {
    _convertToSmarts(lastWeek);
    _standardizeSmarts();
    _updateSetting();

    _smarts.clear();
  }

  void _updateSetting() {
    EventSetting evset = globals.evsetSys;

    _smarts
        .sort((smart1, smart2) => smart1.userRank.compareTo(smart2.userRank));

    // compare all pairs
    List<double> ranges = [];
    List<double> durations = [];
    List<double> participants = [];
    List<double> involvements = [];

    for (int i = 0; i < _smarts.length - 1; i++) {
      EventSetting temporary = EventSetting(
          dateRange: evset.dateRange,
          duration: evset.duration,
          participant: evset.participant,
          involvement: evset.involvement);

      // if system's rank does not match user's rank then update
      if (_smarts[i].sysRank >= _smarts[i + 1].sysRank) {
        temporary = _updatePair(_smarts[i], _smarts[i + 1], temporary);
      }

      ranges.add(temporary.wDateRange);
      durations.add(temporary.wDuration);
      participants.add(temporary.wParticipant);
      involvements.add(temporary.wInvolvement);
    }

    // average pair-updated setting's attributes
    // double sum = evset.sum;
    // double avgDateRange = _average(ranges) * sum;
    // double avgDuration = _average(durations) * sum;
    // double avgParticipant = _average(participants) * sum;
    // double avgInvolvement = _average(involvements) * sum;

    // raw values
    List<double> averages = [];
    double sum = evset.sum;
    averages.add(_average(ranges) * sum);
    averages.add(_average(durations) * sum);
    averages.add(_average(participants) * sum);
    averages.add(_average(involvements) * sum);

    // minimum value is 0
    if (!averages.every((num) => num > 0)) {
      double negatives =
          averages.where((num) => num < 0).reduce((a, b) => a + b);
      double sum = averages.where((num) => num > 0).reduce((a, b) => a + b);

      // change negatives to 0 and decrease positives by proportioned-negatives
      averages = averages
          .map((num) => (num < 0) ? num = 0 : num += (negatives * (num / sum)))
          .toList();
    }

    // maximum value is 100
    while (!averages.every((num) => num <= 100)) {
      averages = averages.map((num) => num *= 0.8).toList();
    }

    // update original setting
    globals.evsetSys
        .updateWith(averages[0], averages[1], averages[2], averages[3]);
  }

  EventSetting _updatePair(
      SmartEvent smart1, SmartEvent smart2, EventSetting temporarySetting) {
    // subtract each attributes
    List<double> differences = List<double>()
      ..add(smart1.dateRange - smart2.dateRange)
      ..add(smart1.duration - smart2.duration)
      ..add(smart1.participant - smart2.participant)
      ..add(smart1.involvement - smart2.involvement);

    // divide positive and negative attributes, then sum up
    double positives =
        differences.where((diff) => diff >= 0).reduce((a, b) => a + b);
    double negatives = differences
        .where((diff) => diff < 0)
        .reduce((a, b) => a.abs() + b.abs());

    List<double> attributes = List<double>();
    for (int i = 0; i < differences.length; i++) {
      // increase or decrease
      double multiplier = (differences[i] >= 0) ? 1.0 : -1.0;
      // positive or negative divider
      double divider = (differences[i] >= 0) ? positives : negatives;
      // how much to increase or decrease
      double updater = (divider > 0)
          ? multiplier *
              (temporarySetting.rate * (differences[i].abs() / divider))
          : 0;

      switch (i) {
        case 0:
          attributes.add(
              (temporarySetting.wDateRange + updater) * temporarySetting.sum);
          break;
        case 1:
          attributes.add(
              (temporarySetting.wDuration + updater) * temporarySetting.sum);
          break;
        case 2:
          attributes.add(
              (temporarySetting.wParticipant + updater) * temporarySetting.sum);
          break;
        case 3:
          attributes.add(
              (temporarySetting.wInvolvement + updater) * temporarySetting.sum);
          break;
        default:
          break;
      }
    }

    temporarySetting.dateRange = attributes[0];
    temporarySetting.duration = attributes[1];
    temporarySetting.participant = attributes[2];
    temporarySetting.involvement = attributes[3];

    return temporarySetting;
  }

  double _average(List<double> list) {
    return list.reduce((a, b) => a + b) / list.length;
  }
}
