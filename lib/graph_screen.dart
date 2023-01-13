import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_router.dart';
import 'graph.dart';
import 'graph_renderer.dart';
import 'graph_settings_screen.dart';


class GraphScreen extends StatefulWidget {
  const GraphScreen({ super.key, });

  @override
  State<GraphScreen> createState() => GraphScreenState();
}

class GraphScreenState extends State<GraphScreen> {
  GraphData? data;

  void onNewConfig(GraphData data) => setState(() {
    this.data = data;
  });

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      body: Column(
        children: [
          Flexible(
            child: ElevatedButton(
              child: const Text('Open settings'),
              onPressed: () async => appRouter.pushNativeRoute(
                DialogRoute(
                  context: context,
                  builder: (context) => GraphSettingsScreen(
                    initialData: data,
                    callback: onNewConfig,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GraphRenderer(data: data),
          ),
        ],
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GraphData?>('data', data));
  }
}
