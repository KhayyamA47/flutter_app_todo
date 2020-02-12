import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_todo/Models/dailyTodo.dart';
import 'package:flutter_app_todo/Utils/daily_database_helper.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class TodoDetail extends StatefulWidget {
  final String appBarTitle;
  final Daily todo;

  TodoDetail(this.todo, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TodoDetailState(this.todo, this.appBarTitle);
  }
}

class TodoDetailState extends State<TodoDetail> {
  //static var _priorities = ['High', 'Low'];

  dailyDBHelper helper = dailyDBHelper();

  String appBarTitle;
  Daily todo;
  String period;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String periodValue = 'Daily';
  List<String> periodItems = ['Daily', 'Weekly', 'Monthly'];
  String priorityValue = 'Low';
  List<String> priorityItems = ['Low', 'Medium', 'High'];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TodoDetailState(this.todo, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = todo.title;
    descriptionController.text = todo.description;

    return WillPopScope(
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First element

                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration:
                        InputDecoration(labelText: 'Title', labelStyle: textStyle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration:
                        InputDecoration(labelText: 'Description', labelStyle: textStyle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 15.0, bottom: 15.0), child: BasicDateTimeField()),
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        value: priorityValue,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                        underline: Container(
                          width: 100.0,
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String data) {
                          setState(() {
                            priorityValue = data;
                            print('dropdownValue : $priorityValue');
                          });
                        },
                        items: priorityItems.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: Colors.black, fontSize: 13)),
                          );
                        }).toList(),
                      ),
                    ))),
                // Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              print(" button clicked ${titleController.text}");

                              if (titleController.text != null &&
                                  titleController.text != '' &&
                                  descriptionController.text != null &&
                                  descriptionController.text != '' &&
                                  BasicDateTimeField.resultTime != null &&
                                  BasicDateTimeField.resultTime != '') {
                                print("Save button clicked");
                                _save();
                              }else{
                                _displaySnackBar(context);
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Update the title of todo object
  void updateTitle() {
    todo.title = titleController.text;
  }

  // Update the description of todo object
  void updateDescription() {
    todo.description = descriptionController.text;
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Please,fill all boxes'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  // Save data to database
  void _save() async {
    moveToLastScreen();

    todo.date = BasicDateTimeField.resultTime.toString();
    todo.period = periodValue;
    todo.priority = priorityValue;
    print('period ${todo.priority}');
    int result;
    if (todo.id != null) {
      // Case 1: Update operation
      result = await helper.updateTodo(todo);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertTodo(todo);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Todo Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Todo');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW todo i.e. he has come to
    // the detail page by pressing the FAB of todoList page.
    if (todo.id == null) {
      _showAlertDialog('Status', 'No Todo was deleted');
      return;
    }

    // Case 2: User is trying to delete the old todo that already has a valid ID.
    int result = await helper.deleteTodo(todo.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Todo Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Todo');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  static var resultTime;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        decoration: InputDecoration(
            labelText: 'Choose Date And Time',
            labelStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
        format: format,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(context: context, firstDate: DateTime(1900), initialDate: currentValue ?? DateTime.now(), lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );

            resultTime = DateTimeField.combine(date, time);
            print('time 1 ${DateTimeField.combine(date, time)}');
            return DateTimeField.combine(date, time);
          } else {
            print('time 2 $currentValue}');

            return currentValue;
          }
        },
      ),
    ]);
  }
}
