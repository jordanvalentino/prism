import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Activity.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;
import 'package:table_calendar/table_calendar.dart';

class Home extends StatefulWidget {
  final ActivityBloc _bloc;

  Home(this._bloc);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  // TODO: replace this
  // example holidays //
  final Map<DateTime, List> _holidays = {
    DateTime(2019, 1, 1): ['New Year\'s Day'],
    DateTime(2019, 1, 6): ['Epiphany'],
    DateTime(2019, 2, 14): ['Valentine\'s Day'],
    DateTime(2019, 4, 21): ['Easter Sunday'],
    DateTime(2019, 4, 22): ['Easter Monday'],
  };
  // -- //

  AnimationController _animationController;
  CalendarController _calendarController;
  DateTime _selectedDay;

  @override
  void initState() {
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();

    _selectedDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedDay = DateTime(day.year, day.month, day.day);
    });
    widget._bloc.setSelectedDay(day);
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        StreamBuilder<Map<DateTime, dynamic>>(
            stream: widget._bloc.activitiesStream,
            initialData: widget._bloc.transform(globals.activities.list),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return TableCalendar(
                  calendarController: _calendarController,
                  events: snapshot.data,
                  holidays: _holidays,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  initialCalendarFormat: CalendarFormat.week,
                  weekendDays: [DateTime.sunday],
                  rowHeight: 50,
                  availableCalendarFormats: {
                    CalendarFormat.month: 'Month',
                    CalendarFormat.week: 'Week',
                  },
                  calendarStyle: CalendarStyle(
                    selectedColor: Colors.deepOrange[400],
                    todayColor: Colors.deepOrange[200],
                    markersColor: Colors.brown[700],
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonTextStyle: TextStyle()
                        .copyWith(color: Colors.white, fontSize: 15.0),
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.deepOrange[400],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onDaySelected: _onDaySelected,
                  onVisibleDaysChanged: _onVisibleDaysChanged,
                );
              }
              return CircularProgressIndicator();
            }),
        StreamBuilder<Map<DateTime, List<dynamic>>>(
            stream: widget._bloc.activitiesStream,
            initialData: widget._bloc.transform(globals.activities.list),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return snapshot.data[_selectedDay] == null
                      ? Center(
                          child: Text("Have some good time!"),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: snapshot.data[_selectedDay]
                              .map((activity) => (activity is Event)
                                  ? _buildEventCard(activity)
                                  : _buildTaskCard(activity))
                              .toList(),
                        );
                }
                return Center(
                  child: Text("Have some good time!"),
                );
              }
              return CircularProgressIndicator();
            }),
      ],
    );
  }

  void _onTapActivity(Activity activity) {
    if (activity is Event) {
      Event event =
          globals.activities.events.list.singleWhere((ev) => ev == activity);
      widget._bloc.eventBloc.updateEventStreamWith(event);

      Navigator.pushNamed(context, 'event_detail');
    } else if (activity is Task) {
      Task task =
          globals.activities.tasks.list.singleWhere((ts) => ts == activity);
      widget._bloc.taskBloc.updateTaskStreamWith(task);

      Navigator.pushNamed(context, 'task_detail');
    }
  }

  Widget _buildEventCard(activity) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colors.secondary[400]),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          activity.title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        subtitle:
            Text("${activity.timeStartString} - ${activity.timeEndString}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
        trailing: CircleAvatar(
          backgroundColor: colors.primary[50],
          child: (activity.sysRank != null)
              ? Text(
                  activity.sysRank.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : Container(),
        ),
        onTap: () => _onTapActivity(activity),
      ),
    );
  }

  Widget _buildTaskCard(activity) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: colors.accent[400]),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          activity.title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        subtitle: Text("${activity.timeStartString}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            )),
        trailing: CircleAvatar(
          backgroundColor: colors.primary[50],
          child: (activity.sysRank != null)
              ? Text(
                  activity.sysRank.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : Container(),
        ),
        onTap: () => _onTapActivity(activity),
      ),
    );
  }
}
