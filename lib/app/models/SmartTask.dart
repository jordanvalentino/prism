import 'package:kilat/app/models/Task.dart';

class SmartTask {
  Task origin;
  int id;
  double dateRange;
  double difficulty;
  double benefit;
  int sysRank;
  int userRank;

  double get totalScore => dateRange + difficulty + benefit;

  SmartTask(
      {this.origin,
      this.id,
      this.dateRange,
      this.difficulty,
      this.benefit,
      this.sysRank,
      this.userRank});
}
