import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/globals.dart' as globals;

class EventDetail extends StatefulWidget {
  final ActivityBloc _bloc;
  EventDetail(this._bloc);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event"),
        actions: <Widget>[
          StreamBuilder<Event>(
              stream: widget._bloc.eventBloc.eventStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PopupMenuButton(
                    offset: Offset(0, 100),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text("Edit"),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text("Delete"),
                        value: 'delete',
                      ),
                      PopupMenuItem(
                        child: Text("Reschedule"),
                        value: 'reschedule',
                      ),
                    ],
                    onSelected: (value) =>
                        _onPopupMenuSelected(value, snapshot.data),
                  );
                }

                return Container();
              }),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<Event>(
            stream: widget._bloc.eventBloc.eventStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: <Widget>[
                    TextFormField(
                      controller:
                          TextEditingController(text: snapshot.data.title),
                      decoration: InputDecoration(
                        hintText: "Event Title",
                        contentPadding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.headline.fontSize),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 5, 0, 10),
                      child: Text("Detail"),
                    ),
                    Table(columnWidths: {
                      0: FlexColumnWidth(0.2),
                      1: FlexColumnWidth(0.8)
                    }, children: <TableRow>[
                      _dateTile(snapshot.data.date),
                      _timeTile(snapshot.data.timeStart, snapshot.data.timeEnd),
                      // _categoryTile(snapshot.data.categoryId),
                    ]),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 5, 0, 10),
                      child: Text("Additional"),
                    ),
                    Table(
                      columnWidths: {
                        0: FlexColumnWidth(0.2),
                        1: FlexColumnWidth(0.8)
                      },
                      children: <TableRow>[
                        _dateCreatedTile(snapshot.data.dateCreated),
                        _participantTile(snapshot.data.participant),
                        _involvementTile(snapshot.data.involvement),
                      ],
                    )
                  ],
                );
              }

              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  _onPopupMenuSelected(String value, Event event) {
    if (value == 'edit') {
      Navigator.pushNamed(context, 'event_edit', arguments: event);
    } else if (value == 'delete') {
      dialogs.yesNoDialog(context, "Are you sure?",
          title: "Delete",
          onYes: () {
            widget._bloc.delete(event);
            Navigator.popUntil(context, ModalRoute.withName('master_home'));
          },
          onNo: () => Navigator.pop(context));
    } else if (value == 'reschedule') {
      dialogs.yesNoDialog(context, "Reschedule this event?",
          title: "Reschedule",
          onYes: () {
            List<Map<String, dynamic>> recommendations =
                globals.activities.events.reschedule(event);

            Navigator.pop(context);
            Navigator.pushNamed(context, 'event_recommendation',
                arguments: recommendations);
          },
          onNo: () => Navigator.pop(context));
    }
  }

  TableRow _dateTile(DateTime date) => TableRow(children: <TableCell>[
        IconCell(icon: Icons.calendar_today),
        TableCell(
          child: ListTile(
              title: Text("Date"),
              subtitle: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Text(DateFormat("EEE, d MMM y").format(date)),
              )),
        ),
      ]);

  TableRow _timeTile(TimeOfDay startTime, TimeOfDay endTime) =>
      TableRow(children: [
        IconCell(icon: Icons.access_time),
        TableCell(
          child: ListTile(
              title: Text("Time"),
              subtitle: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Text(startTime.toString().substring(10, 15) +
                    " - " +
                    endTime.toString().substring(10, 15)),
              )),
        )
      ]);

  // TableRow _categoryTile(int categoryId) => TableRow(children: <TableCell>[
  //       IconCell(icon: MaterialCommunityIcons.getIconData('tag')),
  //       TableCell(
  //         child: ListTile(
  //             title: Text("Category"),
  //             subtitle: Padding(
  //               padding: EdgeInsets.only(right: 14),
  //               child: Text(globals.categories.list
  //                   .singleWhere((cat) => cat.id == categoryId)
  //                   .name),
  //             )),
  //       )
  //     ]);

  TableRow _dateCreatedTile(DateTime dateCreated) =>
      TableRow(children: <TableCell>[
        IconCell(icon: MaterialCommunityIcons.getIconData('calendar-edit')),
        TableCell(
          child: ListTile(
            title: Text("Date created"),
            subtitle: InkWell(
                child: Padding(
              padding: EdgeInsets.only(right: 14),
              child: Text(DateFormat("EEE, d MMM y").format(dateCreated)),
            )),
          ),
        ),
      ]);

  TableRow _participantTile(int participant) => TableRow(children: <TableCell>[
        IconCell(icon: Icons.group),
        TableCell(
          child: ListTile(
              title: Text("Participant(s)"),
              subtitle: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Text(participant.toString()),
              )),
        ),
      ]);

  TableRow _involvementTile(int involvement) => TableRow(children: <TableCell>[
        IconCell(icon: Icons.star),
        TableCell(
          child: ListTile(
              title: Text("Involvement"),
              subtitle: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Text(involvement.toString()))),
        ),
      ]);
}
