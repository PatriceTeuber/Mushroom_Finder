import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mushroom_finder/pointdata/pointdata.dart';

import 'dialoghelper/dialoghelper.dart';

class MarkerPopUp extends StatefulWidget {
  final BuildContext context;
  final PointData? pointData;

  /// Funktionen, die im Dialog lediglich aufgerufen werden
  final void Function(LatLng, String, String) addPinWithLabelMarkerPopUp;
  final void Function(LatLng) removeCustomMarkerMarkerPopUp;
  final void Function(LatLng, String, String) changeCustomMarkerMarkerPopUp;

  const MarkerPopUp(
      {super.key,
      required this.removeCustomMarkerMarkerPopUp,
      required this.changeCustomMarkerMarkerPopUp,
      required this.context,
      required this.addPinWithLabelMarkerPopUp, required this.pointData});

  @override
  State<StatefulWidget> createState() => _MarkerPopUpState();
}

class _MarkerPopUpState extends State<MarkerPopUp> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final pointData = widget.pointData;

    /// Falls der Punkt nicht existiert wird ein leeres Widget zurückgegeben
    if (pointData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: () => setState(() {}),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  /// Editierdialogfenster wird aufgerufen
                  DialogHelper(
                      context: context,
                      point: pointData.pinMarker.point,
                      addPinWithLabelDialogHelper: widget.addPinWithLabelMarkerPopUp,
                      removeCustomMarkerDialogHelper: widget.removeCustomMarkerMarkerPopUp,
                      changeCustomMarkerDialogHelper: widget.changeCustomMarkerMarkerPopUp)
                      .showEditDialog(
                      pointData.title, pointData.additionalInformation);
                },
              ),
            ),
            _cardDescription(context, pointData),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                    /// Dialogfenster zur Löschbestätigung wird aufgerufen
                    DialogHelper(
                        context: context,
                        point: pointData.pinMarker.point,
                        addPinWithLabelDialogHelper: widget.addPinWithLabelMarkerPopUp,
                        removeCustomMarkerDialogHelper: widget.removeCustomMarkerMarkerPopUp,
                        changeCustomMarkerDialogHelper: widget.changeCustomMarkerMarkerPopUp)
                        .showDeleteConfirmationDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mittlerer Teil der Card, welcher alle Inhalte, wie den Namen,
  /// zusätzliche Informationen und die genaue Position darstellt
  Widget _cardDescription(BuildContext context, PointData pointData) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            /// Marker-Titel
            Text(
              'Pilz-Spot "${pointData.title}"',
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const Divider(height: 20, color: Colors.grey, thickness: 1.5),
            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
            /// Zusätzliche Informationen
            const Text(
              'Zusätzliche Informationen:',
              style: TextStyle(fontSize: 12.0),
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 100,
                    minWidth: constraints.maxWidth, // Use the current width of the container
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      pointData.additionalInformation,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                );
              },
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            const Divider(height: 20, color: Colors.grey, thickness: 1.5),
            /// genaue Positions-Informationen
            Text(
              'Position: ${pointData.pinMarker.point.latitude}, ${pointData.pinMarker.point.longitude}',
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }


}
