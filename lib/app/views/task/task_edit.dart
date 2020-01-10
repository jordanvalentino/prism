import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/globals.dart' as globals;

class TaskEdit extends StatefulWidget {
  final ActivityBloc _bloc;
  final Task _task;
  TaskEdit(this._bloc, this._task);

  @override
  _TaskEditState createState() => _TaskEditState(this._task);
}

class _TaskEditState extends State<TaskEdit> {
  final _taskEditKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  Task _task;
  _TaskEditState(this._task);

  DateTime _date;
  TimeOfDay _time;
  DateTime _dateCreated;
  int _difficulty;
  int _benefit;
  // int _categoryId;

  @override
  void initState() {
    _titleController.text = _task.title;
    _date = _task.date;
    _time = _task.timeStart;
    // _categoryId = _task.categoryId;
    _dateCreated = _task.dateCreated;
    _difficulty = _task.difficulty;
    _benefit = _task.benefit;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              dialogs.yesNoDialog(context, "Discard changes?", onYes: () {
                Navigator.pop(context);
                Navigator.pop(context);
              });
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Save"),
              onPressed: _save,
            )
          ],
        ),
        body: Form(
          key: _taskEditKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Task Title",
                  contentPadding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline.fontSize),
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
                _dateTile(),
                _timeTile(),
                // _categoryTile(),
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
                  _dateCreatedTile(),
                  _difficultyTile(),
                  _benefitTile(),
                ],
              )
            ],
          ),
        ));
  }

  void _buildDatePicker(String type) async {
    DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: (type == 'date') ? _date : _dateCreated,
      locale: Locale('en', 'GB'),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime(2900, 12),
    );

    if (selectedDate == null) return;

    if (type == 'date') {
      if (selectedDate != _date) setState(() => _date = selectedDate);
    } else if (type == 'created') {
      if (selectedDate != _dateCreated)
        setState(() => _dateCreated = selectedDate);
    }

    // date created cannot be set after date
    if (_dateCreated.isAfter(_date)) {
      setState(() => _dateCreated = _date);
    }
  }

  void _buildTimePicker() async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (selectedTime == null) return;
    if (selectedTime.hour == null || selectedTime.minute == null) return;

    if (selectedTime != _time) setState(() => _time = selectedTime);
  }

  // void _onChangedCategory(int value) => setState(() => _categoryId = value);

  void _save() {
    Task replacement = Task(
      title:
          (_titleController.text.isEmpty) ? "Untitled" : _titleController.text,
      date: DateTime(_date.year, _date.month, _date.day),
      time: _time,
      dateCreated: _dateCreated,
      difficulty: _difficulty,
      benefit: _benefit,
      // categoryId: _categoryId,
      accountId: globals.account.id,
    );

    _onConfirmEdit(replacement);
  }

  _onConfirmEdit(Task replacement) {
    widget._bloc.update(_task, replacement);
    widget._bloc.taskBloc.updateTaskStreamWith(_task);

    Navigator.pop(context);
  }

  TableRow _dateTile() => TableRow(children: <TableCell>[
        IconCell(icon: Icons.calendar_today),
        TableCell(
          child: ListTile(
            title: Text("Date"),
            trailing: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Text(DateFormat("EEE, d MMM y").format(_date)),
                ),
                onTap: () => _buildDatePicker('date')),
          ),
        ),
      ]);

  TableRow _timeTile() => TableRow(children: [
        IconCell(icon: Icons.access_time),
        TableCell(
          child: ListTile(
            title: Text("Time"),
            trailing: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Text("${_time.toString().substring(10, 15)}"),
                ),
                onTap: _buildTimePicker),
          ),
        )
      ]);

  // TableRow _categoryTile() => TableRow(children: <TableCell>[
  //       IconCell(icon: MaterialCommunityIcons.getIconData('tag')),
  //       TableCell(
  //         child: ListTile(
  //           title: Text("Category"),
  //           trailing: Container(
  //             width: 110,
  //             child: DropdownButtonFormField(
  //               decoration: InputDecoration(border: InputBorder.none),
  //               onChanged: _onChangedCategory,
  //               value: _categoryId,
  //               items: globals.categories.tasks
  //                   .map((cat) => DropdownMenuItem(
  //                         child: Text(
  //                           cat.name,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                         value: cat.id,
  //                       ))
  //                   .toList(),
  //             ),
  //           ),
  //         ),
  //       )
  //     ]);

  TableRow _dateCreatedTile() => TableRow(children: <TableCell>[
        IconCell(icon: MaterialCommunityIcons.getIconData('calendar-edit')),
        TableCell(
          child: ListTile(
            title: Text("Date created"),
            trailing: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Text(DateFormat("EEE, d MMM y").format(_dateCreated)),
                ),
                onTap: () => _buildDatePicker('created')),
          ),
        ),
      ]);

  TableRow _difficultyTile() => TableRow(children: <TableCell>[
        IconCell(icon: MaterialCommunityIcons.getIconData('speedometer')),
        TableCell(
          child: ListTile(
              title: Text("Difficulty"),
              trailing: Container(
                width: 130,
                child: Slider(
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: _difficulty.toString(),
                  value: _difficulty.toDouble(),
                  onChanged: (value) =>
                      setState(() => _difficulty = value.toInt()),
                ),
              )),
        ),
      ]);

  TableRow _benefitTile() => TableRow(children: <TableCell>[
        IconCell(icon: MaterialCommunityIcons.getIconData('chart-line')),
        TableCell(
          child: ListTile(
              title: Text("Benefit"),
              trailing: Container(
                width: 130,
                child: Slider(
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: _benefit.toString(),
                  value: _benefit.toDouble(),
                  onChanged: (value) =>
                      setState(() => _benefit = value.toInt()),
                ),
              )),
        ),
      ]);
}
