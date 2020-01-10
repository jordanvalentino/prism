import 'package:date_util/date_util.dart';
import 'package:kilat/app/blocs/bloc.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/models/Events.dart';
import 'package:kilat/app/networks/event_repository.dart';
import 'package:kilat/globals.dart' as globals;
import 'package:rxdart/rxdart.dart';

class EventBloc extends Bloc {
  final EventRepository _eventRepository;

  EventBloc(this._eventRepository);

  BehaviorSubject<Event> _eventSubject;
  PublishSubject<List<Event>> _eventsSubject;

  Observable<Event> get eventStream => _eventSubject.stream;
  Observable<List<Event>> get eventsStream => _eventsSubject.stream;

  Function(Event event) get updateEventStreamWith => _eventSubject.add;

  Event get eventStreamValue => _eventSubject.stream.value;

  @override
  void init() {
    _eventSubject = BehaviorSubject<Event>();
    _eventsSubject = PublishSubject<List<Event>>();
  }

  @override
  void dispose() {
    _eventSubject.close();
    _eventsSubject.close();
  }

  // void updateStream() {
  //   _eventSubject.add(globals.events.list);
  // }

  void synchronize() {
    globals.activities.events.offline.forEach((ev) async {
      await _eventRepository.add(ev).then((value) {
        ev.id = value;
        ev.updated();
      }).catchError((e) {
        print(e);
      });
    });

    globals.activities.events.updated.forEach((ev) async {
      await _eventRepository.edit(ev).then((value) {
        ev.updated();
      }).catchError((e) {
        print(e);
      });
    });

    globals.activities.events.save();
  }

  fetchAll() async {
    // List<DateTime> range = _threeMonths();
    try {
      await _eventRepository.fetchAll(globals.account.id).then((value) {
        value.forEach((val) {
          globals.activities.add(val);
        });
      });
    } catch (e) {
      print(e);
    }
  }

  List<DateTime> _threeMonths() {
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

    // fetch all events within 3 months range
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
