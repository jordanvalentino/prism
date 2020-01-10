import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help me!"),
      ),
      body: ListView(
        children: <Widget>[
          _tileActivities(),
          _tileBusyHours(),
          _tilePriorities(),
          _tilePreferences(),
        ],
      ),
    );
  }

  _tileActivities() {
    return ExpansionTile(
      title: Text("Activities"),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _flexibleText("What is 'Activities' menu?", isTitle: true),
              _flexibleText(
                "In 'Activities', you can see and manage all of your events and tasks.\n",
              ),
              _flexibleText(
                "What is the difference between 'Event' and 'Task'?",
                isTitle: true,
              ),
              _flexibleText(
                  "Events are activities with duration (start and end) " +
                      "and tasks are one-timed activities without duration.\n"),
              _flexibleText("Why is there numbers on activities?",
                  isTitle: true),
              _flexibleText("The number on each activity is " +
                  "a 'priority rank' which represents how important an activity is. " +
                  "The smaller the number, the more important it is. " +
                  "Events and tasks have separate ranking system.\n"),
              _flexibleText("What is 'Additional' inputs on 'Add' page?",
                  isTitle: true),
              _flexibleText("Additional inputs will be used by PRISM to " +
                  "determine the priority of each activity.\n"),
              _flexibleText("What are 'Date Created'?", isTitle: true),
              _flexibleText(
                  "'Date Created' is the date when activity was created.\n"),
              _flexibleText("What is 'Participant'?", isTitle: true),
              _flexibleText(
                  "'Participant' is the number of person who will be affected by your attendance.\n"),
              _flexibleText("What is 'Involvement'?", isTitle: true),
              _flexibleText(
                  "'Involvement' is a personal score of how important your attendance in the event.\n"),
              _flexibleText("What is 'Difficulty'?", isTitle: true),
              _flexibleText(
                  "'Difficulty' is a personal score of how difficult the task to be completed.\n"),
              _flexibleText("What is 'Benefit'?", isTitle: true),
              _flexibleText(
                  "'Benefit' is a personal score of how much benefit you gained " +
                      "by completing the task or how high the risk of not completing the task."),
            ],
          ),
        )
      ],
    );
  }

  _tileBusyHours() {
    return ExpansionTile(
      title: Text("Busy Hours"),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _flexibleText("What is 'Busy Hours' menu?", isTitle: true),
              _flexibleText(
                "In 'Busy Hours', you can see and manage all of your busy hours.\n",
              ),
              _flexibleText(
                "What is busy hour?",
                isTitle: true,
              ),
              _flexibleText(
                  "Busy hours are reserved hours for primary activities " +
                      "which will be treated as top priority schedules. " +
                      "(e.g. routines, office hours, or school hours) " +
                      "If any new activity scheduled at these hours, " +
                      "you will get notified immediately.\n"),
            ],
          ),
        )
      ],
    );
  }

  _tilePriorities() {
    return ExpansionTile(
      title: Text("My Priorities"),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _flexibleText("What is 'My Priorities' menu?", isTitle: true),
              _flexibleText(
                "In 'My Priorities', you can configure your own 'priority rank' list " +
                    "by changing the order of the activity tiles.\n",
              ),
              _flexibleText(
                "How do I change the activity tiles order?",
                isTitle: true,
              ),
              _flexibleText(
                  "You can change the order by hold-pressing the activity tile " +
                      "and then drag-and-drop it somewhere else.\n"),
              _flexibleText(
                  "Why the numbers on the activity tiles don't change?",
                  isTitle: true),
              _flexibleText(
                  "The numbers on activity tiles represent system's 'priority ranks', " +
                      "while the order of the activity tiles represents your 'priority ranks'.\n"),
            ],
          ),
        )
      ],
    );
  }

  _tilePreferences() {
    return ExpansionTile(
      title: Text("My Preferences"),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _flexibleText("What is 'My Preferences' menu?", isTitle: true),
              _flexibleText(
                "In 'My Preferences', you can see how" +
                    "the system calculate each activity's priority.\n",
              ),
              _flexibleText(
                "What is 'Advanced Mode'?",
                isTitle: true,
              ),
              _flexibleText(
                  "With advanced mode, you can change the behaviour of " +
                      "the system's priority calculation process by manually " +
                      "adjusting each criteria's importance weight.\n"),
            ],
          ),
        )
      ],
    );
  }

  _flexibleText(String text, {isTitle = false}) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            child: Text(
              text,
              style: TextStyle(
                  fontWeight: (isTitle) ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        )
      ],
    );
  }
}
