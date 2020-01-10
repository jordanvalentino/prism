import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/globals.dart' as globals;

class TaskAdd extends StatefulWidget {
  final ActivityBloc _bloc;
  TaskAdd(this._bloc);

  @override
  _TaskAddState createState() => _TaskAddState();
}

class _TaskAddState extends State<TaskAdd> {
  final _taskAddKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  Task _task;
  // bool _allDay = false;
  DateTime _date;
  TimeOfDay _time;
  DateTime _dateCreated;
  int _difficulty;
  int _benefit;
  // int _categoryId;

  @override
  void initState() {
    _date = widget._bloc.selectedDay;
    _time = TimeOfDay(hour: TimeOfDay.now().hour, minute: 00);
    // _categoryId = globals.categories.tasks[0].id;
    _dateCreated = widget._bloc.selectedDay;
    _difficulty = 5;
    _benefit = 50;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              dialogs.yesNoDialog(context, "Discard changes?",
                  onYes: () => Navigator.popUntil(
                      context, ModalRoute.withName('master_home')));
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
          key: _taskAddKey,
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
    _task = Task(
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

    _onConfirmAdd();
  }

  _onConfirmAdd() {
    widget._bloc.add(_task);
    Navigator.popUntil(context, ModalRoute.withName('master_home'));
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
                  child: Text(_time.toString().substring(10, 15)),
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
