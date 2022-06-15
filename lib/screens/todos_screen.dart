import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_test/controller/todo_list_controller.dart';

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

class TodoItem extends StatefulWidget {
  final Todo todo;

  const TodoItem({Key? key, required this.todo}) : super(key: key);

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  final itemFocusNode = FocusNode();
  final textFieldFocusNode = FocusNode();
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (value) {
          // if value is true, it get the focus
          if (value) {
            textEditingController.text = widget.todo.desc;
            debugPrint('got the focus: "${widget.todo.desc}"');
          } else {
            TodosList.to.editTodo(
              id: widget.todo.id,
              desc: textEditingController.text,
            );
            debugPrint('lost the focus: "${widget.todo.desc}"');
          }
        },
        child: ListTile(
          onTap: () {
            debugPrint('click for editing~~');
            setState(() {
              // 이건 focus 취득 및 타이틀을 텍스트 또는 텍스트필드로 변환하는 기능
              itemFocusNode.requestFocus();
              // 아래는 수정시, 텍스트필드의 autofocus 및 키보드 자동로딩용
              // 없어도 동작에는 문제가 없음, 약간 불편한 화면처리 정도임
              textFieldFocusNode.requestFocus();
            });
          },
          leading: Checkbox(
            value: widget.todo.completed,
            onChanged: (bool? checked) {
              debugPrint('clicked toggle button~~');
              TodosList.to.toggleTodo(id: widget.todo.id);
            },
          ),
          title: itemFocusNode.hasFocus
              ? TextField(
                  controller: textEditingController,
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                )
              : Text(widget.todo.desc),
        ),
      ),
    );
  }
}
