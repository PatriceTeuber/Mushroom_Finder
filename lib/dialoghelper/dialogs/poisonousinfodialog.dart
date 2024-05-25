import 'package:flutter/material.dart';

import '../dialoghelper.dart';

class PoisonousInfoDialog extends StatelessWidget {
  const PoisonousInfoDialog({super.key});

  static const TextStyle textStyleInfoDialog = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Giftnotrufzentralen'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deutschland',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoSection('Berlin', [
              'Landesberatungsstelle für Vergiftserscheinungen',
              'Tel. (0 30) 1 92 40'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Bonn', [
              'Informationszentrale gegen Vergiftungen',
              'Tel. (02 28) 1 92 40'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Erfurt', [
              'Gemeinsamensames Giftinformationszentrum der Länder Mecklenburg-Vorpommern, Sachsen, Sachsen-Anhalt und Thüringen',
              'Tel. (0 36) 73 07 30'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Freiburg', [
              'Informationszentrum für Vergiftungen',
              'Tel. (07 61) 1 92 40'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Göttingen', [
              'Giftinformationszentrum Nord: GIZ-Nord der Länder Niedersachsen, Bremen, Hamburg, Schleswig-Holstein',
              'Tel. (05 51) 1 92 40'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Homburg', [
              'Informations- und Beratungszentrum für Vergiftungsfälle',
              'Tel. (0 68 41) 1 92 40'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Mainz', [
              'Beratungsstelle bei Vergiftungen',
              'Tel. (0 61 31) 1 92 40'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('München', [
              'Giftnotruf',
              'Tel. (0 89) 1 92 40'
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Nürnberg', [
              'Gifttelefon',
              'Tel. (09 11) 3 98 24 51'
            ]),
            const SizedBox(height: 20),
            const Text(
              'Österreich',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoSection('Wien', [
              'Vergiftungsinformationszentrale',
              'Tel. (01) 4 06 43 43'
            ]),
            const SizedBox(height: 20),
            const Text(
              'Schweiz',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoSection('Zürich', [
              'Tox-Zentrum',
              'Tel. (0 44) 2 51 51 51'
            ]),
          ],
        ),
      ),
      backgroundColor: DialogHelper.backgroundColor,
      surfaceTintColor: DialogHelper.backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DialogHelper.blackButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DialogHelper.buttonRadius),
            ),
          ),
          child: const Text('Verlassen',
              style: TextStyle(
                color: DialogHelper.textColor,
              )),
        )
      ],
    );
  }

  Widget _buildInfoSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: textStyleInfoDialog,
        ),
        for (String detail in details)
          Text(
            detail,
            softWrap: true,
            style: textStyleInfoDialog,
          ),
      ],
    );
  }
}
