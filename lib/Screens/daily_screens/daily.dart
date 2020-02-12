import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_todo/Models/dailyTodo.dart';
import 'package:flutter_app_todo/Screens/daily_screens/daily_detail.dart';
import 'package:flutter_app_todo/Utils/daily_database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TodoList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DailyList(),
    );
  }
}

class DailyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State<DailyList> {
  dailyDBHelper databaseHelper = dailyDBHelper();
  List<Daily> todoList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (todoList == null) {
      todoList = List<Daily>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Todos'),
      ),
      body: getTodoListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Daily('', '', '', ''), 'Add Todo');
        },
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }

  String getDate(String date) {
    DateTime d = DateTime.parse(date);

    var formatter = new DateFormat('dd.MM.yyyy');
    String formatted = formatter.format(d);
    return formatted;
  }

  String getTime(String date) {
    DateTime d = DateTime.parse(date);

    var formatter = new DateFormat('HH:mm');
    String formatted = formatter.format(d);
    return formatted;
  }

  bool checkTime(String date) {
    DateTime d = DateTime.parse(date);

    final date2 = DateTime.now();

    int diffTime = d.difference(date2).inMinutes;
    bool isSame = (diffTime > 0);
    return isSame;
  }

  Widget listViewItems(int position) {
    checkTime(this.todoList[position].date);
    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: getPriorityColor(this.todoList[position].priority),
          child: Text(getFirstLetter(this.todoList[position].period), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
        ),
        Flexible(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      this.todoList[position].title,
                      style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, decorationThickness: 3.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      this.todoList[position].description,
                      overflow: TextOverflow.ellipsis,
                    ),

//                  ),

//                  Text(this.todoList[position].title, style: TextStyle(fontSize :19.0,fontWeight: FontWeight.bold,decoration:
//                  TextDecoration.lineThrough,decorationThickness: 3.0)),
//                  Text(this.todoList[position].description),
                  )
                ],
              ),
            )),
            Container(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      getDate(this.todoList[position].date),
                      style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                    Text(
                      getTime(this.todoList[position].date),
                      style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                  ],
                ))
          ],
        ))
      ],
    );
  }

  getTodoListView() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(height: 80.0, child: Card(elevation: 3.0, color: Colors.white, child: listViewItems(position))),
          actions: <Widget>[
            IconSlideAction(
              caption: 'Update',
              color: Colors.indigo,
              icon: Icons.update,
              onTap: () {
                navigateToDetail(this.todoList[position], 'Edit Todo');
              },
            ),
          ],
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                _delete(context, todoList[position]);
              },
            ),
          ],
        );
      },
    );
  }

  //Returns the priority color
  Color getPriorityColor(String color) {
    switch (color) {
      case 'Low':
        return Colors.blue;
        break;
      case 'Medium':
        return Colors.yellow;
        break;
      case 'High':
        return Colors.red;
        break;

      default:
        return Colors.blue;
    }
  }

  getFirstLetter(String title) {
    return title.substring(0, 1);
  }

  void _delete(BuildContext context, Daily todo) async {
    int result = await databaseHelper.deleteTodo(todo.id);
    if (result != 0) {
      _showSnackBar(context, 'Todo Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Daily todo, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TodoDetail(todo, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Daily>> todoListFuture = databaseHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          print('todo list ; $todoList');
          this.count = todoList.length;
        });
      });
    });
  }
}
