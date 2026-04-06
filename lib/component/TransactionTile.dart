// 리스트의 각 항목(기록) 위젯
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final dynamic item; // 실제 프로젝트에선 명확한 Model 타입을 쓰시는 게 좋습니다.
  final String formattedAmount;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.item,
    required this.formattedAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = item.amount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isIncome ? Colors.blue.shade50 : Colors.orange.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: isIncome ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          "${item.date.year}년 ${item.date.month}월 ${item.date.day}일",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          "${isIncome ? '+' : ''}$formattedAmount원",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.blueAccent : Colors.redAccent,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
