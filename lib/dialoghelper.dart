import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:text_area/text_area.dart';

class DialogHelper {
  final BuildContext context;
  final LatLng latLng;
  final void Function(LatLng,String) add_Pin_with_Marker;

  DialogHelper({required this.context, required this.latLng, required this.add_Pin_with_Marker});

  Future<void> showMyCreationDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilz-Spot erstellen'),
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          actions: <Widget>[
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.bookmark),
                          hintText: 'Gib den Namen des Markes ein',
                          labelText: 'Name *'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte gebe einen Namen ein';
                        }
                        return null;
                      }),
                  const SizedBox(height: 20),
                  const Text('Zusätzliche Informationen:'),
                  const SizedBox(height: 20),
                  const TextArea(
                      borderRadius: 10,
                      borderColor: const Color(0xFFCFD6FF),
                      validation: false),
                ],
              ),
            ),
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
                    String spotName = nameController.text;
                    add_Pin_with_Marker(latLng, spotName);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                child: const Text('Test Erstellen',
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