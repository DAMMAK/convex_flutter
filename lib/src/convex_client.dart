import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'convex_auth.dart';
import 'convex_database.dart';
import 'convex_types.dart';

class ConvexClient {
  final String deploymentUrl;
  final WebSocketChannel _channel;
  final StreamController<Map<String, dynamic>> _streamController = StreamController.broadcast();
  final ConvexAuth _auth = ConvexAuth();
  late final ConvexDatabase database;

  ConvexClient(this.deploymentUrl)
      : _channel = WebSocketChannel.connect(
      Uri.parse('${deploymentUrl.replaceFirst('https', 'wss')}/websocket')) {
    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      _streamController.add(data);
    });
    database = ConvexDatabase(this);
  }

  Future<Map<String, dynamic>> _request(String endpoint, Map<String, dynamic> body) async {
    final token = await _auth.getToken();
    final response = await http.post(
      Uri.parse('$deploymentUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to execute $endpoint: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> query(String name, Map<String, dynamic> args) async {
    return _request('query', {'name': name, 'args': args});
  }

  Future<Map<String, dynamic>> mutation(String name, Map<String, dynamic> args) async {
    return _request('mutation', {'name': name, 'args': args});
  }

  Stream<Map<String, dynamic>> subscribe(String name, Map<String, dynamic> args) {
    final subscriptionId = DateTime.now().millisecondsSinceEpoch.toString();
    _auth.getToken().then((token) {
      _channel.sink.add(jsonEncode({
        'type': 'subscribe',
        'subscriptionId': subscriptionId,
        'name': name,
        'args': args,
        'token': token,
      }));
    });

    return _streamController.stream.where((event) => event['subscriptionId'] == subscriptionId);
  }

  Future<void> setAuth(String token) async {
    await _auth.setToken(token);
  }

  Future<void> clearAuth() async {
    await _auth.clearToken();
  }

  void close() {
    _channel.sink.close();
    _streamController.close();
  }
}