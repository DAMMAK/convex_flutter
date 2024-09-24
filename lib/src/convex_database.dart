import 'convex_client.dart';
import 'convex_types.dart';

class ConvexDatabase {
  final ConvexClient _client;

  ConvexDatabase(this._client);

  Future<Id> insert(String tableName, Map<String, dynamic> document) async {
    final result = await _client.mutation('database.insert', {
      'tableName': tableName,
      'document': document,
    });
    return Id.fromString(result['id']);
  }

  Future<void> update(String tableName, Id id, Map<String, dynamic> update) async {
    await _client.mutation('database.update', {
      'tableName': tableName,
      'id': id.toString(),
      'update': update,
    });
  }

  Future<void> delete(String tableName, Id id) async {
    await _client.mutation('database.delete', {
      'tableName': tableName,
      'id': id.toString(),
    });
  }

  Future<Map<String, dynamic>?> get(String tableName, Id id) async {
    final result = await _client.query('database.get', {
      'tableName': tableName,
      'id': id.toString(),
    });
    return result['document'];
  }

  Future<List<Map<String, dynamic>>> query(
      String tableName, {
        Expression? filter,
        List<OrderBy>? orderBy,
        int? limit,
        Cursor? cursor,
      }) async {
    final result = await _client.query('database.query', {
      'tableName': tableName,
      'filter': filter?.toJson(),
      'orderBy': orderBy?.map((o) => o.toJson()).toList(),
      'limit': limit,
      'cursor': cursor?.toString(),
    });
    return List<Map<String, dynamic>>.from(result['documents']);
  }

  Stream<List<Map<String, dynamic>>> subscribe(
      String tableName, {
        Expression? filter,
        List<OrderBy>? orderBy,
        int? limit,
      }) {
    return _client.subscribe('database.subscribe', {
      'tableName': tableName,
      'filter': filter?.toJson(),
      'orderBy': orderBy?.map((o) => o.toJson()).toList(),
      'limit': limit,
    }).map((event) => List<Map<String, dynamic>>.from(event['documents']));
  }

  Future<PaginationResult> paginate(
      String tableName, {
        Expression? filter,
        List<OrderBy>? orderBy,
        int pageSize = 10,
        Cursor? cursor,
      }) async {
    final result = await _client.query('database.paginate', {
      'tableName': tableName,
      'filter': filter?.toJson(),
      'orderBy': orderBy?.map((o) => o.toJson()).toList(),
      'pageSize': pageSize,
      'cursor': cursor?.toString(),
    });
    return PaginationResult(
      documents: List<Map<String, dynamic>>.from(result['documents']),
      nextCursor: result['nextCursor'] != null ? Cursor.fromString(result['nextCursor']) : null,
    );
  }
}