import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:mushroom_finder/markerpopup.dart';
import 'package:mushroom_finder/pointdata/pointdata.dart';
import 'appbar.dart';
import 'actionbutton.dart';
import 'database/app_database.dart';
import 'database/pointDataModel.dart';
import 'dialoghelper/dialoghelper.dart';

void main() {
  runApp(const MaterialApp(
      title: 'MushMap', debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late var pointDataList = <PointData>[];
  final List<String> titlesToSearch = [];

  /// Animation Konstanten
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  @override
  void initState() {
    super.initState();
    /// Laden aller bereits gesetzer Marker-Informationen aus der Datenbank
    /// und Erstellen neuer Point-Marker Objekte in pointDataList
    loadPointData();
  }

  @override
  void dispose() {
    super.dispose();
    /// Schließen der Datenbank, wenn die App beendet wird
    AppDatabase.instance.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, /// Verhindert das Verschieben von Widgets beim Einblenden der Bildschirmtastatur
      extendBodyBehindAppBar: true,
      appBar: Appbar(
          getCustomMarker: getPointDataList,
          CreateSearch: createSearch,
          DeleteSearch: deleteSearch),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(50.884842, 12.079811), /// Initiale Kartenzentrierung
          initialZoom: 12, /// Initialer Zoomlevel
          onTap: (tapPosition, latLng) {
            setState(() {
              DialogHelper(
                      context: context,
                      point: latLng,
                      addPinWithLabelDialogHelper: addCustomMarker,
                      removeCustomMarkerDialogHelper: removeCustomMarker,
                      changeCustomMarkerDialogHelper: changeCustomMarker)
                  .showCreationDialog();
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          buildLabelLayer(),
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              markers: pointDataList
                  .map((pointData) => pointData.pinMarker)
                  .toList(),
              popupDisplayOptions: PopupDisplayOptions(
                builder: (BuildContext context, Marker marker) => MarkerPopUp(
                  context: context,
                  pointData: findPointData(marker.point), /// Findet die Punktedaten für den Marker
                  addPinWithLabelMarkerPopUp: addCustomMarker,
                  removeCustomMarkerMarkerPopUp: removeCustomMarker,
                  changeCustomMarkerMarkerPopUp: changeCustomMarker,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionbutton(mapController: mapController),
    );
  }

  /// Laden aller bereits bestehenden Datenbankeinträge von Pilz-Markern
  /// Mit jedem Datensatz wird ein neues PointData-Objekt erstellt, welches
  /// alle Informationen, sowie den Pin und das Label der Markers enthält
  Future<void> loadPointData() async {
    final pointDataModels = await AppDatabase.instance.readAllPointDataModels();
    setState(() {
      pointDataList = pointDataModels.map((model) {
        final color =
        titlesToSearch.contains(model!.title) ? Colors.green : Colors.black;
        final pinMarker =
        buildPin(LatLng(model.latitude, model.longitude), color);
        final labelMarker =
        buildLabel(LatLng(model.latitude, model.longitude), model.title);
        final additionalInformation = model.additionalInformation!.isNotEmpty
            ? model.additionalInformation
            : "";
        return PointData(
            pinMarker, labelMarker, model.title, additionalInformation!);
      }).toList();
    });
  }

  List<PointData> getPointDataList() {
    return pointDataList;
  }

  void createSearch(String title) {
    titlesToSearch.add(title);
    loadPointData();
    List<PointData> filteredPointDataList = [];
    for (PointData pointData in pointDataList) {
      if (pointData.title == title) {
        filteredPointDataList.add(pointData);
      }
    }
    if (filteredPointDataList.isEmpty) {
      /// Fehlerzustand
    } else if (filteredPointDataList.length > 1) {
      /// Mehrere Marker mit selben Namen vorhanden
      var pointEntries = <LatLng>[];
      for (PointData pointData in filteredPointDataList) {
        pointEntries.add(pointData.pinMarker.point);
      }
      final bounds = LatLngBounds.fromPoints(pointEntries);
      final constrained = CameraFit.bounds(
        bounds: bounds,
      ).fit(mapController.camera);
      _animatedMapMove(constrained.center, constrained.zoom - 1);
    } else {
      /// nur ein Marker mit dem selben Namen vorhanden
      _animatedMapMove(filteredPointDataList.first.pinMarker.point,
          mapController.camera.zoom + 1);
    }
  }

  void deleteSearch() {
    titlesToSearch.clear();
    loadPointData();
  }

  /// Methode für die Animationsbewegung der Karte
  /// Bspw. wenn nach bestimmten Pilz gesucht wird
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    /// Erstellen einiger Tweens. Diese dienen dazu, den Übergang von einem Standort zum anderen aufzuteilen.
    /// In unserem Fall möchten wir den Übergang zwischen unserem aktuellen Kartenmittelpunkt und dem Ziel aufteilen.
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    /// Erstellen eines Animationscontroller mit einer Dauer und einem TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    /// Die Animation bestimmt den Pfad der Animation.
    final Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    /// Diese Methode zur Codierung des Zielortes ist ein Workaround.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    /// Event-Listener zum Kontroler hinzufügen, um die passende Animations Status-Id zuzuweisen
    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    /// Entfernen des Controllers, wenn dieser nicht mehr gebraucht wird
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
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
        await AppDatabase.instance.updatePointDataModel(updatedPointDataModel);

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

  /// Entfernen eines bestehenden Markers aus der Datenbank
  /// Aktualisierung des Screens ohne den gelöschten Marker
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

  /// Erstellen eines Pins auf der Karte
  Marker buildPin(LatLng point, [Color pinColor = Colors.black]) => Marker(
      point: point,
      width: 60,
      height: 60,
      alignment: Alignment.topCenter,
      child: Icon(Icons.location_on, size: 50, color: pinColor));

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
      /// Breite des Containers entspricht der Breite des Textes plus Padding
      width: textPainter.width + 16,
      /// Höhe des Containers entspricht der Höhe des Textes plus Padding
      height: textPainter.height + 12,
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
