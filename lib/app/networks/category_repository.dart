import 'package:kilat/app/models/Categories.dart';
import 'package:kilat/app/models/Category.dart';
import 'package:kilat/app/networks/category_provider.dart';

class CategoryRepository {
  CategoryProvider categoryProvider;

  CategoryRepository(this.categoryProvider);

  Future<Categories> fetchAll(int accountId) {
    return categoryProvider.fetchAll(accountId);
  }

  Future<int> add(Category busy) {
    return categoryProvider.add(busy);
  }

  Future<bool> edit(Category busy) {
    return categoryProvider.edit(busy);
  }

  Future<bool> delete(int id) {
    return categoryProvider.delete(id);
  }
}
