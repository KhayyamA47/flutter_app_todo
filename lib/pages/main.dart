import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_todo/Models/todo.dart';
import 'package:flutter_app_todo/dbHelper/database_hepler.dart';
import 'package:flutter_app_todo/pages/todo_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

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
  List<Todo> todoList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (todoList == null) {
      todoList = List<Todo>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: getTodoListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          navigateToDetail(Todo('', '', '', ''), 'Add Todo');
        },
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }

  String getDate(String date) {
    DateTime d = DateTime.parse(date);
    var pattern = new DateFormat('dd.MM.yyyy');
    String formatted = pattern.format(d);
    return formatted;
  }

  String getTime(String date) {
    DateTime d = DateTime.parse(date);
    var pattern = new DateFormat('HH:mm');
    String formatted = pattern.format(d);
    return formatted;
  }

  bool checkTime(String date) {
    DateTime d = DateTime.parse(date);
    final now = DateTime.now();
    int diffTime = d.difference(now).inMinutes;
    bool isSame = (diffTime > 0);
    return isSame;
  }

  Widget listViewItems(int position) {
    checkTime(this.todoList[position].date);
    return ListTile(
onLongPress: (){

  print('Long press');
},
        title:Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 8.0),
          child: CircleAvatar(

            backgroundColor: getPriorityColor(this.todoList[position].priority),
          ),
        ),
        Flexible(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      this.todoList[position].title,
                      style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                          decoration: !checkTime(this.todoList[position].date) ? TextDecoration.lineThrough : TextDecoration.none,
                          decorationThickness: 2.5),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                    ),
                  ),
                  Flexible(
                      child: Container(
                    child: Text(
                      this.todoList[position].description,
                      style: TextStyle(
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                          decoration: !checkTime(this.todoList[position].date) ? TextDecoration.lineThrough : TextDecoration.none,
                          decorationThickness: 1.5),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                    ),
                  ))
                ],
              ),
            )),
            Container(
                margin: EdgeInsets.only(bottom: 8.0),
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
    ));
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
          child: Container(
              height: 80.0,
              child: Card(
                  elevation: 3.0,
                  color: !checkTime(this.todoList[position].date) ? Colors.blueGrey.withOpacity(0.46) : Colors.white,
                  child: listViewItems(position))),
          actions: <Widget>[
            checkTime(this.todoList[position].date)
                ? IconSlideAction(
                    caption: 'Update',
                    color: Colors.indigo,
                    icon: Icons.update,
                    onTap: () {
                      navigateToDetail(this.todoList[position], 'Edit Todo');
                    },
                  )
                : null
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

  void _delete(BuildContext context, Todo todo) async {
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

  void navigateToDetail(Todo todo, String title) async {
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
      Future<List<Todo>> todoListFuture = databaseHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          this.count = todoList.length;
        });
      });
    });
  }
}
