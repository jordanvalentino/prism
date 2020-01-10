import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/globals.dart' as globals;

class BusyHours {
  List<BusyHour> _busys;

  // getters setters
  List<BusyHour> get all => _busys;
  List<BusyHour> get list => _busys.where((bs) => !bs.isDeleted).toList();
  set oldList(List<BusyHour> newList) => _busys = newList;

  List<BusyHour> get online => all.where((bs) => bs.id != null).toList();
  List<BusyHour> get offline => all.where((bs) => bs.id == null).toList();
  List<BusyHour> get updated => online.where((bs) => bs.isUpdated).toList();

  // constructors
  BusyHours() {
    _busys = List<BusyHour>();
  }

  // methods
  void add(BusyHour busy) {
    all.add(busy);
    all.sort((a, b) => a.compareTo(b));
  }

  void update(BusyHour old, BusyHour replacement) {
    list.singleWhere((ev) => ev == old).replaceWith(replacement);
    all.sort((a, b) => a.compareTo(b));
  }

  void delete(BusyHour busy) {
    list.singleWhere((ev) => ev == busy).delete();
  }

  void save() {
    globals.pref.save('busys', _busys);
  }

  Future load() async {
    await globals.pref.load('busys').then((json) {
      _busys = List<BusyHour>.from(json.map((m) => BusyHour.fromJson(m)));
    });
  }

  void remove() {
    globals.pref.remove('busys');
  }
}
