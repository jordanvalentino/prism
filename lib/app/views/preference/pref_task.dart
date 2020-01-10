import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/account_bloc.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/globals.dart' as globals;

class PrefTask extends StatefulWidget {
  final AccountBloc _bloc;
  PrefTask(this._bloc);

  @override
  _PrefTaskState createState() => _PrefTaskState();
}

class _PrefTaskState extends State<PrefTask> {
  bool _hasChanged;

  String _type;
  double _dateRange;
  double _difficulty;
  double _benefit;

  @override
  void initState() {
    _hasChanged = false;

    _type = globals.account.tasetType;
    _setValues();

    super.initState();
  }

  @override
  void dispose() {
    globals.account.save();
    globals.account.update();
    if (globals.activities.tasks.thisWeek.length > 0)
      globals.activities.tasks.rank(globals.activities.tasks.thisWeek);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Preferences"),
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
            _difficultyTile(),
            _benefitTile(),
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
      globals.tasetUser.updateWith(_dateRange, _difficulty, _benefit);
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
        _dateRange = 77;
        _difficulty = 71;
        _benefit = 52;
        _hasChanged = true;
      });
    });
  }

  void _setValues() {
    setState(() {
      _dateRange = globals.account.taset.dateRange;
      _difficulty = globals.account.taset.difficulty;
      _benefit = globals.account.taset.benefit;
    });
  }

  SwitchListTile _advancedTile() => SwitchListTile(
        title: Text("Advanced Settings"),
        subtitle: Text("Use your own preferences"),
        value: _type == 'user',
        onChanged: (value) {
          setState(() {
            _type = value ? 'user' : 'sys';
            globals.account.tasetType = _type;
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

  _difficultyTile() => ListTile(
      title: Text("Difficulty"),
      subtitle: Text("${_difficulty.toInt()}"),
      trailing: Container(
        width: 200,
        child: Slider(
          min: 0,
          max: 100,
          divisions: 100,
          label: _difficulty.toStringAsFixed(0),
          value: _difficulty.toDouble(),
          onChanged: (_type == 'user')
              ? (value) => setState(() {
                    _difficulty = value;
                    _hasChanged = true;
                  })
              : null,
        ),
      ));

  _benefitTile() => ListTile(
      title: Text("Benefit"),
      subtitle: Text("${_benefit.toInt()}"),
      trailing: Container(
        width: 200,
        child: Slider(
          min: 0,
          max: 100,
          divisions: 100,
          label: _benefit.toStringAsFixed(0),
          value: _benefit.toDouble(),
          onChanged: (_type == 'user')
              ? (value) => setState(() {
                    _benefit = value;
                    _hasChanged = true;
                  })
              : null,
        ),
      ));
}
