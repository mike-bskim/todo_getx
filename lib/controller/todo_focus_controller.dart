import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoFocusController extends GetxController {
  late FocusNode itemFocusNode;
  late FocusNode textFieldFocusNode;
  late TextEditingController textEditingController;

  static TodoFocusController get to => Get.find();

  @override
  void onInit() {
    itemFocusNode = FocusNode();
    textFieldFocusNode = FocusNode();
    textEditingController = TextEditingController();
    super.onInit();
  }

  void requestFocus() {
    // 이건 focus 취득 및 타이틀을 텍스트 또는 텍스트필드로 변환하는 기능
    itemFocusNode.requestFocus();
    // 아래는 수정시, 텍스트필드의 autofocus 및 키보드 자동로딩용
    // 없어도 동작에는 문제가 없음, 약간 불편한 화면처리 정도임
    textFieldFocusNode.requestFocus();
    update();
  }

  @override
  void onClose() {
    itemFocusNode.dispose();
    textFieldFocusNode.dispose();
    textEditingController.dispose();
    super.onClose();
  }
}
