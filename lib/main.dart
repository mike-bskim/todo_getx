import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/todo_binding.dart';
import 'screens/todos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GetMaterialApp 으로 변경, from MaterialApp
    return GetMaterialApp(
      // 화면이 하나라서 초기 바인딩으로 dependency injection 함
      initialBinding: TodoBinding(),
      title: 'TODOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodosScreen(),
    );
  }
}
