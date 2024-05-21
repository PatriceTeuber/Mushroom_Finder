import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

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
  Future<bool?> showDeleteConfirmationDialog() async {
    bool? result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          DeleteConfirmationDialog(
            onConfirmed: () {
              //removeCustomMarkerDialogHelper(point);
            },
          ),
    );
    return result;
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

/*
  Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Marker löschen'),
          content: const Text('Möchten Sie diesen Marker wirklich löschen?'),
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          actions: <Widget>[
            Row(children: <Widget>[
              Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    child: const Text('Ja',
                        style: TextStyle(
                          color: textColor,
                        )),
                  )),
              const SizedBox(width: 11),
              Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    child: const Text('Nein',
                        style: TextStyle(
                          color: textColor,
                        )),
                  ))
            ]),
          ],
        );
      },
    );
  }
  Future<void> showMyEditDialog(String markerTitle,
      String markerAdditionalInformation) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController additionalInfoController = TextEditingController();

    nameController.text = markerTitle;
    additionalInfoController.text = markerAdditionalInformation;

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pilz-Spot bearbeiten'),
            backgroundColor: backgroundColor,
            surfaceTintColor: backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.bookmark),
                            hintText: 'Bitte gib den Namen des Markers ein',
                            labelText: 'Name *'),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte gebe einen Namen ein';
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: additionalInfoController,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.book),
                          hintText: 'Gib zusätzliche Informationen ein',
                          labelText: 'Zusätzliche Informationen:'),
                      minLines:
                      1,
                      // any number you need (It works as the rows for the textarea)
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              buttonRadius), // Eckenradius anpassen
                        ),
                      ),
                      child: const Text('Abbrechen',
                          style: TextStyle(
                            color: textColor,
                          )),
                    )),
                const SizedBox(width: 11),
                Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          changeCustomMarkerDialogHelper(
                              point, nameController.text,
                              additionalInfoController.text);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              buttonRadius), // Eckenradius anpassen
                        ),
                      ),
                      child: const Text('Übernehmen',
                          style: TextStyle(
                            color: textColor,
                          )),
                    ))
              ]),
              const Divider(height: 20, color: Colors.grey, thickness: 1),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            bool? deleteConfirmed =
                            await showDeleteConfirmationDialog(context);
                            if (deleteConfirmed != null && deleteConfirmed) {
                              removeCustomMarkerDialogHelper(point);
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blackButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  buttonRadius), // Eckenradius anpassen
                            ),
                          ),
                          child: const Text('Löschen',
                              style: TextStyle(
                                color: textColor,
                              )),
                        ))
                  ])
            ],
          );
        });
  }

  Future<void> showMyCreationDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController additionalInfoController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilz-Spot erstellen'),
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.bookmark),
                          hintText: 'Bitte gib den Namen des Markers ein',
                          labelText: 'Name *'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte gebe einen Namen ein';
                        }
                        return null;
                      }),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: additionalInfoController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.book),
                        hintText: 'Gib zusätzliche Informationen ein',
                        labelText: 'Zusätzliche Informationen:'),
                    minLines:
                    1,
                    // any number you need (It works as the rows for the textarea)
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(children: <Widget>[
              Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    child: const Text('Abbrechen',
                        style: TextStyle(
                          color: textColor,
                        )),
                  )),
              const SizedBox(width: 11),
              Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        addPinWithLabelDialogHelper(point, nameController.text,
                            additionalInfoController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    child: const Text('Erstellen',
                        style: TextStyle(
                          color: textColor,
                        )),
                  ))
            ])
          ],
        );
      },
    );
  }

 */
}