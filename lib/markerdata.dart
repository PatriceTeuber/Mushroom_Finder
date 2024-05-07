import 'package:flutter_map/flutter_map.dart';

class MarkerData {
  final Marker pinMarker;
  final Marker labelMarker;
  final String title;
  final String additionalInformation;

  MarkerData({
    required this.pinMarker,
    required this.labelMarker,
    required this.title,
    required this.additionalInformation
  });
}
