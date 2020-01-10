import 'package:kilat/app/blocs/bloc.dart';
import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/models/BusyHours.dart';
import 'package:kilat/app/networks/busy_repository.dart';
import 'package:kilat/globals.dart' as globals;
import 'package:rxdart/rxdart.dart';

class BusyBloc extends Bloc {
  final BusyRepository _busyRepository;

  BusyBloc(this._busyRepository);

  PublishSubject<List<BusyHour>> _busyhoursSubject;

  Observable<List<BusyHour>> get busyhoursStream => _busyhoursSubject.stream;

  @override
  void init() {
    _busyhoursSubject = PublishSubject<List<BusyHour>>();
  }

  @override
  void dispose() {
    _busyhoursSubject.close();
  }

  updateStream() {
    _busyhoursSubject.add(globals.busys.list);
  }

  void synchronize() {
    globals.busys.offline.forEach((bs) async {
      await _busyRepository.add(bs).then((value) {
        bs.id = value;
        bs.updated();
      }).catchError((e) {
        print(e);
      });
    });

    globals.busys.updated.forEach((bs) async {
      await _busyRepository.edit(bs).then((value) {
        bs.updated();
      }).catchError((e) {
        print(e);
      });
    });

    globals.busys.save();
  }

  fetchAll() async {
    try {
      await _busyRepository.fetchAll(globals.account.id).then((value) {
        globals.busys.oldList = value;
      });
    } catch (e) {
      print(e);
    }
  }

  add(BusyHour busy) {
    globals.busys.add(busy);
    globals.busys.save();
    updateStream();
  }

  edit(BusyHour busy, BusyHour replacement) {
    busy.replaceWith(replacement);
    globals.busys.save();
    updateStream();
  }

  delete(BusyHour busy) {
    busy.delete();
    globals.busys.save();
    updateStream();
  }
}
