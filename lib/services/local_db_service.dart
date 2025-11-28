import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:narrative/models/user_preference_model.dart';
import 'package:narrative/utils/constants.dart';

class LocalDbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.preferencesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL UNIQUE,
        selectedCategories TEXT NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
    }
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final db = await database;
    await db.insert(
      AppConstants.preferencesTable,
      preferences.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserPreferences?> getUserPreferences(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.preferencesTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return UserPreferences.fromMap(maps.first);
  }
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    final db = await database;
    await db.update(
      AppConstants.preferencesTable,
      preferences.toMap(),
      where: 'userId = ?',
      whereArgs: [preferences.userId],
    );
  }

  Future<void> deleteUserPreferences(String userId) async {
    final db = await database;
    await db.delete(
      AppConstants.preferencesTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> hasPreferences(String userId) async {
    final db = await database;
    final result = await db.query(
      AppConstants.preferencesTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty;
  }

  Future<List<UserPreferences>> getAllPreferences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.preferencesTable,
    );

    return List.generate(maps.length, (i) {
      return UserPreferences.fromMap(maps[i]);
    });
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(AppConstants.preferencesTable);
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}