import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_son_pocket/controller/PocketMoneyController.dart';
import 'package:my_son_pocket/vo/PocketMoney.dart';

class PocketMoneyFormView extends StatelessWidget {
  final PocketMoney? arg = Get.arguments;
  final bool isEdit = Get.arguments != null;

  // 상태 관리를 위해 Rx 선언 (GetX 사용)
  // 초기값: 수정 모드이고 금액이 음수면 '지출(false)', 아니면 '수입(true)'
  final RxBool isIncome = true.obs;
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  PocketMoneyFormView({super.key});

  @override
  Widget build(BuildContext context) {
    if (arg != null) {
      titleController.text = arg!.title;
      // 화면 표시용 금액은 항상 양수로 보여줌 (부호는 버튼으로 관리)
      amountController.text = arg!.amount.abs().toString();
      isIncome.value = arg!.amount >= 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEdit ? "다시 적기" : "기록 하기"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png', // 여기에 아들 사진 경로 입력
              fit: BoxFit.cover, // 이미지가 화면에 꽉 차게 조절
            ),
          ),
          // [층 1.5] 배경 이미지 위에 살짝 투명한 검정 레이어 (글자가 더 잘 보이게 함)
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "돈을 썼는지 받았는지 선택해 줘!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // 수입/지출 선택 버튼
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
                const SizedBox(height: 30),
                const Text(
                  "무슨 일이였어?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "무엇을 하셨나요?",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
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
                  decoration: InputDecoration(
                    hintText: "얼마인가요?",
                    suffixText: "원",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
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
                    onPressed: () {
                      // 1. 빈 칸 검사
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        Get.snackbar(
                          "알림",
                          "어디에 썼는지, 얼마인지 모두 적어줘! 😊",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      // 2. 숫자 형식 검사 (tryParse 사용)
                      // 문자가 섞여 있으면 null을 반환합니다.
                      int? rawAmount = int.tryParse(amountController.text);

                      if (rawAmount == null) {
                        // 문자가 입력된 경우
                        Get.snackbar(
                          "숫자만 적어줘!",
                          "금액에는 숫자만 쓸 수 있어. 다시 확인해볼까? 🤔",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                          colorText: Colors.white,
                          icon: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                          ),
                        );
                        return; // 저장하지 않고 종료
                      }

                      // 3. 정상적인 데이터 처리
                      int finalAmount = isIncome.value
                          ? rawAmount.abs()
                          : -rawAmount.abs();

                      Get.find<PocketMoneyController>().addOrUpdate(
                        arg?.id,
                        titleController.text,
                        finalAmount,
                      );

                      // 4. 성공 메시지 출력 후 뒤로 가기
                      Get.back(); // 화면을 먼저 닫고

                      Get.snackbar(
                        "기억 완료!",
                        "${titleController.text} 내역을 잘 적어두었어! 👍",
                        snackPosition: SnackPosition.TOP,
                        // 성공은 위에서 내려오게 하면 더 잘 보여요
                        backgroundColor: Colors.blueAccent.withOpacity(0.8),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                      );
                    },
                    child: Text(
                      isEdit ? "다 고쳤어!" : "기억해줘!",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  // 타입 선택용 커스텀 버튼 위젯
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
