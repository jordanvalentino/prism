import 'package:kilat/app/models/Activity.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/models/Events.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/models/Tasks.dart';
import 'package:kilat/globals.dart' as globals;

class Activities {
  List<Activity> _activities;
  Events _events;
  Tasks _tasks;

  // getters setters
  List<Activity> get all => _activities;
  List<Activity> get list => _activities.where((ac) => !ac.isDeleted).toList();

  Events get events => _events;
  Tasks get tasks => _tasks;

  // constructors
  Activities() {
    _activities = List<Activity>();
    _events = Events();
    _tasks = Tasks();
  }

  // methods
  void add(dynamic item) {
    all.add(item as Activity);

    if (item is Event) {
      events.add(item);
    } else if (item is Task) {
      tasks.add(item);
    }

    all.sort((a, b) => a.compareTo(b));
  }

  void update(dynamic old, dynamic replacement) {
    if (old is Event) {
      events.update(old, replacement);
    } else if (old is Task) {
      tasks.update(old, replacement);
    }

    all.sort((a, b) => a.compareTo(b));
  }

  void delete(dynamic item) {
    if (item is Event) {
      events.delete(item);
    } else if (item is Task) {
      tasks.delete(item);
    }
  }

  void save() {
    _events.save();
    _tasks.save();
  }

  Future load() async {
    await _events.load();
    await _tasks.load();

    _activities.addAll(_events.all);
    _activities.addAll(_tasks.all);

    _activities.sort((a, b) => a.compareTo(b));
  }

  void remove() {
    _events.remove();
    _tasks.remove();
  }
}
