import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/account_bloc.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class PrefEvent extends StatefulWidget {
  final AccountBloc _bloc;
  PrefEvent(this._bloc);

  @override
  _PrefEventState createState() => _PrefEventState();
}

class _PrefEventState extends State<PrefEvent> {
  bool _hasChanged;

  String _type;
  double _dateRange;
  double _duration;
  double _participant;
  double _involvement;

  @override
  void initState() {
    _hasChanged = false;

    _type = globals.account.evsetType;
    _setValues();

    super.initState();
  }

  @override
  void dispose() {
    globals.account.save();
    globals.account.update();
    if (globals.activities.events.thisWeek.length > 0)
      globals.activities.events.rank(globals.activities.events.thisWeek);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Preferences"),
        actions: <Widget>[
          Visibility(
            visible: (_type == 'user' && _hasChanged),
            child: FlatButton(
              child: Text("Save"),
              onPressed: _save,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _advancedTile(),
            Divider(),
            _dateRangeTile(),
            _durationTile(),
            _participantTile(),
            _involvementTile(),
            Visibility(
              visible: _type == 'user',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                child: FlatButton(
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("RESET"),
                  onPressed: _resetPreference,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _save() {
    dialogs.yesNoDialog(context, "Save changes?", title: "Save", onYes: () {
      globals.evsetUser
          .updateWith(_dateRange, _duration, _participant, _involvement);
      globals.account.update();
      globals.account.save();

      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  void _resetPreference() {
    dialogs.yesNoDialog(context, "Reset event user's preferences?",
        title: "Reset", onYes: () {
      Navigator.pop(context);
      setState(() {
        _dateRange = 47;
        _duration = 64;
        _participant = 21;
        _involvement = 68;
        _hasChanged = true;
      });
    });
  }

  void _setValues() {
    setState(() {
      _dateRange = globals.account.evset.dateRange;
      _duration = globals.account.evset.duration;
      _participant = globals.account.evset.participant;
      _involvement = globals.account.evset.involvement;
    });
  }

  SwitchListTile _advancedTile() => SwitchListTile(
        title: Text("Advanced Settings"),
        subtitle: Text("Use your own preferences"),
        value: _type == 'user',
        onChanged: (value) {
          setState(() {
            _type = value ? 'user' : 'sys';
            globals.account.evsetType = _type;
            _setValues();
          });
        },
      );

  _dateRangeTile() => ListTile(
      title: Text("Date Range"),
      subtitle: Text("${_dateRange.toInt()}"),
      trailing: Container(
        width: 200,
        child: Slider(
          min: 0,
          max: 100,
          divisions: 100,
          label: _dateRange.toStringAsFixed(0),
          value: _dateRange.toDouble(),
          onChanged: (_type == 'user')
              ? (value) => setState(() {
                    _dateRange = value;
                    _hasChanged = true;
                  })
              : null,
        ),
      ));

  _durationTile() => ListTile(
      title: Text("Duration"),
      subtitle: Text("${_duration.toInt()}"),
      trailing: Container(
        width: 200,
        child: Slider(
          min: 0,
          max: 100,
          divisions: 100,
          label: _duration.toStringAsFixed(0),
          value: _duration.toDouble(),
          onChanged: (_type == 'user')
              ? (value) => setState(() {
                    _duration = value;
                    _hasChanged = true;
                  })
              : null,
        ),
      ));

  _participantTile() => ListTile(
      title: Text("Participant"),
      subtitle: Text("${_participant.toInt()}"),
      trailing: Container(
        width: 200,
        child: Slider(
          min: 0,
          max: 100,
          divisions: 100,
          label: _participant.toStringAsFixed(0),
          value: _participant.toDouble(),
          onChanged: (_type == 'user')
              ? (value) => setState(() {
                    _participant = value;
                    _hasChanged = true;
                  })
              : null,
        ),
      ));

  _involvementTile() => ListTile(
      title: Text("Involvement"),
      subtitle: Text("${_involvement.toInt()}"),
      trailing: Container(
        width: 200,
        child: Slider(
          min: 0,
          max: 100,
          divisions: 100,
          label: _involvement.toStringAsFixed(0),
          value: _involvement.toDouble(),
          onChanged: (_type == 'user')
              ? (value) => setState(() {
                    _involvement = value;
                    _hasChanged = true;
                  })
              : null,
        ),
      ));
}
