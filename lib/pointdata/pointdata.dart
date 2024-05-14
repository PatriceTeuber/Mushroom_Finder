import 'package:flutter_map/flutter_map.dart';

class PointData {
  Marker _pinMarker;
  Marker _labelMarker;
  String _title;
  String _additionalInformation;

  PointData(this._pinMarker, this._labelMarker, this._title,
      this._additionalInformation);

  Marker get pinMarker => _pinMarker;

  set pinMarker(Marker value) {
    _pinMarker = value;
  }

  String get additionalInformation => _additionalInformation;

  set additionalInformation(String value) {
    _additionalInformation = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  Marker get labelMarker => _labelMarker;

  set labelMarker(Marker value) {
    _labelMarker = value;
  }
}
