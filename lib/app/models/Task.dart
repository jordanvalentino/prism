import 'package:kilat/app/models/Activity.dart';
import 'package:kilat/app/models/SmartTask.dart';

class Task extends Activity implements Comparable {
  int difficulty;
  int benefit;

  // constructors
  @override
  Task(
      {title,
      date,
      time,
      dateCreated,
      categoryId,
      accountId,
      this.difficulty,
      this.benefit})
      : super(
            title: title,
            date: date,
            timeStart: time,
            timeEnd: null,
            dateCreated: dateCreated,
            // categoryId: categoryId,
            accountId: accountId);

  @override
  Task.fromJson(Map<String, dynamic> json)
      : difficulty = json['difficulty'],
        benefit = json['benefit'],
        super.fromJson(json);

  // methods
  @override
  Map<String, dynamic> toJson() => {
        'difficulty': difficulty,
        'benefit': benefit,
      }..addAll(super.toJson());

  void replaceWith(Task task) {
    title = task.title;
    date = task.date;
    timeStart = task.timeStart;
    dateCreated = task.dateCreated;
    difficulty = task.difficulty;
    benefit = task.benefit;
    // categoryId = task.categoryId;

    update();
  }

  SmartTask toSmartObject() => SmartTask(
      origin: this,
      id: id,
      dateRange: dateRange,
      difficulty: difficulty.toDouble(),
      benefit: benefit.toDouble(),
      sysRank: sysRank,
      userRank: userRank);

  // operators
  @override
  int compareTo(dynamic other) {
    int dateDiff = date.difference(other.date).inDays * 1440;
    int hourDiff = (timeStart.hour - other.timeStart.hour) * 60;
    int minDiff = timeStart.minute - other.timeStart.minute;

    return dateDiff + hourDiff + minDiff;
  }
}
