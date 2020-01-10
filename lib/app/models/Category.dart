import 'package:kilat/app/models/Model.dart';

class Category extends Model {
  int id;
  String name;
  String type;
  int accountId;
  DateTime _lastUpdated;
  bool _isUpdated;
  bool _isDeleted;

  DateTime get lastUpdated => _lastUpdated;
  bool get isUpdated => _isUpdated;
  bool get isDeleted => _isDeleted;

  Category({this.name, this.type, this.accountId})
      : id = null,
        _lastUpdated = DateTime.now(),
        _isUpdated = false,
        _isDeleted = false;

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        type = json['type'],
        accountId = json['account_id'],
        _lastUpdated = json['last_updated'] != null
            ? DateTime.parse(json['last_updated'])
            : null,
        _isUpdated = false,
        _isDeleted = false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'account_id': accountId,
        'last_updated': _lastUpdated.toString()
      };

  @override
  void update() {
    _isUpdated = true;
    _lastUpdated = DateTime.now();
  }

  void updated() {
    _isUpdated = false;
  }

  void delete() {
    _isDeleted = true;
  }

  void replaceWith(Category category) {
    name = category.name;
    type = category.type;

    update();
  }
}
