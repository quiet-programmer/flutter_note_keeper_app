import 'package:flutter/material.dart';
import 'package:note_keeper/models/note.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  //all variable goes here
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop:() {
        //code to control what the user sees when he press the back button
        debugPrint('Go back');
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                debugPrint('Go back');
                moveToLastScreen();
              }),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, right: 10.0, left: 10.0),
          child: ListView(
            children: <Widget>[
              //First Element

              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint("It's working");
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),

              //Second Element

              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Title is being tasked');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              //Third Element

              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Description is being Tasked');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              //Fourth Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    //First Element
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          "Save",
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint('save button is been tasked');
                            _save();
                          });
                        },
                      ),
                    ),

                    Container(
                      width: 5.0,
                    ),

                    //Second Element
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          "Delete",
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint('delete button is been tasked');
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    //function to go back
    Navigator.pop(context, true);
  }

  //convert the string value in the form of integer before saving it to database
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;

      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //convert the int priority to the string priority
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0]; //High
        break;

      case 2:
        priority = _priorities[1]; // Low
        break;
    }
    return priority;
  }

  //update the title
  void updateTitle(){
    note.title = titleController.text;
  }

  //update the description
  void updateDescription(){
    note.description = descriptionController.text;
  }

  // save data to the database
  void _save() async{
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id != null){
      //update operation
      result = await helper.updateNote(note);
    } else {
      //insert operation
      result = await helper.insertNote(note);
    }

    if(result != 0){
      //success
      _showAlertDialog('Status', 'Note has been saved');
    } else {
      //failure
      _showAlertDialog('Status', 'Problem while running');
    }
  }

  void _delete() async{

    moveToLastScreen();

    //if the user is trying to delete a new note
    if(note.id == null){
      _showAlertDialog('Status', 'Note was not deleted');
      return;
    }

    //user is trying to delete a date in the database
    int result = await helper.deleteNote(note.id);

    if(result != 0){
      _showAlertDialog('Status', 'Note has been deleted');
    } else {
      _showAlertDialog('Status', 'Error in performing Task');
    }
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}
