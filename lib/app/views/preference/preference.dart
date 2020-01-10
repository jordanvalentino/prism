import 'package:flutter/material.dart';

class Preference extends StatefulWidget {
  @override
  _PreferenceState createState() => _PreferenceState();
}

class _PreferenceState extends State<Preference> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          title: Text("Event Preferences"),
          onTap: _gotoPrefEvent,
        ),
        ListTile(
          title: Text("Task Preferences"),
          onTap: _gotoPrefTask,
        ),
      ],
    );
  }

  void _gotoPrefEvent() => Navigator.pushNamed(context, 'pref_event');

  void _gotoPrefTask() => Navigator.pushNamed(context, 'pref_task');
}
