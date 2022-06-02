import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  DBHelper._privateConstructor();

  static DBHelper dbHelper = DBHelper._privateConstructor();

  late Database _database;

  Future<Database> get database async {
    _database = await _createDatabase();

    return _database;
  }

  Future<Database> _createDatabase() async {
    Database database =
        await openDatabase(join(await getDatabasesPath(), 'mydb.db'),
            onCreate: (Database db, int version) {
      db.execute(
          "CREATE TABLE Alarms(id INTEGER PRIMARY KEY, location TEXT, timer TEXT, sunrise TEXT, sunset TEXT, sunsetON INTEGER, sunriseON INTEGER)");
    }, version: 1);
    return database;
  }

  Future<int> insertData(Map<String, dynamic> row) async {
    Database db = await database;
    return db.insert("Alarms", row);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    Database db = await database;
    return await db.query("Alarms");
  }

  Future<List<Map<String, dynamic>>> getDatabyLocation(String location) async {
    Database db = await database;
    return await db.query("Alarms", where: "location=?", whereArgs: [location]);
  }

  Future<int> deleteByLocation(String location) async {
    Database db = await database;
    return await db
        .delete("Alarms", where: "location=?", whereArgs: [location]);
  }
}
