import 'package:kilat/app/models/Event.dart';

class SmartEvent {
  Event origin;
  int id;
  double dateRange;
  double duration;
  double participant;
  double involvement;
  int sysRank;
  int userRank;

  double get totalScore => dateRange + duration + participant + involvement;
  double get reTotalScore => duration + participant + involvement;

  SmartEvent(
      {this.origin,
      this.id,
      this.dateRange,
      this.duration,
      this.participant,
      this.involvement,
      this.sysRank,
      this.userRank});
}
