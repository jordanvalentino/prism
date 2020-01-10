import 'package:kilat/app/models/Model.dart';
import 'package:kilat/globals.dart' as globals;

class EventSetting extends Model {
  double dateRange;
  double duration;
  double participant;
  double involvement;
  double rate = 0.5;
  DateTime _lastUpdated;

  // getters setters
  double get wDateRange => dateRange / sum;
  double get wDuration => duration / sum;
  double get wParticipant => participant / sum;
  double get wInvolvement => involvement / sum;
  double get sum => dateRange + duration + participant + involvement;
  DateTime get lastUpdated => _lastUpdated;

  // constructors
  @override
  EventSetting(
      {this.dateRange, this.duration, this.participant, this.involvement})
      : _lastUpdated = DateTime.now(),
        super();

  @override
  EventSetting.fromJson(Map<String, dynamic> json)
      : dateRange = json['date_range'].toDouble(),
        duration = json['duration'].toDouble(),
        participant = json['participant'].toDouble(),
        involvement = json['involvement'].toDouble(),
        _lastUpdated = DateTime.parse(json['last_updated']),
        super.fromJson(json);

  // methods
  @override
  Map<String, dynamic> toJson() => {
        'date_range': dateRange,
        'duration': duration,
        'participant': participant,
        'involvement': involvement,
        'last_updated': _lastUpdated.toString(),
      }..addAll(super.toJson()..remove('last_updated'));

  @override
  void update() {
    super.update();
    _lastUpdated = globals.thisMonday.subtract(Duration(days: 1));
  }

  void updateWith(double dateRange, double duration, double participant,
      double involvement) {
    this.dateRange = dateRange;
    this.duration = duration;
    this.participant = participant;
    this.involvement = involvement;

    update();
  }

  void save(String key) {
    globals.pref.save(key, this);
  }

  Future load(String key) async {
    await globals.pref.load(key).then((json) {
      super.loadJson(json);
      dateRange = json['date_range'].toDouble();
      duration = json['duration'].toDouble();
      participant = json['participant'].toDouble();
      involvement = json['involvement'].toDouble();
      _lastUpdated = DateTime.parse(json['last_updated']);
    });
  }

  void remove(String key) {
    globals.pref.remove(key);
  }
}
