import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mushroom_finder/dialoghelper/dialogs/poisonousinfodialog.dart';

import 'dialogs/creationdialog.dart';
import 'dialogs/deleteconfimationdialog.dart';
import 'dialogs/editdialog.dart';

class DialogHelper {
  final BuildContext context;
  final LatLng point;

  /// Funktionen, die im Dialog lediglich aufgerufen werden
  final void Function(LatLng, String, String) addPinWithLabelDialogHelper;
  final void Function(LatLng) removeCustomMarkerDialogHelper;
  final void Function(LatLng, String, String) changeCustomMarkerDialogHelper;

  DialogHelper({
    required this.context,
    required this.point,
    required this.addPinWithLabelDialogHelper,
    required this.removeCustomMarkerDialogHelper,
    required this.changeCustomMarkerDialogHelper,
  });

  /// Festlegung von optischen Einstellungen (Farbwerte, Borderradius, etc.)
  static const greenButton = Colors.green;
  static const redButton = Colors.redAccent;
  static const blackButton = Colors.black;
  static const backgroundColor = Colors.white;
  static const Color textColor = Colors.white;

  static const double buttonRadius = 5;

  /// Dialoge anzeigen
  Future<bool?> showDeleteConfirmationDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          DeleteConfirmationDialog(
            onConfirmed: () {
              removeCustomMarkerDialogHelper(point);
            },
          ),
    );
  }

  void showEditDialog(String markerTitle, String markerAdditionalInformation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          EditDialog(
            markerTitle: markerTitle,
            markerAdditionalInformation: markerAdditionalInformation,
            onConfirmed: (name, additionalInfo) {
              changeCustomMarkerDialogHelper(point, name, additionalInfo);
            },
          ),
    );
  }

  void showCreationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CreationDialog(
            onConfirmed: (name, additionalInfo) {
              addPinWithLabelDialogHelper(point, name, additionalInfo);
            },
          ),
    );
  }

  static void showPoisonousInfoDialog(context) {
    showDialog(context: context, builder: (context) =>
        const PoisonousInfoDialog()
      );
  }

}