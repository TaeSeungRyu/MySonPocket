import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PocketMoneyFormView extends StatelessWidget {
  final bool isEdit = Get.arguments != null;
  final titleController = TextEditingController(text: Get.arguments?.title ?? "");
  final amountController = TextEditingController(text: Get.arguments?.amount.toString() ?? "");

  PocketMoneyFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "내역 수정" : "내역 추가")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "제목 (예: 과자 사먹음)")),
            TextField(controller: amountController, decoration: InputDecoration(labelText: "금액"), keyboardType: TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 저장/수정 로직 실행 후 이전 화면으로 이동
                Get.back();
              },
              child: Text(isEdit ? "수정하기" : "등록하기"),
            )
          ],
        ),
      ),
    );
  }
}