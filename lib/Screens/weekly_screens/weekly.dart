import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_todo/Models/weeklyTodo.dart';
import 'package:flutter_app_todo/Screens/daily_screens/daily_detail.dart';
import 'package:flutter_app_todo/Screens/daily_screens/daily.dart';
import 'package:flutter_app_todo/Screens/weekly_screens/weekly_detail.dart';
import 'package:flutter_app_todo/Utils/weekly_database_helper.dart';

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
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      home: WeeklyList(),
    );
  }
}
class WeeklyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State<WeeklyList> {


  weeklyDBHelper _weeklyDBHelper = weeklyDBHelper();
  List<Weekly> weeklyToDo;
  int weeklyCount=0;




  @override
  Widget build(BuildContext context) {
    print('WEEKLY');
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;


    if (weeklyToDo == null) {
      weeklyToDo = List<Weekly>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Todos'),
      ),
      body:Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: width/4,
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('Daily'),
                  onPressed: (){

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DailyList()),
                    );

                  },
                ),
              ),
              Container(
                width: width/4,
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('Weekly'),
                  onPressed: (){


                  },
                ),
              ),
              Container(
                width: width/4,
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('Monthly'),
                  onPressed: (){
                  },
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
          navigateToDetail(Weekly('', '', ''), 'Add Todo');
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
      itemCount: weeklyCount,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(getFirstLetter(this.weeklyToDo[position].title),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(this.weeklyToDo[position].title,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(this.weeklyToDo[position].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.delete,color: Colors.red,),
                  onTap: () {
                    _delete(context, weeklyToDo[position]);
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.weeklyToDo[position], 'Edit Todo');
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
    return title.substring(0, 2);
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

  void _delete(BuildContext context, Weekly todo) async {
    int result = await _weeklyDBHelper.deleteTodo(todo.id);
    if (result != 0) {
      _showSnackBar(context, 'Todo Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Weekly todo, String title) async {
    bool result =
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WeeklyDetail(todo, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = _weeklyDBHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Weekly>> todoListFuture = _weeklyDBHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.weeklyToDo = todoList;
          this.weeklyCount = todoList.length;
        });
      });
    });
  }


}
