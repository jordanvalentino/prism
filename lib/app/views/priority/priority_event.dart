import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Event.dart';
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class PriorityEvent extends StatefulWidget {
  final ActivityBloc _bloc;
  PriorityEvent(this._bloc);

  @override
  _PriorityEventState createState() => _PriorityEventState();
}

class _PriorityEventState extends State<PriorityEvent> {
  List<Event> _events;

  @override
  void initState() {
    _prepareList();
    super.initState();
  }

  @override
  void dispose() {
    globals.activities.events.all.sort((a, b) => a.compareTo(b));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 80,
      child: (_events.length == 0)
          ? Center(child: Text("No priorities yet."))
          : ReorderableListView(
              padding: EdgeInsets.symmetric(vertical: 12),
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  // removing the item at oldIndex will shorten the list by 1.
                  newIndex -= 1;
                }
                setState(() {
                  Event event = _events.removeAt(oldIndex);
                  _events.insert(newIndex, event);
                  _updateUserRank();
                });
              },
              children: _events.map((ev) => _buildEventCard(ev)).toList(),
            ),
    );
  }

  Widget _buildEventCard(activity) {
    return Card(
      key: ValueKey(activity),
      color: colors.secondary[400],
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          activity.title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
              "${activity.dayString}\n" +
                  "${activity.timeStartString} - ${activity.timeEndString}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              )),
        ),
        trailing: CircleAvatar(
          backgroundColor: colors.primary[50],
          child: (activity.sysRank != null)
              ? Text(
                  activity.sysRank.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : Container(),
        ),
      ),
    );
  }

  void _prepareList() {
    List<Event> weekly = globals.activities.events.thisWeek;

    List<Event> sorted = weekly.where((ev) => ev.userRank != null).toList();
    sorted.sort((a, b) => a.userRank.compareTo(b.userRank));

    List<Event> nulls = weekly.where((ev) => ev.userRank == null).toList();
    nulls.sort((a, b) => a.sysRank.compareTo(b.sysRank));

    _events = sorted.followedBy(nulls).toList();

    _events.where((ev) => ev.userRank == null).forEach((ev) {
      ev.userRank = _events.indexOf(ev) + 1;
      ev.update();
    });
  }

  void _updateUserRank() {
    _events.forEach((ev) {
      ev.userRank = _events.indexOf(ev) + 1;
    });
  }
}
