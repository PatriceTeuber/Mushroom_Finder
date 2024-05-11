import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mushroom_finder/markerdata/markerdata.dart';
import 'appbar.dart';
import 'actionbutton.dart';
import 'database/app_database.dart';
import 'database/markerDataModel.dart';
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
  late var markerDataList = <MarkerData>[];

  @override
  void initState() {
    super.initState();
    loadMarkerData();
  }

  @override
  void dispose() {
    super.dispose();

    /// Schließen der Datenbank, wenn die App beendet wird
    AppDatabase.instance.close();
  }

  Future<void> loadMarkerData() async {
    final markerDataModels =
        await AppDatabase.instance.readAllMarkerDataModels();
    setState(() {
      markerDataList = markerDataModels.map((model) {
        final pinMarker = model != null
            ? buildPin(LatLng(model.latitude, model.longitude))
            : null;
        final labelMarker = model != null
            ? buildLabel(LatLng(model.latitude, model.longitude), model.title)
            : null;
        final additionalInformation =
            model != null ? model.additionalInformation : "";
        return MarkerData(
            pinMarker!, labelMarker!, model!.title, additionalInformation!);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Appbar(),
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

  /// Zusammenfassen aller Pin-Marker aus MarkerData-Objekten in einem MarkerLayer
  Widget buildMarkerLayer() {
    final markers =
        markerDataList.map((markerData) => markerData.pinMarker).toList();
    return MarkerLayer(markers: markers);
  }

  /// Zusammenfassen aller Label-Marker aus MarkerData-Objekten in einem MarkerLayer
  Widget buildLabelLayer() {
    final markers =
        markerDataList.map((markerData) => markerData.labelMarker).toList();
    return MarkerLayer(markers: markers);
  }

  /// Hinzufügen eines neuen Markers in die Datenbank
  /// Aktualisierung des Screens mit dem neuen hinzugefügten Marker
  void addCustomMarker(
      LatLng point, String spotName, String spotInformation) async {
    /// Erstellung eines Objektes zur Datenhaltung eines MarkerData-Objektes
    final newMarkerDataModel = MarkerDataModel(
      latitude: point.latitude,
      longitude: point.longitude,
      title: spotName,
      additionalInformation: spotInformation,
    );

    /// Hinzufügen der neuen MarkerDataModel-Instanz zur Datenbank
    final insertedModel =
        await AppDatabase.instance.createMarkerDataModel(newMarkerDataModel);

    /// Erstellen des neuen MarkerData-Objektes aus dem gespeicherten Datensatz
    /// und Hinzufügen zur temporären Liste der MarkerData-Objekte
    /// alte Implementierung
    /*
      setState(() {
        final pinMarker = buildPin(LatLng(insertedModel.latitude, insertedModel.longitude));
        final labelMarker = buildLabel(LatLng(insertedModel.latitude, insertedModel.longitude), insertedModel.title);
        markerDataList.add(
            MarkerData(
                pinMarker,
                labelMarker,
                insertedModel.title,
                insertedModel.additionalInformation!)
        );
      });*/
    /// Neuladen aller Markerdaten, um die Anzeige auf der Karte zu aktualisieren
    loadMarkerData();
  }

  /// Aktualisieren eines bestehenden Markers in der Datenbank
  /// Aktualisierung des Screens mit dem aktualisierten Marker
  void changeCustomMarker(
      LatLng point, String newSpotName, String newSpotInformation) async {
    try {
      /// Versuche, die MarkerDataModel-Instanz für die angegebenen Koordinaten zu lesen
      final existingMarkerDataModel = await AppDatabase.instance
          .readMarkerDataModelByLatLng(point.latitude, point.longitude);

      /// Wenn eine MarkerDataModel-Instanz gefunden wurde
      if (existingMarkerDataModel != null) {
        /// Erstellen neuer Instanz der MarkerDataModel-Klasse mit den aktualisierten Daten
        final updatedMarkerDataModel = MarkerDataModel(
          id: existingMarkerDataModel.id,
          latitude: existingMarkerDataModel.latitude,
          longitude: existingMarkerDataModel.longitude,
          title: newSpotName,
          additionalInformation: newSpotInformation,
        );

        /// Aktualisieren der MarkerDataModel-Instanz in der Datenbank
        await AppDatabase.instance
            .updateMarkerDataModel(updatedMarkerDataModel);

        /// Neuladen aller Markerdaten, um die Anzeige auf der Karte zu aktualisieren
        loadMarkerData();
      } else {
        /// Wenn keine MarkerDataModel-Instanz für die angegebenen Koordinaten gefunden wurde,
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
    /// Versuche, die MarkerDataModel-Instanz für die angegebenen Koordinaten zu lesen
    final existingMarkerDataModel = await AppDatabase.instance
        .readMarkerDataModelByLatLng(point.latitude, point.longitude);

    if (existingMarkerDataModel != null) {
      /// Löschen der MarkerDataModel-Instanz in der Datenbank
      await AppDatabase.instance
          .deleteMarkerDataModel(existingMarkerDataModel.id!);

      /// Neuladen aller Markerdaten, um die Anzeige auf der Karte zu aktualisieren
      loadMarkerData();
    } else {
      /// Wenn keine MarkerDataModel-Instanz für die angegebenen Koordinaten gefunden wurde,
      /// zeige eine Fehlermeldung an
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marker-Datensatz wurde nicht gefunden.')),
      );
    }
  }

  /// Suchen eines MarkerData-Objektes in der temporären Liste von MarkerData-Objekten
  /// an bestimmten Punkt
  MarkerData? findMarkerData(LatLng point) {
    for (var markerData in markerDataList) {
      if (markerData.pinMarker.point == point) {
        return markerData;
      }
    }
    return null;
  }

  /// Erstellen von Pins auf der Karte
  Marker buildPin(LatLng point) => Marker(
        point: point,
        width: 60,
        height: 60,
        alignment: Alignment.topCenter,
        child: IconButton(
          onPressed: () {
            setState(() {
              MarkerData? markerData = findMarkerData(point);
              if (markerData != null) {
                DialogHelper(
                        context: context,
                        point: point,
                        addPinWithLabelDialogHelper: addCustomMarker,
                        removeCustomMarkerDialogHelper: removeCustomMarker,
                        changeCustomMarkerDialogHelper: changeCustomMarker)
                    .showMyEditDialog(
                        markerData.title, markerData.additionalInformation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Marker-Datensatz wurde nicht gefunden.')),
                );
              }
            });
          },
          icon: const Icon(Icons.location_on),
          color: Colors.black,
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
      height: textPainter.height + 8,

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
