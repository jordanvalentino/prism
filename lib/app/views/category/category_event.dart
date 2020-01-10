import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/category_bloc.dart';

class CategoryEvent extends StatefulWidget {
  final CategoryBloc _bloc;
  CategoryEvent(this._bloc);

  @override
  _CategoryEventState createState() => _CategoryEventState();
}

class _CategoryEventState extends State<CategoryEvent> {
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
