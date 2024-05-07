import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class DialogHelper {
  final BuildContext context;
  final LatLng latLng;
  final void Function(LatLng, String, String) addPinWithLabelDialogHelper;

  DialogHelper(
      {required this.context,
      required this.latLng,
      required this.addPinWithLabelDialogHelper});

  Future<void> showMyCreationDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController additionalInfoController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilz-Spot erstellen'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
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
                        1, // any number you need (It works as the rows for the textarea)
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
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Abbrechen',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    addPinWithLabelDialogHelper(latLng, nameController.text,
                        additionalInfoController.text);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                child: const Text('Erstellen',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ])
          ],
        );
      },
    );
  }
}
