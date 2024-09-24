import 'package:flutter/widgets.dart';
import 'convex_client.dart';

class ConvexProvider extends InheritedWidget {
  final ConvexClient client;

  const ConvexProvider({
    super.key,
    required this.client,
    required super.child,
  });

  static ConvexProvider of(BuildContext context) {
    final ConvexProvider? result = context.dependOnInheritedWidgetOfExactType<ConvexProvider>();
    assert(result != null, 'No ConvexProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ConvexProvider oldWidget) => client != oldWidget.client;
}