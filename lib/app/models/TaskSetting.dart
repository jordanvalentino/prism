import 'package:kilat/app/models/Model.dart';
import 'package:kilat/globals.dart' as globals;

class TaskSetting extends Model {
  double dateRange;
  double difficulty;
  double benefit;
  double rate = 0.5;
  DateTime _lastUpdated;

  // getters setters
  double get wDateRange => dateRange / sum;
  double get wDifficulty => difficulty / sum;
  double get wBenefit => benefit / sum;
  double get sum => dateRange + difficulty + benefit;
  DateTime get lastUpdated => _lastUpdated;

  // constructors
  @override
  TaskSetting({this.dateRange, this.difficulty, this.benefit})
      : _lastUpdated = DateTime.now(),
        super();

  @override
  TaskSetting.fromJson(Map<String, dynamic> json)
      : dateRange = json['date_range'].toDouble(),
        difficulty = json['difficulty'].toDouble(),
        benefit = json['benefit'].toDouble(),
        _lastUpdated = DateTime.parse(json['last_updated']),
        super.fromJson(json);

  // methods
  @override
  Map<String, dynamic> toJson() => {
        'date_range': dateRange,
        'difficulty': difficulty,
        'benefit': benefit,
        'last_updated': _lastUpdated.toString(),
      }..addAll(super.toJson()..remove('last_updated'));

  @override
  void update() {
    super.update();
    _lastUpdated = globals.thisMonday.subtract(Duration(days: 1));
  }

  void updateWith(double dateRange, double difficulty, double benefit) {
    this.dateRange = dateRange;
    this.difficulty = difficulty;
    this.benefit = benefit;

    update();
  }

  void save(String key) {
    globals.pref.save(key, this);
  }

  Future load(String key) async {
    await globals.pref.load(key).then((json) {
      super.loadJson(json);
      dateRange = json['date_range'].toDouble();
      difficulty = json['difficulty'].toDouble();
      benefit = json['benefit'].toDouble();
      _lastUpdated = DateTime.parse(json['last_updated']);
    });
  }

  void remove(String key) {
    globals.pref.remove(key);
  }
}
