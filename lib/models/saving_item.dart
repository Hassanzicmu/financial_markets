import 'dart:convert';

enum AssetClass { fiat, crypto, metal }

class SavingItem {
  final String id;
  final AssetClass assetClass;
  final String symbol; // e.g., 'usd', 'btc', 'xau'
  final double amount;
  final String? unit; // e.g., 'g', 'oz'
  final DateTime createdAt;
  final DateTime actionDate;
  final double purchaseAmount;
  final String purchaseCurrency;
  final String? notes;

  SavingItem({
    required this.id,
    required this.assetClass,
    required this.symbol,
    required this.amount,
    this.unit,
    required this.createdAt,
    required this.actionDate,
    required this.purchaseAmount,
    required this.purchaseCurrency,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetClass': assetClass.name,
      'symbol': symbol,
      'amount': amount,
      if (unit != null) 'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'actionDate': actionDate.toIso8601String(),
      'purchaseAmount': purchaseAmount,
      'purchaseCurrency': purchaseCurrency,
      if (notes != null) 'notes': notes,
    };
  }

  factory SavingItem.fromMap(Map<String, dynamic> map) {
    return SavingItem(
      id: map['id'] ?? '',
      assetClass: AssetClass.values.firstWhere(
        (e) => e.name == map['assetClass'],
        orElse: () => AssetClass.fiat,
      ),
      symbol: map['symbol'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      actionDate: map['actionDate'] != null ? DateTime.parse(map['actionDate']) : DateTime.now(),
      purchaseAmount: (map['purchaseAmount'] as num?)?.toDouble() ?? 0.0,
      purchaseCurrency: map['purchaseCurrency'] ?? 'usd',
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SavingItem.fromJson(String source) => SavingItem.fromMap(json.decode(source));
}
