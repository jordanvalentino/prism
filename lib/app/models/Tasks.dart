import 'dart:math';

import 'package:kilat/app/models/SmartTask.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/models/TaskSetting.dart';
import 'package:kilat/globals.dart' as globals;

class Tasks {
  List<Task> _tasks;
  List<SmartTask> _smarts;

  List<Task> get all => _tasks;
  List<Task> get list => _tasks.where((ts) => !ts.isDeleted).toList();
  set oldList(List<Task> newList) => _tasks = newList;

  List<Task> get online => all.where((ts) => ts.id != null).toList();
  List<Task> get offline => all.where((ts) => ts.id == null).toList();
  List<Task> get updated => online.where((ts) => ts.isUpdated).toList();
  List<Task> get thisWeek => list
      .where((ts) =>
          (ts.date.isAfter(globals.thisMonday.subtract(Duration(days: 1))) &&
              ts.date.isBefore(globals.nextMonday)))
      .toList();

  List<Task> get lastWeek => list
      .where((ts) =>
          (ts.date.isAfter(globals.lastMonday.subtract(Duration(days: 1))) &&
              ts.date.isBefore(globals.thisMonday)))
      .toList();

  // constructors
  Tasks() {
    _tasks = new List<Task>();
  }

  Tasks.fromList(List<Task> list) : _tasks = list;

  // methods
  void add(Task task) {
    all.add(task);

    List<Task> weekly = list.where((ts) => ts.week == task.week).toList();
    rank(weekly);
    all.sort((a, b) => a.compareTo(b));
  }

  void update(Task old, Task replacement) {
    int oldWeek = old.week;
    int newWeek = replacement.week;

    list.singleWhere((ts) => ts == old).replaceWith(replacement);

    // re-rank new weekly schedule
    List<Task> weekly =
        list.where((ts) => ts.week == replacement.week).toList();
    rank(weekly);

    // re-rank old weekly schedule if not the same as new week and not in the past week
    if ((oldWeek != newWeek) && old.date.isAfter(globals.thisMonday)) {
      List<Task> weekly = list.where((ts) => ts.week == oldWeek).toList();
      rank(weekly);
    }

    all.sort((a, b) => a.compareTo(b));
  }

  void delete(Task task) {
    list.singleWhere((ts) => ts == task).delete();

    List<Task> weekly = list.where((ts) => ts.week == task.week).toList();
    if (weekly.length > 0) rank(weekly);
  }

  void save() {
    globals.pref.save('tasks', _tasks);
  }

  Future load() async {
    await globals.pref.load('tasks').then((json) {
      _tasks = List<Task>.from(json.map((m) => Task.fromJson(m)));
    });
  }

  void remove() {
    globals.pref.remove('tasks');
  }

  // custom methods
  void _convertToSmarts(List<Task> weekly) {
    _smarts = new List<SmartTask>();

    weekly.forEach((ts) {
      _smarts.add(ts.toSmartObject());
    });
  }

  void _standardizeSmarts() {
    // standardize all attribute-values (maximize function)
    List<double> ranges =
        _standardize(_smarts.map((ts) => ts.dateRange).toList());
    List<double> difficulties =
        _standardize(_smarts.map((ts) => ts.difficulty).toList());
    List<double> benefits =
        _standardize(_smarts.map((ts) => ts.benefit).toList());

    for (int i = 0; i < _smarts.length; i++) {
      _smarts[i].dateRange = ranges[i];
      _smarts[i].difficulty = difficulties[i];
      _smarts[i].benefit = benefits[i];
    }
  }

  List<double> _standardize(List<double> values) {
    double maxValue = values.reduce(max);
    double minValue = values.reduce(min);

    List<double> standards = List<double>();
    values.forEach((val) {
      double result = (val - minValue) / (maxValue - minValue) * 100.0;
      standards.add(result.isNaN ? 0 : result);
    });

    return standards;
  }

  // ------------------------------------------------------------------ //
  // -------------------------- SMART RANK ---------------------------- //
  // ------------------------------------------------------------------ //
  void rank(List<Task> weekly) {
    _convertToSmarts(weekly);
    _standardizeSmarts();
    _scoreSmarts();
    _rankWeekly(weekly);

    _smarts.clear();

    // Q: needed? or just leave it to null
    // listWeek.forEach((ev) => ev.userRank = ev.sysRank);
  }

  void _scoreSmarts() {
    // determine which event setting to use
    TaskSetting taset = globals.account.taset;

    for (int i = 0; i < _smarts.length; i++) {
      _smarts[i].dateRange *= taset.wDateRange;
      _smarts[i].difficulty *= taset.wDifficulty;
      _smarts[i].benefit *= taset.wBenefit;
    }
  }

  void _rankWeekly(List<Task> weekly) {
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
  // ------------------------ WEIGHT UPDATE --------------------------- //
  // ------------------------------------------------------------------ //
  void updateWeight() async {
    _convertToSmarts(lastWeek);
    _standardizeSmarts();
    _updateSetting();

    _smarts.clear();
  }

  void _updateSetting() {
    TaskSetting taset = globals.tasetSys;

    _smarts
        .sort((smart1, smart2) => smart1.userRank.compareTo(smart2.userRank));

    // compare all pairs
    List<double> ranges = [];
    List<double> difficulties = [];
    List<double> benefits = [];

    for (int i = 0; i < _smarts.length - 1; i++) {
      TaskSetting temporary = TaskSetting(
          dateRange: taset.dateRange,
          difficulty: taset.difficulty,
          benefit: taset.benefit);

      // if system's rank does not match user's rank then update
      if (_smarts[i].sysRank >= _smarts[i + 1].sysRank) {
        temporary = _updatePair(_smarts[i], _smarts[i + 1], temporary);
      }

      ranges.add(temporary.wDateRange);
      difficulties.add(temporary.wDifficulty);
      benefits.add(temporary.wBenefit);
    }

    // average pair-updated setting's attributes
    // double sum = taset.sum;
    // double avgDateRange = _average(ranges) * sum;
    // double avgDifficulty = _average(difficulties) * sum;
    // double avgBenefit = _average(benefits) * sum;

    // raw values
    List<double> averages = [];
    double sum = taset.sum;
    averages.add(_average(ranges) * sum);
    averages.add(_average(difficulties) * sum);
    averages.add(_average(benefits) * sum);

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
    globals.tasetSys.updateWith(averages[0], averages[1], averages[2]);
  }

  TaskSetting _updatePair(
      SmartTask smart1, SmartTask smart2, TaskSetting temporarySetting) {
    // subtract each attributes
    List<double> differences = List<double>()
      ..add(smart1.dateRange - smart2.dateRange)
      ..add(smart1.difficulty - smart2.difficulty)
      ..add(smart1.benefit - smart2.benefit);

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
              (temporarySetting.wDifficulty + updater) * temporarySetting.sum);
          break;
        case 2:
          attributes.add(
              (temporarySetting.wBenefit + updater) * temporarySetting.sum);
          break;
        default:
          break;
      }
    }

    temporarySetting.dateRange = attributes[0];
    temporarySetting.difficulty = attributes[1];
    temporarySetting.benefit = attributes[2];

    return temporarySetting;
  }

  double _average(List<double> list) {
    return list.reduce((a, b) => a + b) / list.length;
  }
}
