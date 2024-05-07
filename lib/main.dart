import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mushroom_finder/markerdata.dart';
import 'appbar.dart';
import 'actionbutton.dart';
import 'dialoghelper.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MapController mapController = MapController();
  var markerDataList = <MarkerData>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Appbar(),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: const LatLng(51.509364, -0.128928),
          zoom: 4,
          onTap: (tapPosition, latLng) {
            setState(() {
              DialogHelper(
                      context: context,
                      latLng: latLng,
                      addPinWithLabelDialogHelper: addCustomMarker)
                  .showMyCreationDialog();
            });
            setState(() {});
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          buildMarkerLayer(),
          buildLabelLayer(),
        ],
      ),
      floatingActionButton: FloatingActionbutton(mapController: mapController),
    );
  }

  Widget buildMarkerLayer() {
    final markers = markerDataList.map((markerData) => markerData.pinMarker).toList();
    return MarkerLayer(markers: markers);
  }

  Widget buildLabelLayer() {
    final markers = markerDataList.map((markerData) => markerData.labelMarker).toList();
    return MarkerLayer(markers: markers);
  }

  // Hinzufügen eines neuen Markers in die Liste
  void addCustomMarker(LatLng point, String spotName, String spotInformation) {
    final pinMarker = buildPin(point);
    final labelMarker = buildLabel(point, spotName);

    final markerData = MarkerData(
      pinMarker: pinMarker,
      labelMarker: labelMarker,
      title: spotName,
      additionalInformation: spotInformation
    );

    setState(() {
      markerDataList.add(markerData);
    });
  }

  // Erstellen von Pins auf der Karte
  Marker buildPin(LatLng point) => Marker(
        point: point,
        width: 60,
        height: 60,
        alignment: Alignment.topCenter,
        child: IconButton(
          onPressed: () {
            setState(() {
              markerDataList.removeWhere((markerData) {
                return markerData.pinMarker.point == point;
              });
            });
          },
          icon: const Icon(Icons.location_on),
          color: Colors.black,
          iconSize: 50,
        ),
      );

  // Erstellen von Text auf der Karte
  Marker buildLabel(LatLng point, String markerName) => Marker(
        point: point,
        width: 300,
        height: 50,
        alignment: Alignment.bottomCenter,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            " $markerName ",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              backgroundColor: Colors.white.withOpacity(0.5),
              color: Colors.black,
            ),
          ),
        ),
      );
}
