import 'package:flutter_map/flutter_map.dart';

class PointData {
  Marker pinMarker;
  Marker labelMarker;
  String title;
  String additionalInformation;

  PointData(this.pinMarker, this.labelMarker, this.title,
      this.additionalInformation);
}
