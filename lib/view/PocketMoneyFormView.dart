import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_son_pocket/controller/PocketMoneyController.dart';
import 'package:my_son_pocket/vo/PocketMoney.dart';

class PocketMoneyFormView extends StatelessWidget {
  final PocketMoney? arg = Get.arguments;
  final bool isEdit = Get.arguments != null;

  final RxBool isIncome = true.obs;
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  PocketMoneyFormView({super.key}) {
    // 생성자에서 초기값 세팅 (build 밖으로 분리)
    if (arg != null) {
      titleController.text = arg!.title;
      amountController.text = arg!.amount.abs().toString();
      isIncome.value = arg!.amount >= 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = isEdit
        ? const Color(0xFFFB8C00)
        : const Color(0xFF764ba2);
    final controller = Get.find<PocketMoneyController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context, controller, mainColor),
      body: Stack(
        children: [
          _buildBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeSelector(),
                const SizedBox(height: 30),
                _buildInputFields(),
                const SizedBox(height: 40),
                _buildSubmitButton(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. 앱바 영역 ---
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    PocketMoneyController controller,
    Color mainColor,
  ) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.7),
      title: Text(
        isEdit ? "고치기 ✏️" : "새로 적기 ✨",
        style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close, color: mainColor),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (isEdit)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteDialog(controller, arg!.id),
          ),
      ],
    );
  }

  // --- 2. 배경 이미지 영역 ---
  Widget _buildBackground() {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. 수입/지출 선택 영역 ---
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "돈을 썼는지 받았는지 선택해 줘!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              _buildTypeButton(
                label: "돈을 받았어요!",
                icon: Icons.add_circle,
                color: Colors.blue,
                isSelected: isIncome.value,
                onTap: () => isIncome.value = true,
              ),
              const SizedBox(width: 12),
              _buildTypeButton(
                label: "돈을 썼어요!",
                icon: Icons.remove_circle,
                color: Colors.orange,
                isSelected: !isIncome.value,
                onTap: () => isIncome.value = false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 4. 입력 필드 영역 ---
  Widget _buildInputFields() {
    const primaryColor = Color(0xFF764ba2);

    // 공통 스타일 정의
    InputDecoration inputStyle(String hint, IconData icon, {String? suffix}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 2.5),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "무슨 일이였어?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: inputStyle("무엇을 하셨나요?", Icons.edit_rounded),
        ),
        const SizedBox(height: 25),
        const Text(
          "얼마야?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: inputStyle(
            "얼마인가요?",
            Icons.monetization_on_rounded,
            suffix: "원",
          ),
        ),
      ],
    );
  }

  // --- 5. 저장 버튼 영역 ---
  Widget _buildSubmitButton(PocketMoneyController controller) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => _handleSubmit(controller),
        child: Text(
          isEdit ? "다 고쳤어!" : "기억해줘!",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- 로직: 저장 처리 ---
  void _handleSubmit(PocketMoneyController controller) {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      _showSnackbar("알림", "어디에 썼는지, 얼마인지 모두 적어줘! 😊", Colors.orangeAccent);
      return;
    }

    int? rawAmount = int.tryParse(amountController.text);
    if (rawAmount == null) {
      _showSnackbar(
        "숫자만 적어줘!",
        "금액에는 숫자만 쓸 수 있어. 다시 확인해볼까? 🤔",
        Colors.redAccent,
      );
      return;
    }

    int finalAmount = isIncome.value ? rawAmount.abs() : -rawAmount.abs();
    controller.addOrUpdate(arg?.id, titleController.text, finalAmount);

    Get.back();
    _showSnackbar(
      "기억 완료!",
      "${titleController.text} 내역을 잘 적어두었어! 👍",
      Colors.blueAccent,
      isTop: true,
    );
  }

  // --- 로직: 스낵바 공통 ---
  void _showSnackbar(
    String title,
    String message,
    Color color, {
    bool isTop = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: isTop ? SnackPosition.TOP : SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // --- 로직: 삭제 다이얼로그 (위젯은 기존 그대로 유지하되 가독성만 개선) ---
  void _showDeleteDialog(PocketMoneyController controller, String id) {
    Get.defaultDialog(
      title: "정말 지울까?",
      middleText: "이 기록을 지우면 다시 되돌릴 수 없어! 😮",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      radius: 20,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "아니, 안 할래",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          await controller.deleteItem(id);
          Get.back();
          Get.back();
          _showSnackbar("삭제 완료", "기록이 깨끗하게 지워졌어! ✨", Colors.grey);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "응, 지워줘!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 타입 선택 버튼 빌더
  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
