import 'package:collection/collection.dart';
import 'package:kilat/app/blocs/bloc.dart';
import 'package:kilat/app/blocs/busy_bloc.dart';
import 'package:kilat/app/blocs/event_bloc.dart';
import 'package:kilat/app/blocs/task_bloc.dart';
import 'package:kilat/app/models/Activity.dart';
import 'package:kilat/globals.dart' as globals;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityBloc extends Bloc {
  final BusyBloc _busyBloc;
  final EventBloc _eventBloc;
  final TaskBloc _taskBloc;

  BusyBloc get busyBloc => _busyBloc;
  EventBloc get eventBloc => _eventBloc;
  TaskBloc get taskBloc => _taskBloc;

  PublishSubject<Map<DateTime, List<dynamic>>> _activitiesStream;
  BehaviorSubject<DateTime> _selectedDayStream;

  Observable<Map<DateTime, List<dynamic>>> get activitiesStream =>
      _activitiesStream.stream;
  Function(DateTime selectedDay) get setSelectedDay => _selectedDayStream.add;
  DateTime get selectedDay => _selectedDayStream.value;

  ActivityBloc(this._busyBloc, this._eventBloc, this._taskBloc);

  @override
  void init() {
    _activitiesStream = PublishSubject<Map<DateTime, List<dynamic>>>();
    _selectedDayStream = BehaviorSubject<DateTime>.seeded(DateTime.now());

    _busyBloc.init();
    _eventBloc.init();
    _taskBloc.init();
  }

  @override
  void dispose() {
    _activitiesStream.close();
    _selectedDayStream.close();

    _busyBloc.dispose();
    _eventBloc.dispose();
    _taskBloc.dispose();
  }

  void synchronize() {
    _busyBloc.synchronize();
    _eventBloc.synchronize();
    _taskBloc.synchronize();
  }

  void updateStream() {
    _activitiesStream.add(transform(globals.activities.list));
  }

  Map<DateTime, List<dynamic>> transform(List<Activity> activities) {
    Map<DateTime, List<dynamic>> map = groupBy(activities, (ac) => ac.dateOnly);
    return map;
  }

  Future fetchAll() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('busys')) await busyBloc.fetchAll();
    globals.busys.save();
    busyBloc.updateStream();

    if (!prefs.containsKey('events')) await eventBloc.fetchAll();
    globals.activities.events.save();
    updateStream();

    if (!prefs.containsKey('tasks')) await taskBloc.fetchAll();
    globals.activities.tasks.save();
    updateStream();
  }

  void add(dynamic item) {
    globals.activities.add(item);
    globals.activities.save();
    updateStream();
  }

  void update(dynamic old, dynamic replacement) {
    globals.activities.update(old, replacement);
    globals.activities.save();
    updateStream();
  }

  void delete(dynamic item) {
    globals.activities.delete(item);
    globals.activities.save();
    updateStream();
  }
}
