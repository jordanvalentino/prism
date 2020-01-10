import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/custom_time.dart' as times;
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/globals.dart' as globals;

class EventReschedule extends StatefulWidget {
  final ActivityBloc _bloc;
  final Event _event;
  EventReschedule(this._bloc, this._event);

  @override
  _EventRescheduleState createState() => _EventRescheduleState(_event);
}

class _EventRescheduleState extends State<EventReschedule> {
  final _eventReKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _participantContoller = TextEditingController();

  Event _event;
  _EventRescheduleState(this._event);

  DateTime _date;
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  DateTime _dateCreated;
  int _participant;
  int _involvement;
  // int _categoryId;

  @override
  void initState() {
    _titleController.text = "${_event.title}";
    _date = _event.date;
    _startTime = _event.timeStart;
    _endTime = _event.timeEnd;
    // _categoryId = _event.categoryId;
    _dateCreated = _event.dateCreated;
    _participant = _event.participant;
    _involvement = _event.involvement;

    _participantContoller.text = "$_participant";

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
          key: _eventReKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Event Title",
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
                _startTimeTile(),
                _endTimeTile(),
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
                  _participantTile(),
                  _involvementTile(),
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

  void _buildTimePicker(String type) async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: type == 'start' ? _startTime : _endTime,
    );

    if (selectedTime == null) return;
    if (selectedTime.hour == null || selectedTime.minute == null) return;

    List<TimeOfDay> startEndTime;
    if (type == 'start')
      startEndTime = times.compareStartEndTime(type, selectedTime, _endTime);
    else if (type == 'end')
      startEndTime = times.compareStartEndTime(type, _startTime, selectedTime);
    setState(() {
      _startTime = startEndTime[0];
      _endTime = startEndTime[1];
    });
  }

  // void _onChangedCategory(int value) => setState(() => _categoryId = value);

  void _minusParticipant() {
    setState(() {
      _participant--;
      _participantContoller.text = "$_participant";
    });
  }

  void _plusParticipant() {
    setState(() {
      _participant++;
      _participantContoller.text = "$_participant";
    });
  }

  void _onChangedParticipant(String value) {
    if (int.parse(value) < 1)
      setState(() => _participant = 1);
    else if (int.parse(value) >= 1)
      setState(() => setState(() => _participant = int.parse(value)));

    setState(() => _participantContoller.text = "$_participant");
  }

  void _onEditingCompleteParticipant() {
    if (_participantContoller.text.isEmpty) {
      setState(() {
        _participant = 1;
        _participantContoller.text = "$_participant";
      });
    }
  }

  String _participantValidator(String value) {
    if (value.isEmpty) return "";
    return null;
  }

  void _save() async {
    _event = Event(
      title:
          (_titleController.text.isEmpty) ? "Untitled" : _titleController.text,
      date: _date,
      timeStart: _startTime,
      timeEnd: _endTime,
      dateCreated: _dateCreated,
      participant: _participant,
      involvement: _involvement,
      // categoryId: _categoryId,
      accountId: globals.account.id,
    );

    if (_event.hasCollisionWithEvents(globals.activities.events.list, _event) ||
        _event.hasCollisionWithBusys(globals.busys.list)) {
      dialogs.yesNoDialog(
          context, "Schedule overlapped.\nContinue to reschedule event?",
          title: "Warning",
          onYes: () {
            _onConfirmReschedule();
          },
          onNo: () => Navigator.pop(context));

      return;
    }

    _onConfirmReschedule();
  }

  _onConfirmReschedule() {
    widget._bloc.delete(widget._bloc.eventBloc.eventStreamValue);
    widget._bloc.add(_event);
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

  TableRow _startTimeTile() => TableRow(children: [
        IconCell(icon: Icons.access_time),
        TableCell(
          child: ListTile(
            title: Text("Start time"),
            trailing: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Text(_startTime.toString().substring(10, 15)),
                ),
                onTap: () => _buildTimePicker('start')),
          ),
        )
      ]);

  TableRow _endTimeTile() => TableRow(children: [
        TableCell(child: Container()),
        TableCell(
          child: ListTile(
            title: Text("End time"),
            trailing: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Text(_endTime.toString().substring(10, 15)),
                ),
                onTap: () => _buildTimePicker('end')),
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
  //               items: globals.categories.events
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

  TableRow _participantTile() => TableRow(children: <TableCell>[
        IconCell(icon: Icons.group),
        TableCell(
          child: ListTile(
              title: Text("Participant(s)"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Visibility(
                    visible: (_participant > 1),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: _minusParticipant,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 20,
                      child: TextFormField(
                        autofocus: false,
                        autovalidate: true,
                        controller: _participantContoller,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        textAlign: TextAlign.center,
                        onChanged: _onChangedParticipant,
                        onEditingComplete: _onEditingCompleteParticipant,
                        validator: _participantValidator,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _plusParticipant,
                  ),
                ],
              )),
        ),
      ]);

  TableRow _involvementTile() => TableRow(children: <TableCell>[
        IconCell(icon: Icons.star),
        TableCell(
          child: ListTile(
              title: Text("Involvement"),
              trailing: Container(
                width: 130,
                child: Slider(
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: _involvement.toString(),
                  value: _involvement.toDouble(),
                  onChanged: (value) =>
                      setState(() => _involvement = value.toInt()),
                ),
              )),
        ),
      ]);
}
