import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../graph.dart';
import '../graph_screen.dart';
import '../graph_settings_screen.dart';


part 'app_router.gr.dart';


@MaterialAutoRouter(
  // replaceInRouteName: 'Page,Route',
  routes: [
    AutoRoute(
      initial: true,
      path: '/graph',
      page: GraphScreen,
    ),
    AutoRoute(
      path: '/graph-settings',
      page: GraphSettingsScreen,
    ),
  ],
)
class AppRouter extends _$AppRouter {

}
