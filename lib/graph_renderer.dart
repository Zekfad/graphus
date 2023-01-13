import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'graph.dart';


class GraphRenderer extends StatelessWidget {
  const GraphRenderer({
    this.data,
    super.key,
  });

  final GraphData? data;

  @override
  Widget build(BuildContext context) =>
    data != null
      ? CustomPaint(
        foregroundPainter: GraphPainter(data!),
        child: Container(),
      )
      : const Center(child: Text('No graph data'));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GraphData?>('data', data));
  }
}
