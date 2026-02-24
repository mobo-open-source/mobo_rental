class TaxModel {
  final int id;
  final String name;
  final double amount;

  TaxModel({required this.id, required this.name, required this.amount});

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'] as int,
      name: json['display_name'] ?? 'Unknown Tax',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
