import 'package:kilat/app/models/BusyHour.dart';
import 'package:kilat/app/models/BusyHours.dart';
import 'package:kilat/app/networks/busy_provider.dart';

class BusyRepository {
  BusyProvider busyProvider;

  BusyRepository(this.busyProvider);

  Future<List<BusyHour>> fetchAll(int accountId) {
    return busyProvider.fetchAll(accountId);
  }

  Future<int> add(BusyHour busy) {
    return busyProvider.add(busy);
  }

  Future<bool> edit(BusyHour busy) {
    return busyProvider.edit(busy);
  }

  Future<bool> delete(int id) {
    return busyProvider.delete(id);
  }
}
