import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper; //singleton Database Helper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';


  //names constructor to create instance of DatabaseHelper
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {

    if(_databaseHelper == null) {
      // this is executed only once singleton object
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {

    if(_database == null){
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async{
    //ge the directory path for both Android and IOS to store Database
    Directory directory = await getApplicationDocumentsDirectory();

    String path = directory.path + 'notes.db';

    //open/ create database at given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async{

    await db.execute("CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription Text, $colPriority INTEGER, $colDate TEXT)");
  }

  // fetch data
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;

//    var result = await db.rawQuery("SELECT * FROM $noteTable ORDER BY $colPriority ASC");
      var result = await db.query(noteTable, orderBy: '$colPriority ASC');
      return result;
  }

  // insert data
  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //update data
  Future<int> updateNote(Note note) async{
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //delete data
  Future<int> deleteNote(int id) async{
     var db = await this.database;
     int result = await db.rawDelete("DELETE FROM $noteTable WHERE $colId = $id");
     return result;
  }

  //get the number of notes
  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery("SELECT COUNT (*) FROM $noteTable");
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //get the list of map from the database and convert it to the note list
  Future<List<Note>> getNoteList() async{

    var noteMapList = await getNoteMapList(); // get map list from database
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();

    for(int i = 0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}