class PaymentTerm {
  final int id;
  final String name;

  PaymentTerm({required this.id, required this.name});

  factory PaymentTerm.fromJson(Map<String, dynamic> json) {
    return PaymentTerm(id: json['id'] as int, name: json['name'] as String);
  }
}
