import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mushroom_finder/pointdata/pointdata.dart';
import 'appbar.dart';
import 'actionbutton.dart';
import 'database/app_database.dart';
import 'database/pointDataModel.dart';
import 'dialoghelper.dart';

void main() {
  /// Ausführen der App
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MapController mapController = MapController();
  late var pointDataList = <PointData>[];
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();
    loadPointData();
  }

  @override
  void dispose() {
    super.dispose();

    /// Schließen der Datenbank, wenn die App beendet wird
    AppDatabase.instance.close();
  }

  Future<void> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _hasConnection = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> loadPointData() async {
    final pointDataModels =
        await AppDatabase.instance.readAllPointDataModels();
    setState(() {
      pointDataList = pointDataModels.map((model) {
        final pinMarker = model != null
            ? buildPin(LatLng(model.latitude, model.longitude))
            : null;
        final labelMarker = model != null
            ? buildLabel(LatLng(model.latitude, model.longitude), model.title)
            : null;
        final additionalInformation =
            model != null ? model.additionalInformation : "";
        return PointData(
            pinMarker!, labelMarker!, model!.title, additionalInformation!);
      }).toList();
    });
  }
  List<PointData> getCustomMarker() {
      return pointDataList;
    }

    void changeMarkerColor(String target_title, Color c){
      for (var obj in pointDataList) {
        if (obj.title == target_title) {
          setState(() {
            obj.pinMarker = buildPin(obj.pinMarker.point,c);
          });
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Appbar(getCustomMarker: getCustomMarker,changeMarkerColor: changeMarkerColor),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(50.884842, 12.079811),
          initialZoom: 12,
          onTap: (tapPosition, latLng) {
            setState(() {
              DialogHelper(
                      context: context,
                      point: latLng,
                      addPinWithLabelDialogHelper: addCustomMarker,
                      removeCustomMarkerDialogHelper: removeCustomMarker,
                      changeCustomMarkerDialogHelper: changeCustomMarker)
                  .showMyCreationDialog();
            });
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

  /// Zusammenfassen aller Pin-Marker aus PointData-Objekten in einem MarkerLayer
  Widget buildMarkerLayer() {
    final markers =
    pointDataList.map((pointData) => pointData.pinMarker).toList();
    return MarkerLayer(markers: markers);
  }

  /// Zusammenfassen aller Label-Marker aus PointData-Objekten in einem MarkerLayer
  Widget buildLabelLayer() {
    final markers =
    pointDataList.map((pointData) => pointData.labelMarker).toList();
    return MarkerLayer(markers: markers);
  }

  /// Hinzufügen eines neuen Markers in die Datenbank
  /// Aktualisierung des Screens mit dem neuen hinzugefügten Marker
  void addCustomMarker(
      LatLng point, String spotName, String spotInformation) async {
    /// Erstellung eines Objektes zur Datenhaltung eines PointData-Objektes
    final newPointDataModel = PointDataModel(
      latitude: point.latitude,
      longitude: point.longitude,
      title: spotName,
      additionalInformation: spotInformation,
    );

    /// Hinzufügen der neuen PointDataModel-Instanz zur Datenbank
    await AppDatabase.instance.createPointDataModel(newPointDataModel);

    /// Neuladen aller Markerdaten, um die Anzeige auf der Karte zu aktualisieren
    loadPointData();
  }

  /// Aktualisieren eines bestehenden Markers in der Datenbank
  /// Aktualisierung des Screens mit dem aktualisierten Marker
  void changeCustomMarker(
      LatLng point, String newSpotName, String newSpotInformation) async {
    try {
      /// Versuche, die PointDataModel-Instanz für die angegebenen Koordinaten zu lesen
      final existingPointDataModel = await AppDatabase.instance
          .readPointDataModelByLatLng(point.latitude, point.longitude);

      /// Wenn eine PointDataModel-Instanz gefunden wurde
      if (existingPointDataModel != null) {
        /// Erstellen neuer Instanz der PointDataModel-Klasse mit den aktualisierten Daten
        final updatedPointDataModel = PointDataModel(
          id: existingPointDataModel.id,
          latitude: existingPointDataModel.latitude,
          longitude: existingPointDataModel.longitude,
          title: newSpotName,
          additionalInformation: newSpotInformation,
        );

        /// Aktualisieren der PointDataModel-Instanz in der Datenbank
        await AppDatabase.instance
            .updatePointDataModel(updatedPointDataModel);

        /// Neuladen aller Markerdaten, um die Anzeige auf der Karte zu aktualisieren
        loadPointData();
      } else {
        /// Wenn keine PointDataModel-Instanz für die angegebenen Koordinaten gefunden wurde,
        /// zeige eine Fehlermeldung an
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Marker-Datensatz wurde nicht gefunden.')),
        );
      }
    } catch (e) {
      /// Bei Fehlern während des Prozesses zeige eine Fehlermeldung an
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Aktualisieren des Markers.')),
      );
    }
  }

  void removeCustomMarker(LatLng point) async {
    /// Versuche, die PointDataModel-Instanz für die angegebenen Koordinaten zu lesen
    final existingPointDataModel = await AppDatabase.instance
        .readPointDataModelByLatLng(point.latitude, point.longitude);

    if (existingPointDataModel != null) {
      /// Löschen der PointDataModel-Instanz in der Datenbank
      await AppDatabase.instance
          .deletePointDataModel(existingPointDataModel.id!);

      /// Neuladen aller Markerdaten, um die Anzeige auf der Karte zu aktualisieren
      loadPointData();
    } else {
      /// Wenn keine PointDataModel-Instanz für die angegebenen Koordinaten gefunden wurde,
      /// zeige eine Fehlermeldung an
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marker-Datensatz wurde nicht gefunden.')),
      );
    }
  }

  /// Suchen eines PointData-Objektes in der temporären Liste von PointData-Objekten
  /// an bestimmten Punkt
  PointData? findPointData(LatLng point) {
    for (var pointData in pointDataList) {
      if (pointData.pinMarker.point == point) {
        return pointData;
      }
    }
    return null;
  }

  /// Erstellen von Pins auf der Karte
  Marker buildPin(LatLng point,[Color PinColor = Colors.black]) => Marker(
        point: point,
        width: 60,
        height: 60,
        alignment: Alignment.topCenter,
        child: IconButton(
          onPressed: () {
            setState(() {
              PointData? pointData = findPointData(point);
              if (pointData != null) {
                DialogHelper(
                        context: context,
                        point: point,
                        addPinWithLabelDialogHelper: addCustomMarker,
                        removeCustomMarkerDialogHelper: removeCustomMarker,
                        changeCustomMarkerDialogHelper: changeCustomMarker)
                    .showMyEditDialog(
                    pointData.title, pointData.additionalInformation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Marker-Datensatz wurde nicht gefunden.')),
                );
              }
            });
          },
          icon: const Icon(Icons.location_on),
          color: PinColor,
          iconSize: 50,
        ),
      );

  /// Erstellen von Text auf der Karte
  Marker buildLabel(LatLng point, String markerName) {
    const textStyle = TextStyle(
      fontSize: 20,
      color: Colors.white,
    );
    final textSpan = TextSpan(text: markerName, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    return Marker(
      point: point,
      width: textPainter.width + 16,

      /// Breite des Containers entspricht der Breite des Textes plus Padding
      height: textPainter.height + 12,

      /// Höhe des Containers entspricht der Höhe des Textes plus Padding
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          markerName,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }
}
