import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class FloatingActionbutton extends StatelessWidget {
  final MapController mapController;

  FloatingActionbutton({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 10),
        FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            mapController.move(mapController.camera.center, mapController.camera.zoom + 1);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            mapController.move(mapController.camera.center, mapController.camera.zoom - 1);
          },
          child: const Icon(
            Icons.remove,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

