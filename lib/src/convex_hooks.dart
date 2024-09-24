import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'convex_provider.dart';
import 'convex_reactive.dart';
import 'convex_auth.dart';
import 'convex_types.dart';

ConvexReactive useReactive() {
  final client = ConvexProvider.of(useContext()).client;
  return useMemoized(() => ConvexReactive(client), [client]);
}

// Update the useQuery hook to use the new useReactive hook
T useQuery<T>(String name, Map<String, dynamic> args) {
  final reactive = useReactive();
  final result = useState<T?>(null);

  useEffect(() {
    final subscription = reactive.watchQuery<T>(name, args).listen((data) {
      result.value = data;
    });
    return subscription.cancel;
  }, [name, args.toString()]);

  if (result.value == null) {
    throw Exception('Query is still loading');
  }

  return result.value as T;
}

Future<T> Function(Map<String, dynamic>) useMutation<T>(String name) {
  final client = ConvexProvider.of(useContext()).client;
  return useCallback((Map<String, dynamic> args) {
    return client.mutation(name, args) as Future<T>;
  }, [client, name]);
}

Stream<T> useSubscription<T>(String name, Map<String, dynamic> args) {
  final client = ConvexProvider.of(useContext()).client;
  return useMemoized(() => client.subscribe(name, args).map((event) => event as T), [name, args.toString()]);
}

bool useAuth() {
  final client = ConvexProvider.of(useContext()).client;
  final isAuthenticated = useState<bool>(false);

  useEffect(() {
    ConvexAuth().isAuthenticated().then((value) => isAuthenticated.value = value);
  }, []);

  return isAuthenticated.value;
}

Future<void> useSignIn(String token) async {
  final client = ConvexProvider.of(useContext()).client;
  await client.setAuth(token);
}

Future<void> useSignOut() async {
  final client = ConvexProvider.of(useContext()).client;
  await client.clearAuth();
}

Future<Id> Function(Map<String, dynamic>) useInsert(String tableName) {
  final client = ConvexProvider.of(useContext()).client;
  return useCallback((Map<String, dynamic> document) {
    return client.database.insert(tableName, document);
  }, [client, tableName]);
}


Future<void> Function(Id, Map<String, dynamic>) useUpdate(String tableName) {
  final client = ConvexProvider.of(useContext()).client;
  return useCallback((Id id, Map<String, dynamic> update) {
    return client.database.update(tableName, id, update);
  }, [client, tableName]);
}


Future<void> Function(Id) useDelete(String tableName) {
  final client = ConvexProvider.of(useContext()).client;
  return useCallback((Id id) {
    return client.database.delete(tableName, id);
  }, [client, tableName]);
}


Future<Map<String, dynamic>?> useGet(String tableName, Id id) {
  final client = ConvexProvider.of(useContext()).client;
  final result = useState<Map<String, dynamic>?>(null);

  useEffect(() {
    client.database.get(tableName, id).then((value) => result.value = value);
  }, [tableName, id.toString()]);

  return Future.value(result.value);
}

List<Map<String, dynamic>> useDatabaseQuery(
    String tableName, {
      Expression? filter,
      List<OrderBy>? orderBy,
      int? limit,
    }) {
  final client = ConvexProvider.of(useContext()).client;
  final result = useState<List<Map<String, dynamic>>>([]);

  useEffect(() {
    client.database.query(tableName, filter: filter, orderBy: orderBy, limit: limit)
        .then((value) => result.value = value);
  }, [tableName, filter?.toJson().toString(), orderBy?.toString(), limit]);

  return result.value;
}

Stream<List<Map<String, dynamic>>> useDatabaseSubscription(
    String tableName, {
      Expression? filter,
      List<OrderBy>? orderBy,
      int? limit,
    }) {
  final client = ConvexProvider.of(useContext()).client;
  return useMemoized(() => client.database.subscribe(
    tableName,
    filter: filter,
    orderBy: orderBy,
    limit: limit,
  ), [tableName, filter?.toJson().toString(), orderBy?.toString(), limit]);
}
