import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqliteapp/grocery.dart';

class DataBaseHelper{
  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

  // Si "_database" n'existe pas le "_initDatabase()" vas l'initialiser
  static Database? _database;
  Future<Database> get database async => _database??= await _initDatabase();

  // Création de la database
  Future<Database> _initDatabase() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'groceries.db');
    return await openDatabase(
      path,
      version: 1,
      //onCreate permet de créer la base de donnée si elle existe pas
      onCreate: _onCreate,
    );
  }

  // Création de la fonction _onCreate pour créer la table et son contenue
  Future _onCreate(Database db, int version) async{
    await db.execute('''
      CREATE TABLE groceries(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
  }

  // Fonction pour récupèrer le contenue d'une table
  Future<List<Grocery>> getGroceries() async{
    Database db = await instance.database;
    var groceries = await db.query('groceries', orderBy:'name');
    List<Grocery> groceryList = groceries.isNotEmpty
        ? groceries.map((c) => Grocery.fromMap(c)).toList()
        :[];
    return groceryList;
  }
  //Fonction pour ajouter dans la base de donnée
  Future<int> add(Grocery grocery) async{
    Database db = await instance.database;
    return await db.insert('groceries', grocery.toMap());
  }

  //Fonction pour supprimer dans la base de donnée
  Future<int> delete(int id) async{
    Database db = await instance.database;
    return await db.delete('groceries', where: 'id = ?', whereArgs: [id]);
  }

  //Fonction pour modifier dans la base de donnée
  Future<int> update(Grocery grocery) async{
    Database db = await instance.database;
    return await db.update('groceries', grocery.toMap(), where: 'id = ?', whereArgs: [grocery.id]);
  }
}