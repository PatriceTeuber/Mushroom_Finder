import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'appbar.dart';
import 'actionbutton.dart';
import 'dialoghelper.dart';

late MyApp myAppInstance;

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MapController mapController = MapController();

  var customMarkers = <Marker>[];

  var customLabels = <Marker>[];

  @override
  void initState() {
    super.initState();
    myAppInstance = this.widget;
  }

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
                      add_Pin_with_Marker: add_Pin_with_Marker)
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
          MarkerLayer(
            markers: customMarkers,
          ),
          MarkerLayer(
            markers: customLabels,
          ),
        ],
      ),
      floatingActionButton: FloatingActionbutton(mapController: mapController),
    );
  }

  void add_Pin_with_Marker(LatLng point, String spotName) {
    customLabels.add(buildLabel(point, spotName));
    customMarkers.add(buildPin(point));
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
              customMarkers.removeWhere((marker) {
                return marker.point == point;
              });
              customLabels.removeWhere((label) {
                return label.point == point;
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
