import 'package:date_util/date_util.dart';
import 'package:kilat/app/blocs/bloc.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/models/Tasks.dart';
import 'package:kilat/app/networks/task_repository.dart';
import 'package:kilat/globals.dart' as globals;
import 'package:rxdart/rxdart.dart';

class TaskBloc extends Bloc {
  final TaskRepository _taskRepository;

  TaskBloc(this._taskRepository);

  BehaviorSubject<Task> _taskSubject;
  PublishSubject<List<Task>> _tasksSubject;

  Observable<Task> get taskStream => _taskSubject.stream;
  Observable<List<Task>> get tasksStream => _tasksSubject.stream;

  Function(Task task) get updateTaskStreamWith => _taskSubject.add;

  @override
  void init() {
    _taskSubject = BehaviorSubject<Task>();
    _tasksSubject = PublishSubject<List<Task>>();
  }

  @override
  void dispose() {
    _taskSubject.close();
    _tasksSubject.close();
  }

  // void updateStream() {
  //   _taskSubject.add(globals.tasks.list);
  // }

  void synchronize() {
    globals.activities.tasks.offline.forEach((ts) async {
      await _taskRepository.add(ts).then((value) {
        ts.id = value;
        ts.updated();
      }).catchError((e) {
        print(e);
      });
    });

    globals.activities.tasks.updated.forEach((ts) async {
      await _taskRepository.edit(ts).then((value) {
        ts.updated();
      }).catchError((e) {
        print(e);
      });
    });

    globals.activities.tasks.save();
  }

  fetchAll() async {
    // List<DateTime> range = _getRange();
    try {
      await _taskRepository.fetchAll(globals.account.id).then((value) {
        value.forEach((val) {
          globals.activities.add(val);
        });
      });
    } catch (e) {
      print(e);
    }
  }

  List<DateTime> _getRange() {
    DateUtil util = DateUtil();

    DateTime now = DateTime.now();

    // if current month is january, previous month will be december year-1
    int startMon =
        (now.month == DateTime.january) ? DateTime.december : now.month - 1;
    int startYear = (now.month == DateTime.january) ? now.year - 1 : now.year;

    // if current month is december, next month will be january year+1
    int endMon =
        (now.month == DateTime.december) ? DateTime.january : now.month + 1;
    int endYear = (now.month == DateTime.december) ? now.year + 1 : now.year;

    // fetch all tasks within 3 months range
    DateTime start = DateTime(startYear, startMon, 1);
    DateTime end = DateTime(endYear, endMon, util.daysInMonth(endMon, endYear));

    // we need weekly (monday - sunday) schedule so:
    // if first day is not monday, subtract until monday
    // if last day is not sunday, add until sunday
    if (start.day != DateTime.monday) {
      start = start.subtract(Duration(days: start.day - DateTime.monday));
    }
    if (end.day != DateTime.sunday) {
      end = end.add(Duration(days: DateTime.sunday - end.day));
    }

    return [start, end];
  }
}
