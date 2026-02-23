enum RentalScheduleStatus { normal, warning, info }

class RentalScheduleItem {
  final int productId;
  final String productName;
  final String? productImageBase64;
  final String customerName;
  final String orderName;
  final DateTime startDate;
  final DateTime endDate;
  final RentalScheduleStatus status;

  RentalScheduleItem({
    required this.productId,
    required this.productName,
    required this.customerName,
    required this.orderName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.productImageBase64,
  });

  factory RentalScheduleItem.fromGanttRecord(Map<String, dynamic> json) {
    final product = json['product_id'] is Map
        ? json['product_id']
        : {'id': 0, 'display_name': 'Unknown'};
    final order = json['order_id'] is Map
        ? json['order_id']
        : {'id': 0, 'display_name': 'Unknown'};

    final bool isLate = json['is_late'] == true;
    final String rentalStatus = json['rental_status'] ?? '';

    final RentalScheduleStatus status = isLate
        ? RentalScheduleStatus.warning
        : rentalStatus == 'pickup'
        ? RentalScheduleStatus.info
        : RentalScheduleStatus.normal;

    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      return DateTime.tryParse(dateStr) ?? DateTime.now();
    }

    return RentalScheduleItem(
      productId: product['id'] ?? 0,
      productName: product['display_name'] ?? 'Unknown Product',
      productImageBase64: product['image_128'] is String
          ? product['image_128']
          : null,
      customerName: _extractCustomer(json['display_name'] ?? ''),
      orderName: order['display_name'] ?? '',
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['return_date']),
      status: status,
    );
  }

  static String _extractCustomer(String displayName) {
    if (displayName.contains('(') && displayName.contains(')')) {
      try {
        int start = displayName.lastIndexOf('(') + 1;
        int end = displayName.lastIndexOf(')');
        if (end > start) {
          return displayName.substring(start, end);
        }
      } catch (_) {}
    }
    return displayName.split(',').first;
  }
}
