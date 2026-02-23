class PaymentTerm {
  final int id;
  final String name;

  PaymentTerm({required this.id, required this.name});

  factory PaymentTerm.fromJson(Map<String, dynamic> json) {
    return PaymentTerm(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() {
    return 'PaymentTerm(id: $id, name: $name)';
  }
}
