import 'dart:convert';
import 'dart:typed_data';

class Customer {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? image1920;

  Uint8List? _cachedImageBytes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.image1920,
  });

  Uint8List? get imageBytes {
    if (_cachedImageBytes != null) return _cachedImageBytes;
    if (image1920 == null || image1920!.isEmpty) return null;

    try {
      var data = image1920!.trim();
      if (data.contains(',')) {
        data = data.split(',').last.trim();
      }

      final padding = data.length % 4;
      if (padding != 0) {
        data = data.padRight(data.length + (4 - padding), '=');
      }

      final bytes = base64Decode(data);
      if (bytes.length < 4) return null;

      final b0 = bytes[0], b1 = bytes[1], b2 = bytes[2], b3 = bytes[3];
      final isJpeg = b0 == 0xFF && b1 == 0xD8;
      final isPng = b0 == 0x89 && b1 == 0x50 && b2 == 0x4E && b3 == 0x47;

      if (!isJpeg && !isPng) return null;

      _cachedImageBytes = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : '',
      phone: _parseString(json['phone']),
      email: _parseString(json['email']),
      image1920: _parseString(json['image_1920']),
    );
  }

  static String? _parseString(dynamic v) {
    if (v == null || v == false) return null;
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }
}

class Pricelist {
  final int id;
  final String name;

  Pricelist({required this.id, required this.name});

  factory Pricelist.fromJson(Map<String, dynamic> json) {
    return Pricelist(id: json['id'] as int, name: json['name'] as String);
  }
}
