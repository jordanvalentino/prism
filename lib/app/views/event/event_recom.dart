import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class EventRecommendation extends StatefulWidget {
  final List<Map<String, dynamic>> _recommendations;
  EventRecommendation(this._recommendations);

  @override
  _EventRecommendationState createState() => _EventRecommendationState();
}

class _EventRecommendationState extends State<EventRecommendation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: colors.primary[500],
        body: SafeArea(
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(6, 6, 0, 0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.primary[50]),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 44),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        (widget._recommendations.length > 0)
                            ? MaterialCommunityIcons.getIconData(
                                'emoticon-excited-outline')
                            : MaterialCommunityIcons.getIconData(
                                'emoticon-cry-outline'),
                        color: colors.primary[800],
                        size: 50,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        (widget._recommendations.length > 0)
                            ? "GOOD NEWS!"
                            : "TOO BAD!",
                        style: TextStyle(
                          color: colors.primary[50],
                          fontFamily: 'FredokaOne',
                          fontSize:
                              Theme.of(context).textTheme.display1.fontSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                (widget._recommendations.length > 0)
                    ? "We found you some free time to reschedule."
                    : "We cannot find you a good time to reschedule.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.primary[700],
                  fontSize: Theme.of(context).textTheme.subhead.fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: (widget._recommendations.length > 0)
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget._recommendations.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: colors.primary[50],
                                    child: ListTile(
                                      title: Text(widget
                                          ._recommendations[index]['event']
                                          .dayString),
                                      subtitle: Text(
                                          "${widget._recommendations[index]['event'].timeStartString} - " +
                                              "${widget._recommendations[index]['event'].timeEndString}"),
                                      onTap: () => _chooseSchedule(widget
                                          ._recommendations[index]['event']),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
            ),
          ]),
        ));
  }

  void _chooseSchedule(Event event) {
    dialogs.yesNoDialog(context, "Choose this schedule?", title: "Reschedule",
        onYes: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, 'event_reschedule', arguments: event);
    });
  }
}
