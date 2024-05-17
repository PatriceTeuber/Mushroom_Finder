import 'package:flutter/material.dart';

import '../dialoghelper.dart';

class CreationDialog extends StatefulWidget {
  final Function(String, String) onConfirmed;

  const CreationDialog({super.key,
    required this.onConfirmed,
  });

  @override
  _CreationDialogState createState() => _CreationDialogState();
}

class _CreationDialogState extends State<CreationDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _additionalInfoController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilz-Spot erstellen'),
      backgroundColor: DialogHelper.backgroundColor,
      surfaceTintColor: DialogHelper.backgroundColor,
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
                  controller: _nameController,
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
                controller: _additionalInfoController,
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
                  backgroundColor: DialogHelper.redButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DialogHelper.buttonRadius),
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
                    borderRadius: BorderRadius.circular(DialogHelper.buttonRadius),
                  ),
                ),
                child: const Text('Erstellen',
                    style: TextStyle(
                      color: DialogHelper.textColor,
                    )),
              ))
        ])
      ],
    );
  }
}