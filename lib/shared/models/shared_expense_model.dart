class SharedExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;

  SharedExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
  });

  factory SharedExpenseModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return SharedExpenseModel(
      id: id,
      title: json['title'],
      amount: json['amount'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
    };
  }
}