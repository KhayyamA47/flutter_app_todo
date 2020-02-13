import 'package:flutter/material.dart';
import 'package:flutter_app_todo/Models/dailyTodo.dart';
import 'package:flutter_app_todo/dbHelper/daily_database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:jiffy/jiffy.dart';

class TodoDetail extends StatefulWidget {
  final String appBarTitle;
  final Todo todo;

  TodoDetail(this.todo, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TodoDetailState(this.todo, this.appBarTitle);
  }
}

class TodoDetailState extends State<TodoDetail> {
  dailyDBHelper helper = dailyDBHelper();
  String appBarTitle;
  Todo todo;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
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
          moveToLastScreen();
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration:
                        InputDecoration(labelText: 'Title', labelStyle: textStyle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
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
                              if (titleController.text != null &&
                                  titleController.text != '' &&
                                  descriptionController.text != null &&
                                  descriptionController.text != '' &&
                                  BasicDateTimeField.resultTime != null &&
                                  BasicDateTimeField.resultTime != '') {
                                if (checkTime(BasicDateTimeField.resultTime) == false) {
                                  _displaySnackBar(context, 'Already passed');
                                } else {
                                  _save();
                                }
                              } else {
                                _displaySnackBar(context, 'Please,fill all boxes');
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

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descriptionController.text;
  }

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _save() async {
    moveToLastScreen();
    todo.date = Jiffy(BasicDateTimeField.resultTime).add(minutes: 2).toString();

    todo.priority = priorityValue;
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
      Fluttertoast.showToast(
          msg: "Todo Saved Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      // Failure
      Fluttertoast.showToast(
          msg: "Problem Saving Todo",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  bool checkTime(DateTime date) {
    if (date != null) {
      final now = DateTime.now();
      int diffTime = date.difference(now).inSeconds;
      bool isSame = (diffTime > 0);
      return isSame;
    } else {
      _displaySnackBar(context, 'Please,set date and time');
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (todo.id == null) {
      _showAlertDialog('Status', 'No Todo was deleted');
      return;
    }

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
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    ]);
  }
}
