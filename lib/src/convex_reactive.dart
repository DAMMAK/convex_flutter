import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'convex_client.dart';

class ConvexReactive {
  final ConvexClient _client;
  final Map<String, BehaviorSubject> _queryCache = {};

  ConvexReactive(this._client);

  Stream<T> watchQuery<T>(String name, Map<String, dynamic> args) {
    final cacheKey = '$name${jsonEncode(args)}';
    if (!_queryCache.containsKey(cacheKey)) {
      _queryCache[cacheKey] = BehaviorSubject<T>();
      _refreshQuery(name, args);
    }
    return _queryCache[cacheKey]!.stream as Stream<T>;
  }

  Future<void> _refreshQuery(String name, Map<String, dynamic> args) async {
    final cacheKey = '$name${jsonEncode(args)}';
    try {
      final result = await _client.query(name, args);
      _queryCache[cacheKey]?.add(result);
    } catch (e) {
      _queryCache[cacheKey]?.addError(e);
    }
  }

  void invalidateQueries() {
    _queryCache.forEach((key, subject) {
      final parts = key.split('{');
      final name = parts[0];
      final args = jsonDecode('{${parts[1]}');
      _refreshQuery(name, args);
    });
  }

  void dispose() {
    for (var subject in _queryCache.values) {
      subject.close();
    }
    _queryCache.clear();
  }
}