import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/globals.dart' as globals;

class BusyList extends StatefulWidget {
  final ActivityBloc _bloc;
  BusyList(this._bloc);

  @override
  _BusyListState createState() => _BusyListState();
}

class _BusyListState extends State<BusyList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BusyHour>>(
        initialData: globals.busys.list,
        stream: widget._bloc.busyBloc.busyhoursStream,
        builder: (context, snapshot) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: globals.busys.list.length,
            itemBuilder: (context, index) {
              if (snapshot.hasData) {
                return ListTile(
                  title: Text(globals.busys.list[index].dayString),
                  subtitle: Text(globals.busys.list[index].timeStartString +
                      " - " +
                      globals.busys.list[index].timeEndString),
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
                        _onPopupSelected(value, snapshot.data[index]),
                  ),
                );
              }
            },
          );
        });
  }

  void _onPopupSelected(dynamic value, BusyHour busy) {
    if (value == 'edit') {
      Navigator.pushNamed(context, 'busy_edit', arguments: busy);
    } else if (value == 'delete') {
      dialogs.confirmDialog(context, "Delete schedule?", onConfirm: () async {
        widget._bloc.busyBloc.delete(busy);
        Navigator.pop(context);
      });
    }
  }
}
