import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/busy_bloc.dart';
import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/models/BusyHours.dart';
import 'package:kilat/app/views/custom_materials/custom_time.dart' as times;
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/constants.dart' as cons;
import 'package:kilat/globals.dart' as globals;

class BusyEdit extends StatefulWidget {
  final BusyBloc _bloc;
  final BusyHour _busy;
  BusyEdit(this._bloc, this._busy);

  @override
  _BusyEditState createState() => _BusyEditState(this._busy);
}

class _BusyEditState extends State<BusyEdit> {
  final _busyAddKey = GlobalKey<FormState>();

  BusyHour _busy;
  int _day;
  TimeOfDay _startTime;
  TimeOfDay _endTime;

  _BusyEditState(this._busy);

  @override
  void initState() {
    widget._bloc.init();
    _day = _busy.day;
    _startTime =
        TimeOfDay(hour: _busy.timeStart.hour, minute: _busy.timeStart.minute);
    _endTime =
        TimeOfDay(hour: _busy.timeEnd.hour, minute: _busy.timeEnd.minute);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: colors.primary[50],
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                dialogs.yesNoDialog(context, "Discard changes?", onYes: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                })),
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
            onPressed: () =>
                dialogs.yesNoDialog(context, "Save changes?", onYes: _save),
          )
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _busyAddKey,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("Day"),
                trailing: Text(cons.days[_day - 1]),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                onTap: () => _buildDaysSheet(context),
              ),
              ListTile(
                title: Text("Start Time"),
                trailing: Text(_startTime.toString().substring(10, 15)),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                onTap: () => _buildTimePicker(context, 'start'),
              ),
              ListTile(
                title: Text("End Time"),
                trailing: Text(_endTime.toString().substring(10, 15)),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                onTap: () => _buildTimePicker(context, 'end'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _buildDaysSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cons.days.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cons.days[index]),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  onTap: () {
                    setState(() => _day = index + 1);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          );
        });
  }

  void _buildTimePicker(BuildContext context, String type) async {
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

  void _save() {
    Navigator.pop(context);
    BusyHour replacement = BusyHour(
      day: _day,
      timeStart: _startTime,
      timeEnd: _endTime,
    );

    if (replacement.hasCollisionWithBusys(globals.busys.list, _busy) ||
        replacement.hasCollisionWithEvents(globals.activities.events.list)) {
      dialogs.alertDialog(context, "Schedule overlapped with other busy hour.",
          onConfirm: () => Navigator.pop(context));

      return;
    }

    _onConfirmEdit(replacement);
  }

  _onConfirmEdit(BusyHour replacement) {
    widget._bloc.edit(_busy, replacement);
    Navigator.pop(context);
  }
}
