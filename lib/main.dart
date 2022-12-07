import 'package:flutter/material.dart';
import 'package:sqliteapp/DataBaseHelper.dart';

import 'package:sqliteapp/grocery.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SqliteApp());
}


class SqliteApp extends StatefulWidget {
  const SqliteApp({Key? key}) : super(key: key);

  @override
  State<SqliteApp> createState() => _SqliteAppState();
}

class _SqliteAppState extends State<SqliteApp> {
  int? selectedId; // != null
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //Création d'une navbar
        appBar: AppBar(
          title: TextField(
            controller: textController,
          ),
        ),
        body: Center(
          child: FutureBuilder<List<Grocery>>(
            future: DataBaseHelper.instance.getGroceries(),
            builder: (BuildContext context, AsyncSnapshot<List<Grocery>> snapshot){
              if (!snapshot.hasData) {
                return Center(child: Text('Chargement..'));
              }
              return snapshot.data!.isEmpty
                ? Center(child: Text('Il y a rien dans la BDD gros'))
              : ListView(
                children: snapshot.data!.map((grocery) {
                  return Center(
                    child: ListTile(
                      title: Text(grocery.name),
                      // Quand on appuie sur une donnée, on peux la modifier
                      onTap: (){
                        setState(() {
                          textController.text = grocery.name;
                          selectedId = grocery.id;

                        });
                      },
                      // On maintient pour supprimer
                      onLongPress: (){
                        setState(() {
                          DataBaseHelper.instance.delete(grocery.id!);
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () async {
            //Modification
            selectedId != null
                ? await DataBaseHelper.instance.update(Grocery(id: selectedId, name: textController.text),
            )
            // si on click sur l'icon, on ajoute dans la base de donnée
            : await DataBaseHelper.instance.add(Grocery(name: textController.text),
            );
            //Nettoyage de la zone de texte
            setState(() {
              textController.clear();
            });
          },
        ),
      ),
    );
  }
}


/*
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
}*/
