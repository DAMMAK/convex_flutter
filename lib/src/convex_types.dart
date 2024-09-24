class Id {
  final String _value;

  Id(this._value);

  factory Id.fromString(String value) => Id(value);

  @override
  String toString() => _value;
}

class Cursor {
  final String _value;

  Cursor(this._value);

  factory Cursor.fromString(String value) => Cursor(value);

  @override
  String toString() => _value;
}

class Expression {
  final Map<String, dynamic> _value;

  Expression(this._value);

  Map<String, dynamic> toJson() => _value;

  static Expression eq(String field, dynamic value) => Expression({'$eq': {field: value}});
  static Expression neq(String field, dynamic value) => Expression({'$neq': {field: value}});
  static Expression gt(String field, dynamic value) => Expression({'$gt': {field: value}});
  static Expression gte(String field, dynamic value) => Expression({'$gte': {field: value}});
  static Expression lt(String field, dynamic value) => Expression({'$lt': {field: value}});
  static Expression lte(String field, dynamic value) => Expression({'$lte': {field: value}});
  static Expression and(List<Expression> expressions) => Expression({'$and': expressions.map((e) => e._value).toList()});
  static Expression or(List<Expression> expressions) => Expression({'$or': expressions.map((e) => e._value).toList()});
}

class OrderBy {
  final String field;
  final bool descending;

  OrderBy(this.field, {this.descending = false});

  Map<String, dynamic> toJson() => {
    'field': field,
    'direction': descending ? 'desc' : 'asc',
  };
}

class PaginationResult {
  final List<Map<String, dynamic>> documents;
  final Cursor? nextCursor;

  PaginationResult({required this.documents, this.nextCursor});
}
