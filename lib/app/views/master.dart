import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:kilat/app/blocs/account_bloc.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/models/Activities.dart';
import 'package:kilat/app/models/BusyHours.dart';
import 'package:kilat/app/models/Categories.dart';
import 'package:kilat/app/models/Category.dart';
import 'package:kilat/app/models/EventSetting.dart';
import 'package:kilat/app/models/TaskSetting.dart';
import 'package:kilat/app/views/busyhour/busy_list.dart';
import 'package:kilat/app/views/home.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/app/views/preference/preference.dart';
import 'package:kilat/app/views/priority/priority_event.dart';
import 'package:kilat/app/views/priority/priority_task.dart';
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class Master extends StatefulWidget {
  final AccountBloc _accBloc;
  final ActivityBloc _actBloc;
  final String _route;

  Master(this._accBloc, this._actBloc, this._route);

  @override
  _MasterState createState() => _MasterState(this._route);
}

class _MasterState extends State<Master> with TickerProviderStateMixin {
  String _route;
  _MasterState(this._route);

  IconData _fabIcons = Icons.add;

  Timer cron;

  @override
  void initState() {
    widget._accBloc.init();
    widget._actBloc.init();

    _initialize();

    super.initState();
  }

  @override
  void dispose() {
    cron.cancel();
    super.dispose();
  }

  void onPageChangeCallback(String newRoute) {
    if (_route != newRoute) setState(() => _route = newRoute);
  }

  void onStreamChange() {
    widget._actBloc.updateStream();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getPageTitle()),
        ),
        drawer: Drawer(
          child: ListView(
            shrinkWrap: true,
            children: _buildDrawerItems(context),
          ),
        ),
        body: SingleChildScrollView(
          child: _buildBody(),
        ),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    return [
      Container(
        height: 150,
        decoration: BoxDecoration(color: colors.primary[500]),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 32,
                          ),
                          radius: 28,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 28),
                    child: Row(
                      children: <Widget>[
                        Text(
                          globals.account.name.toUpperCase(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListTile(
            title: Text("Activities"),
            onTap: () {
              setState(() => _route = 'home');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Busy Hours"),
            onTap: () {
              setState(() => _route = 'busy');
              Navigator.pop(context);
            },
          ),
          ExpansionTile(
            title: Text("My Priorities"),
            children: <Widget>[
              ListTile(
                title: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Events"),
                ),
                onTap: _gotoPriorityEvent,
              ),
              ListTile(
                title: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Tasks"),
                ),
                onTap: _gotoPriorityTask,
              )
            ],
          ),
          ListTile(
            title: Text("My Preferences"),
            onTap: _gotoPreference,
          ),
          ListTile(
            title: Text("Help me"),
            onTap: _gotoHelp,
          ),
          ListTile(
              title: Text("Sign Out"),
              onTap: () {
                dialogs.yesNoDialog(context, "Are you sure want to sign out?",
                    title: "Sign Out",
                    onNo: () => Navigator.pop(context),
                    onYes: _signout);
              }),
        ],
      ),
    ];
  }

  _getPageTitle() {
    switch (_route) {
      case 'home':
        return "Activities";
        break;
      case 'busy':
        return "Busy Hours";
        break;
      case 'priority_event':
        return 'Event Priorities';
        break;
      case 'priority_task':
        return 'Task Priorities';
        break;
      case 'evcat':
        return "Event Category";
        break;
      case 'tacat':
        return "Task Category";
        break;
      case 'preference':
        return "My Preferences";
        break;
      default:
        return "Undefined";
        break;
    }
  }

  _buildBody() {
    switch (_route) {
      case 'home':
        return Home(widget._actBloc);
        break;
      case 'busy':
        return BusyList(widget._actBloc);
        break;
      case 'priority_event':
        return PriorityEvent(widget._actBloc);
        break;
      case 'priority_task':
        return PriorityTask(widget._actBloc);
        break;
      case 'preference':
        return Preference();
        break;
      default:
        break;
    }
  }

  _buildFab() {
    if (_route == 'home') {
      return SpeedDial(
        child: Icon(_fabIcons),
        onOpen: () => setState(() => _fabIcons = Icons.close),
        onClose: () => setState(() => _fabIcons = Icons.add),
        children: _buildFabActions(),
      );
    } else if (_route == 'busy') {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, 'busy_add'),
      );
    }
  }

  _buildFabActions() {
    return [
      SpeedDialChild(
          child: Icon(Icons.event),
          backgroundColor: Colors.deepOrange[400],
          label: 'Event',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => Navigator.pushNamed(context, 'event_add')),
      SpeedDialChild(
          child: Icon(MaterialCommunityIcons.getIconData('clock-fast')),
          backgroundColor: Colors.deepOrange[400],
          label: 'Task',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => Navigator.pushNamed(context, 'task_add')),
    ];
  }

  void _initialize() async {
    await widget._actBloc.fetchAll();

    if (globals.today.weekday != DateTime.sunday &&
        (globals.today.difference(globals.evsetSys.lastUpdated).inDays > 7) &&
        (globals.today.difference(globals.tasetSys.lastUpdated).inDays > 7)) {
      await widget._accBloc.updateSettings();

      if (globals.activities.events.thisWeek.length > 0)
        globals.activities.events.rank(globals.activities.events.thisWeek);
      if (globals.activities.tasks.thisWeek.length > 0)
        globals.activities.tasks.rank(globals.activities.tasks.thisWeek);
    }

    widget._actBloc.updateStream();

    _startSyncCron();
  }

  void _startSyncCron() {
    Timer.run(() => _cronCallback);
    cron = Timer.periodic(Duration(seconds: 10), _cronCallback);
  }

  void _cronCallback(Timer timer) {
    widget._accBloc.synchronize();
    widget._actBloc.synchronize();
  }

  void _signout() async {
    globals.pref.clear();

    globals.account = Account();
    globals.activities = Activities();
    globals.busys = BusyHours();
    globals.categories = Categories();
    globals.evsetSys = EventSetting();
    globals.evsetUser = EventSetting();
    globals.tasetSys = TaskSetting();
    globals.tasetUser = TaskSetting();

    _gotoSplash();
  }

  void _gotoSplash() => Navigator.pushNamedAndRemoveUntil(
      context, '/', (Route<dynamic> route) => false);

  void _gotoPriorityEvent() {
    Navigator.pop(context);
    setState(() => _route = 'priority_event');
  }

  void _gotoPriorityTask() {
    Navigator.pop(context);
    setState(() => _route = 'priority_task');
  }

  void _gotoPreference() {
    Navigator.pop(context);
    setState(() => _route = 'preference');
  }

  void _gotoHelp() {
    Navigator.pop(context);
    Navigator.pushNamed(context, 'help');
  }
}
