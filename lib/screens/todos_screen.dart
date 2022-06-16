import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/todo_focus_controller.dart';
import '../controller/todo_list_controller.dart';
import '../model/todo_model.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
  const SearchAndFilterTodo({Key? key}) : super(key: key);

  // final debounce = Debounce(milliseconds: 1000);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
// 신규 추가한 controller
          controller: TodosSearch.to.searchWordController,
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
    final currentTodos = FilteredTodos.to.filteredTodos;

    return Obx(() {
      return ListView.separated(
        // 에러가 발생(Vertical viewport was given unbounded height.)하므로
        // 1. 아래 2개의 조건을 줘야 함. primary & shrinkWrap. 이건 전체가 바운딩처리됨.
        // 2. Expanded 조건으로 감싸면 화면전체가 바운딩도지 않고 ShowTodos 만 바운디처리됨
        //    2번으로 할때, 외부에 SingleChildScrollView 가 있으면 2번은 동작하지 않음.
        primary: false,
        shrinkWrap: true,
        itemCount: currentTodos.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(color: Colors.grey);
        },
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
              key: ValueKey(currentTodos[index].id),
              onDismissed: (_) {
                TodosList.to.deleteTodo(id: currentTodos[index].id);
              },
              confirmDismiss: (_) {
                return Get.defaultDialog(
                  title: 'Are you sure?',
                  middleText: 'Do you really want to delete',
                  actions: [
                    ElevatedButton(
                      child: const Text('YES'),
                      onPressed: () {
                        return Get.back(result: true);
                      },
                    ),
                    ElevatedButton(
                      child: const Text('NO'),
                      onPressed: () {
                        return Get.back(result: false);
                      },
                    ),
                  ],
                );
              },
              child: TodoItem(todo: currentTodos[index]));
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
    return GetBuilder<TodoFocusController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Focus(
            focusNode: controller.itemFocusNode,
            onFocusChange: (value) {
              // if value is true, it get the focus
              if (value) {
                controller.textEditingController.text = todo.desc;
                debugPrint('got the focus: "${todo.desc}"');
              } else {
                TodosList.to.editTodo(
                  id: todo.id,
                  desc: controller.textEditingController.text,
                );
                debugPrint('lost the focus: "${todo.desc}"');
              }
            },
            child: ListTile(
              onTap: () {
                debugPrint('click for editing~~');
                controller.requestFocus();
              },
              leading: Checkbox(
                value: todo.completed,
                onChanged: (bool? checked) {
                  debugPrint('clicked toggle button~~');
                  TodosList.to.toggleTodo(id: todo.id);
                },
              ),
              title: controller.itemFocusNode.hasFocus
                  ? TextField(
                      controller: controller.textEditingController,
                      autofocus: true,
                      focusNode: controller.textFieldFocusNode,
                    )
                  : Text(todo.desc),
            ),
          ),
        );
      },
    );
  }
}
