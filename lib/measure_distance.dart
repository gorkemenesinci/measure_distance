import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class MeasureDistance extends StatefulWidget {
  const MeasureDistance({super.key});

  @override
  _MeasureDistanceState createState() => _MeasureDistanceState();
}

class _MeasureDistanceState extends State<MeasureDistance> {
  late ArCoreController arCoreController;
  List<vector.Vector3> points = [];

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isNotEmpty) {
      final hit = hits.first;
      _addPoint(hit.pose.translation);
      _addSphere(hit.pose.translation);
    }
  }

  void _addPoint(vector.Vector3 point) {
    setState(() {
      points.add(point);
      if (points.length == 2) {
        _calculateDistance();
        points.clear();
      }
    });
  }

  void _addSphere(vector.Vector3 position) {
    final material = ArCoreMaterial(color: Colors.orange);
    final sphere = ArCoreSphere(materials: [material], radius: 30);
    final node = ArCoreNode(
      shape: sphere,
      position: position,
    );
    arCoreController.addArCoreNodeWithAnchor(node);
  }

  void _calculateDistance() {
    if (points.length < 2) return;
    final point1 = points[0];
    final point2 = points[1];
    final distance = _distanceBetweenPoints(point1, point2);
    _showDistanceDialog(distance);
  }

  double _distanceBetweenPoints(vector.Vector3 point1, vector.Vector3 point2) {
    return (point1 - point2).length * 100; // Metreyi santimetreye çevir
  }

  void _showDistanceDialog(double distance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Distance"),
          content: Text(
              "The distance between the points is ${distance.toStringAsFixed(2)} cm"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
