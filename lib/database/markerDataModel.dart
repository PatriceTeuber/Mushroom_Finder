const String tableName = "marker_data_model";

const String idField = "_id";
const String latitudeField = "latitude";
const String longitudeField = "longitude";
const String titleField = "title";
const String additionalInformationField = "additional_information";

const List<String> markerDataModelColumns = [
  idField,
  latitudeField,
  longitudeField,
  titleField,
  additionalInformationField,
];

const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
const String doubleType = "DOUBLE NOT NULL UNIQUE";
const String textTypeNullable = "TEXT";
const String textType = "TEXT NOT NULL";

class MarkerDataModel {
  final int? id;
  final double latitude;
  final double longitude;
  final String title;
  final String? additionalInformation;

  MarkerDataModel(
      {this.id,
      required this.latitude,
      required this.longitude,
      required this.title,
      this.additionalInformation});

  static MarkerDataModel fromJson(Map<String, dynamic> json) => MarkerDataModel(
        id: json[idField] as int?,
        latitude: json[latitudeField] as double,
        longitude: json[longitudeField] as double,
        title: json[titleField] as String,
        additionalInformation: json[additionalInformationField] as String,
      );

  Map<String, dynamic> toJson() => {
        idField: id,
        latitudeField: latitude,
        longitudeField: longitude,
        titleField: title,
        additionalInformationField: additionalInformation,
      };

  MarkerDataModel copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? title,
    String? additionalInformation,
  }) => MarkerDataModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      additionalInformation: additionalInformation ?? this.additionalInformation,
  );

}
