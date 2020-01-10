import 'package:kilat/app/blocs/bloc.dart';
import 'package:kilat/app/models/Categories.dart';
import 'package:kilat/app/models/Category.dart';
import 'package:kilat/app/networks/category_repository.dart';
import 'package:kilat/globals.dart' as globals;
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends Bloc {
  final CategoryRepository _categoryRepository;

  CategoryBloc(this._categoryRepository);

  PublishSubject<List<Category>> _categorySubject;

  Observable<List<Category>> get categoriesStream => _categorySubject.stream;

  @override
  void init() {
    _categorySubject = PublishSubject<List<Category>>();
  }

  @override
  void dispose() {
    _categorySubject.close();
  }

  updateStream() {
    _categorySubject.add(globals.categories.list);
  }

  synchronize() async {
    try {
      globals.categories.all
          .where((cat) => (cat.isDeleted && cat.id != null))
          .forEach((cat) async {
        await _categoryRepository.delete(cat.id).catchError((e) {
          return;
        });
      });

      globals.categories.list
          .where((cat) => (cat.isUpdated && cat.id != null))
          .forEach((cat) async {
        await _categoryRepository.edit(cat).then((value) {
          cat.updated();
        }).catchError((e) {
          return;
        });
      });

      globals.categories.list
          .where((cat) => cat.id == null)
          .forEach((cat) async {
        await _categoryRepository.add(cat).then((value) {
          cat.id = value;
          cat.updated();
        }).catchError((e) {
          return;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  fetchAll() async {
    try {
      await synchronize();

      await _categoryRepository.fetchAll(globals.account.id).then((value) {
        if (globals.categories.list.every((cat) => cat.id != null) &&
            globals.categories.list.every((cat) => !cat.isUpdated) &&
            globals.categories.all.every((cat) => !cat.isDeleted)) {
          globals.categories = Categories.fromList(value.list);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  add(Category cat) {
    cat.update();
    globals.categories.add(cat);
  }

  edit(Category cat, Category replacement) {
    cat.replaceWith(replacement);
  }

  delete(Category cat) {
    cat.delete();
  }
}
