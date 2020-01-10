import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/globals.dart' as globals;

class TaskDetail extends StatefulWidget {
  final ActivityBloc _bloc;
  TaskDetail(this._bloc);

  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task"),
        actions: <Widget>[
          StreamBuilder<Task>(
              stream: widget._bloc.taskBloc.taskStream,
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
        child: StreamBuilder<Task>(
            stream: widget._bloc.taskBloc.taskStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: <Widget>[
                    TextFormField(
                      controller:
                          TextEditingController(text: snapshot.data.title),
                      decoration: InputDecoration(
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
                      _timeTile(snapshot.data.timeStart),
                      // _categoryTile(snapshot.data.categoryId,),
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
                        _difficultyTile(snapshot.data.difficulty),
                        _benefitTile(snapshot.data.benefit),
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

  void _onPopupMenuSelected(String value, Task task) {
    if (value == 'edit') {
      Navigator.pushNamed(context, 'task_edit', arguments: task);
    } else if (value == 'delete') {
      dialogs.yesNoDialog(context, "Are you sure?",
          title: "Delete",
          onYes: () {
            widget._bloc.delete(task);
            Navigator.popUntil(context, ModalRoute.withName('master_home'));
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

  TableRow _timeTile(TimeOfDay time) => TableRow(children: [
        IconCell(icon: Icons.access_time),
        TableCell(
          child: ListTile(
            title: Text("Time"),
            subtitle: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Text(time.toString().substring(10, 15))),
          ),
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
            subtitle: Padding(
              padding: EdgeInsets.only(right: 14),
              child: Text(DateFormat("EEE, d MMM y").format(dateCreated)),
            ),
          ),
        ),
      ]);

  TableRow _difficultyTile(int difficulty) => TableRow(children: <TableCell>[
        IconCell(icon: MaterialCommunityIcons.getIconData('speedometer')),
        TableCell(
          child: ListTile(
              title: Text("Difficulty"),
              subtitle: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Text(difficulty.toString()),
              )),
        ),
      ]);

  TableRow _benefitTile(int benefit) => TableRow(children: <TableCell>[
        IconCell(icon: MaterialCommunityIcons.getIconData('chart-line')),
        TableCell(
          child: ListTile(
              title: Text("Benefit"),
              subtitle: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Text(benefit.toString()),
              )),
        ),
      ]);
}
