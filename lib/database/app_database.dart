import 'package:mushroom_finder/database/pointDataModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String fileName = "point_date_model_database.db";

class AppDatabase {
  AppDatabase._init();

  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null ) return _database!;
    _database = await _initializeDB(fileName);
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $idField $idType,
        $latitudeField $doubleType,
        $longitudeField $doubleType,
        $titleField $textType,
        $additionalInformationField $textTypeNullable
      )
    ''');
  }

  Future<Database> _initializeDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<PointDataModel> createPointDataModel(PointDataModel pointDataModel) async {
    final db = await instance.database;
    final id = await db.insert(tableName, pointDataModel.toJson());
    return pointDataModel.copyWith(id: id);
  }

  Future<List<PointDataModel?>> readAllPointDataModels() async {
    final db = await instance.database;
    final result = await db.query(tableName); //Eventuell OrderBY hinzufügen
    return result.map((json) => PointDataModel.fromJson(json)).toList();
  }

  Future<PointDataModel?> readPointDataModelByLatLng(double latitude, double longitude) async {
    final db = await instance.database;
    final result = await db.query(
      tableName,
      where: "$latitudeField = ? AND $longitudeField = ?",
      whereArgs: [latitude, longitude],
    );
    if (result.isNotEmpty) {
      /// Wenn ein Datensatz mit den angegebenen Koordinaten gefunden wurde,
      /// konvertiere ihn in ein PointDataModel-Objekt und gib es zurück
      return PointDataModel.fromJson(result.first);
    } else {
      /// Wenn kein Datensatz mit den angegebenen Koordinaten gefunden wurde,
      /// gib null zurück
      return null;
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }

  Future<int> updatePointDataModel(PointDataModel pointDataModel) async {
    final db = await instance.database;
    return await db.update(
      tableName,
      pointDataModel.toJson(),
      where: "$idField = ?",
      whereArgs: [pointDataModel.id],
    );
  }

  Future<int> deletePointDataModel(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
  }

}