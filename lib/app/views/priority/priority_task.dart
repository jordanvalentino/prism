import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/activity_bloc.dart';
import 'package:kilat/app/models/Task.dart';
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class PriorityTask extends StatefulWidget {
  final ActivityBloc _bloc;
  PriorityTask(this._bloc);

  @override
  _PriorityTaskState createState() => _PriorityTaskState();
}

class _PriorityTaskState extends State<PriorityTask> {
  List<Task> _tasks;

  @override
  void initState() {
    _prepareList();
    super.initState();
  }

  @override
  void dispose() {
    globals.activities.tasks.all.sort((a, b) => a.compareTo(b));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 80,
      child: (_tasks.length == 0)
          ? Center(child: Text("No priorities yet."))
          : ReorderableListView(
              padding: EdgeInsets.symmetric(vertical: 12),
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  // removing the item at oldIndex will shorten the list by 1.
                  newIndex -= 1;
                }
                setState(() {
                  Task task = _tasks.removeAt(oldIndex);
                  _tasks.insert(newIndex, task);
                  _updateUserRank();
                });
              },
              children: _tasks.map((ts) => _buildTaskCard(ts)).toList(),
            ),
    );
  }

  Widget _buildTaskCard(activity) {
    return Card(
      key: ValueKey(activity),
      color: colors.accent[400],
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
          child: Text("${activity.dayString}\n" + "${activity.timeStartString}",
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
    List<Task> weekly = globals.activities.tasks.thisWeek;

    List<Task> sorted = weekly.where((ts) => ts.userRank != null).toList();
    sorted.sort((a, b) => a.userRank.compareTo(b.userRank));

    List<Task> nulls = weekly.where((ts) => ts.userRank == null).toList();
    nulls.sort((a, b) => a.sysRank.compareTo(b.sysRank));

    _tasks = sorted.followedBy(nulls).toList();

    _tasks.where((ts) => ts.userRank == null).forEach((ts) {
      ts.userRank = _tasks.indexOf(ts) + 1;
    });
  }

  void _updateUserRank() {
    _tasks.forEach((ts) {
      ts.userRank = _tasks.indexOf(ts) + 1;
      ts.update();
    });
  }
}
