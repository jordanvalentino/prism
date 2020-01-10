import 'package:kilat/app/models/Category.dart';

class Categories {
  List<Category> _categories;

  List<Category> get list =>
      _categories.where((cat) => !cat.isDeleted).toList();
  List<Category> get all => _categories;

  List<Category> get events =>
      list.where((cat) => cat.type == 'event').toList();
  List<Category> get tasks => list.where((cat) => cat.type == 'task').toList();

  Categories() {
    _categories = new List<Category>();
  }

  Categories.fromList(List<Category> catList) : _categories = catList;

  void add(Category category) {
    all.add(category);
  }
}
