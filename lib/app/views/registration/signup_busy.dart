import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/busy_bloc.dart';
import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class SignUpBusy extends StatefulWidget {
  final BusyBloc _bloc;
  SignUpBusy(this._bloc);

  @override
  _SignUpBusyState createState() => _SignUpBusyState();
}

class _SignUpBusyState extends State<SignUpBusy> {
  @override
  void initState() {
    widget._bloc.init();
    super.initState();
  }

  @override
  void dispose() {
    widget._bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: colors.primary[500],
            body: SafeArea(
              child: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 14, 16, 0),
                      child: (globals.busys.list.length > 0)
                          ? InkWell(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Done",
                                  style: TextStyle(
                                    color: colors.primary[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: () => dialogs.yesNoDialog(
                                  context, "Everything set?",
                                  onYes: _gotoHome),
                            )
                          : InkWell(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Skip",
                                  style: TextStyle(
                                    color: colors.primary[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: () => dialogs.yesNoDialog(
                                  context, "Skip this step?",
                                  onYes: () => _gotoHome()),
                            ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 58),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "BEFORE YOU GO",
                        style: TextStyle(
                          color: colors.primary[50],
                          fontFamily: 'FredokaOne',
                          fontSize:
                              Theme.of(context).textTheme.display1.fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50, 5, 50, 0),
                  child: Text(
                    "Would you let me know when you're free?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.primary[700],
                      fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                    child: (globals.busys.list.length > 0)
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 40),
                            child: Column(
                              children: <Widget>[
                                RaisedButton(
                                  color: colors.accent,
                                  child: Text("Add"),
                                  onPressed: () => _gotoBusyAdd(),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: StreamBuilder<List<BusyHour>>(
                                      initialData: globals.busys.list,
                                      stream: widget._bloc.busyhoursStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                color: colors.primary[50],
                                                child: ListTile(
                                                  title: Text(snapshot
                                                      .data[index].dayString),
                                                  subtitle: Text(
                                                      "${snapshot.data[index].timeStartString} - " +
                                                          "${snapshot.data[index].timeEndString}"),
                                                  trailing: PopupMenuButton(
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
                                                        _onPopupSelected(
                                                            value,
                                                            snapshot
                                                                .data[index]),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }

                                        showDialog(
                                            context: context,
                                            builder: (context) => Container(
                                                child:
                                                    CircularProgressIndicator()));
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                FloatingActionButton(
                                  backgroundColor: colors.accent,
                                  child: Icon(Icons.add, color: Colors.black),
                                  tooltip: "Add",
                                  onPressed: () => _gotoBusyAdd(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text(
                                    "Add busy hour",
                                    style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize,
                                      color: colors.primary[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ])),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "What's this?",
                        style: TextStyle(
                          color: colors.primary[700],
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () => _showHelpSheet(context),
                  ),
                )
              ]),
            )));
  }

  _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 250,
            child: Column(
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Container(
                      color: Colors.grey[300],
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Text("What's this?"),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Busy Hour(s) are reserved hours for primary activities " +
                            "which will be treated as top priority schedules.\n" +
                            "(e.g. routines, office hours, or school hours)\n\n" +
                            "If any new activity scheduled at these hours, " +
                            "you will get notified immediately.",
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.subhead.fontSize),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  void _gotoBusyAdd() => Navigator.pushNamed(context, 'busy_add');
  void _gotoHome() => Navigator.pushReplacementNamed(context, 'master_home');

  void _onPopupSelected(dynamic value, BusyHour busy) {
    if (value == 'edit') {
      Navigator.pushNamed(context, 'busy_edit', arguments: busy);
    } else if (value == 'delete') {
      dialogs.confirmDialog(context, "Delete schedule?", onConfirm: () async {
        _onConfirmDelete(busy);
        Navigator.pop(context);
      });
    }
  }

  void _onConfirmDelete(BusyHour busy) {
    widget._bloc.delete(busy);
    if (globals.busys.list.length == 0) setState(() {});
  }
}
