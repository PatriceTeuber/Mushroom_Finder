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

class _MarkerPopUpState extends State<MarkerPopUp> {

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  DialogHelper(
                      context: context,
                      point: widget.pointData!.pinMarker.point,
                      addPinWithLabelDialogHelper: widget.addPinWithLabelMarkerPopUp,
                      removeCustomMarkerDialogHelper: widget.removeCustomMarkerMarkerPopUp,
                      changeCustomMarkerDialogHelper: widget.changeCustomMarkerMarkerPopUp)
                      .showEditDialog(
                      widget.pointData!.title, widget.pointData!.additionalInformation);
                },
              ),
            ),
            _cardDescription(context),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                    bool? deleteConfirmed = await DialogHelper(
                        context: context,
                        point: widget.pointData!.pinMarker.point,
                        addPinWithLabelDialogHelper: widget.addPinWithLabelMarkerPopUp,
                        removeCustomMarkerDialogHelper: widget.removeCustomMarkerMarkerPopUp,
                        changeCustomMarkerDialogHelper: widget.changeCustomMarkerMarkerPopUp)
                        .showDeleteConfirmationDialog();
                    if (deleteConfirmed == true) {
                      ///Schließen des MarkerPopUps
                    }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Pilz-Spot "${widget.pointData!.title}"',
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
            Text(
              'Zusätzliche Informationen: ${widget.pointData!.additionalInformation}',
              style: const TextStyle(fontSize: 12.0),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              'Position: ${widget.pointData!.pinMarker.point.latitude}, ${widget.pointData!.pinMarker.point.longitude}',
              style: const TextStyle(fontSize: 12.0),
            )
          ],
        ),
      ),
    );
  }
}
