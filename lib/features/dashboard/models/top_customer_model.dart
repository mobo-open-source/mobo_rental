import 'dart:convert';
import 'dart:typed_data';

class TopCustomerItem {
  final int customerId;
  final String customerName;
  final int rentalCount;
  final Uint8List? avatarBytes;
  final String? avatarBase64;

  TopCustomerItem({
    required this.customerId,
    required this.customerName,
    required this.rentalCount,
    this.avatarBytes,
    this.avatarBase64,
  });

  static Uint8List? decodeAvatar(dynamic value) {
    if (value == null || value == false) return null;
    if (value is! String || value.isEmpty) return null;

    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }
}
