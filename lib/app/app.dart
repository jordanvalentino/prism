import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:kilat/app/modules.dart';
import 'package:kilat/app/views/busyhour/busy_add.dart';
import 'package:kilat/app/views/busyhour/busy_edit.dart';
import 'package:kilat/app/views/busyhour/busy_list.dart';
import 'package:kilat/app/views/category/category_event.dart';
import 'package:kilat/app/views/category/category_task.dart';
import 'package:kilat/app/views/event/event_add.dart';
import 'package:kilat/app/views/event/event_detail.dart';
import 'package:kilat/app/views/event/event_edit.dart';
import 'package:kilat/app/views/event/event_recom.dart';
import 'package:kilat/app/views/event/event_reschedule.dart';
import 'package:kilat/app/views/help.dart';
import 'package:kilat/app/views/master.dart';
import 'package:kilat/app/views/preference/pref_event.dart';
import 'package:kilat/app/views/preference/pref_task.dart';
import 'package:kilat/app/views/preference/preference.dart';
import 'package:kilat/app/views/priority/priority_event.dart';
import 'package:kilat/app/views/priority/priority_task.dart';
import 'package:kilat/app/views/registration/signin.dart';
import 'package:kilat/app/views/registration/signup.dart';
import 'package:kilat/app/views/registration/signup_busy.dart';
import 'package:kilat/app/views/registration/signup_profile.dart';
import 'package:kilat/app/views/splashscreen.dart';
import 'package:kilat/app/views/task/task_add.dart';
import 'package:kilat/app/views/task/task_detail.dart';
import 'package:kilat/app/views/task/task_edit.dart';

import 'package:kilat/colors.dart' as colors;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        'signin': (context) => SignIn(accountBloc),
        'signup': (context) => SignUp(accountBloc),
        'signup_busy': (context) => SignUpBusy(busyBloc),
        'master_home': (context) => Master(accountBloc, activityBloc, 'home'),
        'busy_add': (context) => BusyAdd(busyBloc),
        'busy_list': (context) => BusyList(activityBloc),
        'category_task': (context) => CategoryTask(categoryBloc),
        'category_event': (context) => CategoryEvent(categoryBloc),
        'event_add': (context) => EventAdd(activityBloc),
        'event_detail': (context) => EventDetail(activityBloc),
        'task_add': (context) => TaskAdd(activityBloc),
        'task_detail': (context) => TaskDetail(activityBloc),
        'priority_event': (context) => PriorityEvent(activityBloc),
        'priority_task': (context) => PriorityTask(activityBloc),
        'preference': (context) => Preference(),
        'pref_event': (context) => PrefEvent(accountBloc),
        'pref_task': (context) => PrefTask(accountBloc),
        'help': (context) => Help(),
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case 'signup_profile':
            final arguments = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => SignUpProfile(accountBloc, arguments));
          case 'busy_edit':
            final arguments = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => BusyEdit(busyBloc, arguments));
          case 'event_edit':
            final arguments = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => EventEdit(activityBloc, arguments));
          case 'event_recommendation':
            final arguments = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => EventRecommendation(arguments));
          case 'event_reschedule':
            final arguments = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => EventReschedule(activityBloc, arguments));
          case 'task_edit':
            final arguments = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => TaskEdit(activityBloc, arguments));

          default:
            return MaterialPageRoute(
                builder: (_) => Scaffold(
                      body: SafeArea(
                        child: Center(
                            child: Text(
                                "Oops, it seems like this page doesn't exist.")),
                      ),
                    ));
        }
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          backgroundColor: Colors.white,
          fontFamily: 'Raleway',
          primarySwatch: colors.primary,
          accentColor: Colors.deepOrangeAccent,
          textTheme: TextTheme(
            button: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('en', 'GB'),
      ],
    );
  }
}
