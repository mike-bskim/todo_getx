import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_test/controller/todo_list_controller.dart';

import '../model/todo_model.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              children: const [
                TodoHeader(),
                CreateTodo(),
                SizedBox(height: 20.0),
                SearchAndFilterTodo(),
                ShowTodos(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoHeader extends StatelessWidget {
  const TodoHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'TODO',
          style: TextStyle(fontSize: 40.0),
        ),
        Obx(() {
          return Text(
            '${ActiveCount.to.activeCount} items left',
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.redAccent,
            ),
          );
        }),
      ],
    );
  }
}

class CreateTodo extends StatefulWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  _CreateTodoState createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  final newTodoController = TextEditingController();

  @override
  void dispose() {
    newTodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: newTodoController,
      decoration: const InputDecoration(labelText: 'What to do?'),
      onFieldSubmitted: (String? todoDesc) {
        debugPrint('CreateTodo Clicked: ${newTodoController.text}');
        if (todoDesc != null && todoDesc.trim().isNotEmpty) {
          TodosList.to.addTodo(todoDesc: todoDesc);
          newTodoController.clear();
        }
      },
    );
  }
}

class SearchAndFilterTodo extends StatelessWidget {
  //StatelessWidget
  const SearchAndFilterTodo({Key? key}) : super(key: key);

  // String clickedType = 'all';

  // final debounce = Debounce(milliseconds: 1000);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Search todos',
            border: InputBorder.none,
            filled: true,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (String? newSearchTerm) {
            debugPrint('Search todos: $newSearchTerm');
            if (newSearchTerm != null) {
              // debounce.run(() {
              TodosSearch.to.searchWord.value = newSearchTerm;
              // });
            }
          },
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            filterButton(context, Filter.all),
            filterButton(context, Filter.active),
            filterButton(context, Filter.completed),
          ],
        ),
      ],
    );
  }

  Widget filterButton(BuildContext context, Filter filter) {
    //, Filter filter
    return TextButton(
      onPressed: () {
        // 일반적으로는 함수처리해야 함. 직접 접근하지 말것
        TodosFilter.to.todosFilter.value = filter;
        debugPrint('Clicked button $filter');
      },
      child: Obx(
        () => Text(
          filter == Filter.all
              ? 'All'
              : filter == Filter.active
                  ? 'Active'
                  : 'Completed',
          style: TextStyle(
            fontSize: 18.0,
            color: textColor(context, filter),
            fontWeight: textFontWeight(context, filter),
          ),
        ),
      ),
    );
  }

  Color textColor(BuildContext context, Filter filter) {
    //Filter filter
    final currentFilter = TodosFilter.to.todosFilter;
    return currentFilter.value == filter ? Colors.blue : Colors.grey;
  }

  FontWeight textFontWeight(BuildContext context, Filter filter) {
    var currentFilter = TodosFilter.to.todosFilter;
    return currentFilter.value == filter ? FontWeight.bold : FontWeight.normal;
  }
}

class ShowTodos extends StatelessWidget {
  const ShowTodos({Key? key}) : super(key: key);

  Widget showBackground(int direction) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      color: Colors.red,
      alignment: direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(
        Icons.delete,
        size: 30.0,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final todos = context.watch<FilteredTodos>().state.filteredTodos;
    final currentTodos = FilteredTodos.to.filteredTodos;

    return Obx(() {
      return ListView.separated(
        primary: false,
        shrinkWrap: true,
        itemCount: currentTodos.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(color: Colors.grey);
        },
        itemBuilder: (BuildContext context, int index) {
          return TodoItem(todo: currentTodos[index]);
        },
      );
    });
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.completed,
        onChanged: (bool? checked) {
          debugPrint('clicked toggle button~~');
          TodosList.to.toggleTodo(id: todo.id);
        },
      ),
      title: Text(todo.desc),
    );
  }
}
