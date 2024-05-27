import 'package:flutter/material.dart';

import '../dialoghelper.dart';

class EditDialog extends StatefulWidget {
  final String markerTitle;
  final String markerAdditionalInformation;
  final Function(String, String) onConfirmed;

  const EditDialog({
    super.key,
    required this.markerTitle,
    required this.markerAdditionalInformation,
    required this.onConfirmed,
  });

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  /// Key zum Initialisieren der Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  /// Controler, um die Informationen des Namen-Inputfelds abrufen zu können
  late TextEditingController _nameController;
  /// Controler, um die Informationen des zusätzliche Informationen-Inputfelds
  /// abrufen zu können
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    /// Controler Initialisieren mit bereits vorhandenen Werten
    /// Dadurch werden Inputfelder direkt mit diesen Werten gefüllt
    _nameController = TextEditingController(text: widget.markerTitle);
    _additionalInfoController =
        TextEditingController(text: widget.markerAdditionalInformation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: AlertDialog(
      title: const Text('Pilz-Spot bearbeiten'),
      backgroundColor: DialogHelper.backgroundColor,
      surfaceTintColor: DialogHelper.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      content: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// Inputfield für Name
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    icon: Icon(Icons.bookmark),
                    hintText: 'Bitte gib den Namen des Markers ein',
                    labelText: 'Name *'),
                /// validator -> Name muss vorhanden sein
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gebe einen Namen ein';
                  }
                  return null;
                }),
            const SizedBox(height: 20),
            /// Inputfield für zusätzliche Informationen
            TextFormField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.book),
                  hintText: 'Gib zusätzliche Informationen ein',
                  labelText: 'Zusätzliche Informationen:'),
              minLines: 1,
              // any number you need (It works as the rows for the textarea)
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const SizedBox(height: 20)
          ],
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
              backgroundColor: DialogHelper.redButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    DialogHelper.buttonRadius), // Eckenradius anpassen
              ),
            ),
            child: const Text('Abbrechen',
                style: TextStyle(
                  color: DialogHelper.textColor,
                )),
          )),
          const SizedBox(width: 11),
          Expanded(
              child: ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                widget.onConfirmed(
                  _nameController.text,
                  _additionalInfoController.text,
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DialogHelper.greenButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    DialogHelper.buttonRadius), // Eckenradius anpassen
              ),
            ),
            child: const Text('Übernehmen',
                style: TextStyle(
                  color: DialogHelper.textColor,
                )),
          ))
        ]),
      ],
    )));
  }
}
