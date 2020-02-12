import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_todo/Models/dailyTodo.dart';
import 'package:flutter_app_todo/Screens/daily_screens/daily_detail.dart';
import 'package:flutter_app_todo/Utils/daily_database_helper.dart';
import 'package:sqflite/sqflite.dart';

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
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: width / 4,
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('Daily'),
                  onPressed: () {},
                ),
              ),
              Container(
                width: width / 4,
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('Weekly'),
                  onPressed: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(builder: (context) => WeeklyList()),
//                    );
                  },
                ),
              ),
              Container(
                width: width / 4,
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('Monthly'),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          getTodoListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Daily('', '', ''), 'Add Todo');
        },
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getTodoListView() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(getFirstLetter(this.todoList[position].period), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            ),
            title: Text(this.todoList[position].title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(this.todoList[position].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    _delete(context, todoList[position]);
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.todoList[position], 'Edit Todo');
            },
          ),
        );
      },
    );
  }

  //Returns the priority color
//   Color getPriorityColor(int priority) {
//   	switch (priority) {
//   		case 1:
//   			return Colors.red;
//   			break;
//   		case 2:
//   			return Colors.yellow;
//   			break;
//
//   		default:
//   			return Colors.yellow;
//   	}
//   }
  getFirstLetter(String title) {
    return title.substring(0, 1);
  }

//  // Returns the priority icon
//   Icon getPriorityIcon(int priority) {
//   	switch (priority) {
//   		case 1:
//   			return Icon(Icons.play_arrow);
//   			break;
//   		case 2:
//   			return Icon(Icons.keyboard_arrow_right);
//   			break;
//
//   		default:
//   			return Icon(Icons.keyboard_arrow_right);
//   	}
//   }

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
