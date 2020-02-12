import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_todo/Models/dailyTodo.dart';
import 'package:flutter_app_todo/Screens/daily_screens/daily_detail.dart';
import 'package:flutter_app_todo/Utils/daily_database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
          getTodoListView(),
        ],
      ),
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

  getTodoListView() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Card(
            elevation: 3.0,
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.todoList[position].priority),
                child: Text(getFirstLetter(this.todoList[position].period), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              ),
              title: Text(this.todoList[position].title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(this.todoList[position].description),

            ),
          ),
          actions: <Widget>[
            IconSlideAction(
              caption: 'Update',
              color: Colors.indigo,
              icon: Icons.update,
              onTap: ()  {
                navigateToDetail(this.todoList[position], 'Edit Todo');
              },
            ),
          ],
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap:  () {
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

class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation =
        new Tween(begin: const Offset(0.0, 0.0), end: const Offset(-0.2, 0.0)).animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        // we can access context.size here
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500)
          _controller.animateTo(.0);
        else if (_controller.value >= .5 || data.primaryVelocity < -2500)
          _controller.animateTo(1.0);
        else
          _controller.animateTo(.0);
      },
      child: new Stack(
        children: <Widget>[
          new SlideTransition(position: animation, child: widget.child),
          new Positioned.fill(
            child: new LayoutBuilder(
              builder: (context, constraint) {
                return new AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return new Stack(
                      children: <Widget>[
                        new Positioned(
                          right: .0,
                          top: .0,
                          bottom: .0,
                          width: constraint.maxWidth * animation.value.dx * -2,
                          child: new Container(
                            margin: EdgeInsets.only(top: 8.0),
                            height: MediaQuery.of(context).size.height / 10,
                            color: Colors.white,
                            child: new Row(
                              children: widget.menuItems.map((child) {
                                return new Expanded(
                                  child: child,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
