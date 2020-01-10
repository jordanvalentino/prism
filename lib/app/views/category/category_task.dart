import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/category_bloc.dart';

class CategoryTask extends StatefulWidget {
  final CategoryBloc _bloc;
  CategoryTask(this._bloc);

  @override
  _CategoryTaskState createState() => _CategoryTaskState();
}

class _CategoryTaskState extends State<CategoryTask> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("$index"),
        );
      },
    );
  }
}
