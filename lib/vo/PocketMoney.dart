// 용돈 내역 모델
class PocketMoney {
  String id;
  String title;
  int amount;
  DateTime date;

  PocketMoney({required this.id, required this.title, required this.amount, required this.date});

  // JSON 변환 (저장용)
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'amount': amount, 'date': date.toIso8601String()};
  factory PocketMoney.fromJson(Map<String, dynamic> json) => PocketMoney(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
  );
}