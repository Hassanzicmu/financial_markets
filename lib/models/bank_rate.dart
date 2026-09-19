class BankRate {
  final String name;
  final String buy;
  final String sell;
  final bool isUp;

  BankRate({
    required this.name,
    required this.buy,
    required this.sell,
    required this.isUp,
  });

  factory BankRate.fromJson(Map<String, dynamic> json) {
    return BankRate(
      name: json['name'],
      buy: json['buy'],
      sell: json['sell'],
      isUp: json['isUp'],
    );
  }
}
