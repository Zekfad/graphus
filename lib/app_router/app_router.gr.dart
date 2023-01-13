// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

part of 'app_router.dart';

class _$AppRouter extends RootStackRouter {
  _$AppRouter([GlobalKey<NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    GraphScreenRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
        routeData: routeData,
        child: const GraphScreen(),
      );
    },
    GraphSettingsScreenRoute.name: (routeData) {
      final args = routeData.argsAs<GraphSettingsScreenRouteArgs>();
      return MaterialPageX<dynamic>(
        routeData: routeData,
        child: GraphSettingsScreen(
          callback: args.callback,
          initialData: args.initialData,
          key: args.key,
        ),
      );
    },
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/graph',
          fullMatch: true,
        ),
        RouteConfig(
          GraphScreenRoute.name,
          path: '/graph',
        ),
        RouteConfig(
          GraphSettingsScreenRoute.name,
          path: '/graph-settings',
        ),
      ];
}

/// generated route for
/// [GraphScreen]
class GraphScreenRoute extends PageRouteInfo<void> {
  const GraphScreenRoute()
      : super(
          GraphScreenRoute.name,
          path: '/graph',
        );

  static const String name = 'GraphScreenRoute';
}

/// generated route for
/// [GraphSettingsScreen]
class GraphSettingsScreenRoute
    extends PageRouteInfo<GraphSettingsScreenRouteArgs> {
  GraphSettingsScreenRoute({
    required void Function(GraphData) callback,
    GraphData? initialData,
    Key? key,
  }) : super(
          GraphSettingsScreenRoute.name,
          path: '/graph-settings',
          args: GraphSettingsScreenRouteArgs(
            callback: callback,
            initialData: initialData,
            key: key,
          ),
        );

  static const String name = 'GraphSettingsScreenRoute';
}

class GraphSettingsScreenRouteArgs {
  const GraphSettingsScreenRouteArgs({
    required this.callback,
    this.initialData,
    this.key,
  });

  final void Function(GraphData) callback;

  final GraphData? initialData;

  final Key? key;

  @override
  String toString() {
    return 'GraphSettingsScreenRouteArgs{callback: $callback, initialData: $initialData, key: $key}';
  }
}
