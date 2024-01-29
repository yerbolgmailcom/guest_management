import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/property.dart';

class DatabaseService {
  Database? _database;
  final String _dbName = 'properties.db';

  Future<void> _deleteDbIfExists() async {
    String dbPath = join(await getDatabasesPath(), _dbName);
    if (await databaseExists(dbPath)) {
      await deleteDatabase(dbPath);
      print('Database $_dbName deleted');
    }
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    // _deleteDbIfExists();
    // Lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create the table if it doesn't exist
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);

    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE properties(id INTEGER PRIMARY KEY, name TEXT, tenantName TEXT, tenantPhone TEXT)',
        );
        // Prepopulate the database after creation
        await _prepopulateDatabase(db);
      },
      version: 1,
    );
  }

  Future<void> _prepopulateDatabase(Database db) async {
    final List<String> propertyNames = [
      'Коркем 4: 598',
      'Коркем 4: 696',
      'Коркем 4: 663',
      'Коркем 4: 723',
      'Коркем 4: 778',
      'Коркем 4: 803',
      'Коркем 4: 890',
      'Коркем 3: 86',
      'Триумфальная арка: 95',
      'Хайвилл парк: 810',
      'Сеним 1: 66',
      'Сеним 1: 67',
      'Сеним 1: 68',
      'Сеним 1: 46',
      'Сеним 1: 47',
      'Спорт тауерс: 142',
      'Спорт тауерс: 207',
      'Алтыншар 2: 639',
      'Алтыншар 2: 819',
      'Алтыншар 2: 820',
      'Алтыншар 2: 828',
      'Алтыншар 2: 829',
    ];
    List<Property> initialProperties = [
      for (var i = 0; i < propertyNames.length; i++)
        Property(
            id: i + 1, name: propertyNames[i], tenantName: '', tenantPhone: ''),
    ];

    for (var property in initialProperties) {
      await db.insert('properties', property.toMap());
    }
  }

  // Fetch all properties
  Future<List<Property>> getProperties() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('properties');

    return List.generate(maps.length, (i) {
      return Property(
        id: maps[i]['id'],
        name: maps[i]['name'],
        tenantName: maps[i]['tenantName'] ?? '',
        tenantPhone: maps[i]['tenantPhone'] ?? '',
      );
    });
  }

  // Update a property
  Future<void> updateProperty(Property property) async {
    final db = await database;

    await db.update(
      'properties',
      property.toMap(),
      where: 'id = ?',
      whereArgs: [property.id],
    );
  }

  // Insert a property
  Future<void> insertProperty(Property property) async {
    final db = await database;

    await db.insert(
      'properties',
      property.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete a property
  Future<void> deleteProperty(int id) async {
    final db = await database;

    await db.delete(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
