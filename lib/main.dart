import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:mushroom_finder/pointdata/pointdata.dart';
import 'appbar.dart';
import 'actionbutton.dart';
import 'database/app_database.dart';
import 'database/pointDataModel.dart';
import 'dialoghelper.dart';

void main() {
  /// Ausführen der App
  runApp(const MaterialApp(
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late var pointDataList = <PointData>[];
  final List<String> TitelstoSearch = [];

  bool _hasConnection = true;

  /// Animation Konstante
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

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

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

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
        final color = TitelstoSearch.contains(model!.title) ? Colors.green : Colors.black;
        final pinMarker = model != null
            ? buildPin(LatLng(model.latitude, model.longitude),color)
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

  void createSearch(String title) {
    TitelstoSearch.add(title);
    loadPointData();
    List<PointData> filteredPointDataList = [];
    for (PointData pointData in pointDataList) {
      if (pointData.title == title) {
        filteredPointDataList.add(pointData);
      }
    }
    if (filteredPointDataList.isEmpty) {
      /// Fehlerzustand
    } else if (filteredPointDataList.length > 1) { /// Mehrere Marker mit selben Namen vorhanden
      var PointEntries = <LatLng>[];
      for (PointData pointData in filteredPointDataList) {
        PointEntries.add(pointData.pinMarker.point);
      }
      final bounds = LatLngBounds.fromPoints(PointEntries);
      final constrained = CameraFit.bounds(
        bounds: bounds,
      ).fit(mapController.camera);
      _animatedMapMove(constrained.center, constrained.zoom -1);
    } else { /// nur ein Marker mit dem selben Namen vorhanden
      _animatedMapMove(filteredPointDataList.first.pinMarker.point, mapController.camera.zoom + 1);
    }
  }

  void deleteSearch() {
    TitelstoSearch.clear();
    loadPointData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Appbar(getCustomMarker: getCustomMarker,changeMarkerColor: changeMarkerColor,CreateSearch:createSearch, DeleteSearch:deleteSearch),
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
            tileProvider: CancellableNetworkTileProvider(),
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
