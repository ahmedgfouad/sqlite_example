import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_example/todo.dart';
import 'package:sqlite_example/todo_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

List<Todo> todoList = [];

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text("Todo App"),
          actions: [
            Text('asdf'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            await showModalBottomSheet(

                context: context,
                builder: (context) {
                  return BottomSheetCustomWidget();
                }
                );
            setState(() {});
          },
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: FutureBuilder<List<Todo>>(
            future: TodoProvider.instance.getAllTodo(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.hasData) {
                todoList = snapshot.data!;
                return ListView.builder(
                  itemCount: todoList.length,
                  itemBuilder: (context, index) {
                    Todo todo = todoList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isChecked,
                          onChanged: (bool? value) async{
                            todoList[index].isChecked = value!;
                            await TodoProvider.instance.updateTodo(todoList[index]);

                            setState(() {});
                          },
                        ),
                        title: Text(todo.name),
                        subtitle: Text(DateTime.fromMillisecondsSinceEpoch(todo.date).toString()),

                           trailing: IconButton(
                            onPressed: () async {
                              if (todo.id != null)
                                await TodoProvider.instance
                                    .deleteTodo(todo.id!);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            )
                           ),
                      ),
                    );
                  },
                );
              }
              return Center(
                child: Container(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BottomSheetCustomWidget extends StatefulWidget {
  const BottomSheetCustomWidget({Key? key}) : super(key: key);

  @override
  State<BottomSheetCustomWidget> createState() =>
      _BottomSheetCustomWidgetState();
}

class _BottomSheetCustomWidgetState extends State<BottomSheetCustomWidget> {
  TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(label: Text('Todo Name')),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)));
                    print(selectedDate.toString());
                    setState(() {});
                  },
                  icon: Icon(Icons.calendar_month)),
              SizedBox(
                width: 20,
              ),
              Text(selectedDate != null
                  ? selectedDate.toString()
                  : "No Date Chosen")
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              TodoProvider.instance.insertTodo(Todo(
                  name: nameController.text,
                  date: selectedDate!.millisecondsSinceEpoch,
                  isChecked: false));
              print(todoList);
              Navigator.pop(context);
            },
            child: Text("ADD"),
          ),
        ],
      ),
    );
  }
}