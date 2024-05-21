import 'package:flutter/material.dart';

import '../dialoghelper.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Function() onConfirmed;

  const DeleteConfirmationDialog({super.key,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Marker löschen'),
      content: const Text('Möchten Sie diesen Marker wirklich löschen?'),
      backgroundColor: DialogHelper.backgroundColor,
      surfaceTintColor: DialogHelper.backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      actions: <Widget>[
        Row(children: <Widget>[
          Expanded(
              child: ElevatedButton(
                onPressed: () {
                  onConfirmed();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DialogHelper.redButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DialogHelper.buttonRadius),
                  ),
                ),
                child: const Text('Ja',
                    style: TextStyle(
                      color: DialogHelper.textColor,
                    )),
              )),
          const SizedBox(width: 11),
          Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DialogHelper.greenButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DialogHelper.buttonRadius),
                  ),
                ),
                child: const Text('Nein',
                    style: TextStyle(
                      color: DialogHelper.textColor,
                    )),
              ))
        ]),
      ],
    );
  }
}