class Model {
  int id;
  DateTime _lastUpdated;
  bool _isUpdated;
  bool _isDeleted;

  DateTime get lastUpdated => _lastUpdated;
  bool get isUpdated => _isUpdated;
  bool get isDeleted => _isDeleted;

  // constructors
  Model()
      : id = null,
        _lastUpdated = DateTime.now(),
        _isUpdated = false,
        _isDeleted = false;

  Model.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _lastUpdated = DateTime.parse(json['last_updated']),
        _isUpdated = false,
        _isDeleted = false;

  // methods
  Map<String, dynamic> toJson() => {
        'id': id,
        'last_updated': lastUpdated.toString(),
        'is_updated': _isUpdated,
        'is_deleted': _isDeleted,
      };

  void update() {
    _isUpdated = true;
    _lastUpdated = DateTime.now();
  }

  void updated() {
    _isUpdated = false;
  }

  void delete() {
    _isUpdated = true;
    _isDeleted = true;
  }

  loadJson(json) {
    id = json['id'];
    _lastUpdated = DateTime.parse(json['last_updated']);
    _isUpdated = json['is_updated'];
    _isDeleted = json['is_deleted'];
  }
}
