class QuoteDocument {
  final int id;
  final String name;
  bool isSelected;
  

  QuoteDocument({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  factory QuoteDocument.fromJson(Map<String, dynamic> json) {
    return QuoteDocument(
      id: json['id'],
      name: json['name'],
      isSelected: json['is_selected'] ?? false,
    );
  }
}
class QuoteLine {
  final int lineId;
  final String productName;
  final List<QuoteDocument> files;

  QuoteLine({
    required this.lineId,
    required this.productName,
    required this.files,
  });

  factory QuoteLine.fromJson(Map<String, dynamic> json) {
    return QuoteLine(
      lineId: json['id'],
      productName: json['name'],
      files: (json['files'] as List)
          .map((f) => QuoteDocument.fromJson(f))
          .toList(),
    );
  }
}

class QuoteBuilderData {
  List<QuoteDocument> headers = [];
  List<QuoteDocument> footers = [];
  List<QuoteLine> lines = []; 
}
