import 'package:flutter/material.dart';

import '../dialoghelper.dart';

class CreationDialog extends StatefulWidget {
  final Function(String, String) onConfirmed;

  const CreationDialog({
    super.key,
    required this.onConfirmed,
  });

  @override
  _CreationDialogState createState() => _CreationDialogState();
}

class _CreationDialogState extends State<CreationDialog> {
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
    /// Controler Initialisieren
    _nameController = TextEditingController();
    _additionalInfoController = TextEditingController();
  }

  @override
  void dispose() {
    /// Controler entfernen
    _nameController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Überprüfung, ob Gerät vertikal oder horizontal ausgerichtet ist
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    /// Festlegung der Größe des Dialogfeldes entsprechend der Ausrichtung des Geräts
    final double dialogWidth = isLandscape
        ? MediaQuery.of(context).size.width * 0.7
        : MediaQuery.of(context).size.width * 0.9;

    return Center(
        child: SingleChildScrollView(
      child: AlertDialog(
        title: const Text('Pilz-Spot erstellen'),
        backgroundColor: DialogHelper.backgroundColor,
        surfaceTintColor: DialogHelper.backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        content: Container(
          width: dialogWidth,
          alignment: Alignment.center,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// Nameninputfeld
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
                /// Inputfeld für zusätzliche Informationen
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
        ),
        actions: <Widget>[
          Row(children: <Widget>[
            /// Abbrechen-Button
            Expanded(
                child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DialogHelper.redButton,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DialogHelper.buttonRadius),
                ),
              ),
              child: const Text('Abbrechen',
                  style: TextStyle(
                    color: DialogHelper.textColor,
                  )),
            )),
            const SizedBox(width: 11),
            /// Erstellen-Button
            Expanded(
                child: ElevatedButton(
              onPressed: () {
                /// Validatorfunktion
                if (formKey.currentState!.validate()) {
                  widget.onConfirmed(
                    _nameController.text.trim(),
                    _additionalInfoController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DialogHelper.greenButton,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DialogHelper.buttonRadius),
                ),
              ),
              child: const Text('Erstellen',
                  style: TextStyle(
                    color: DialogHelper.textColor,
                  )),
            ))
          ])
        ],
      ),
    ));
  }
}
