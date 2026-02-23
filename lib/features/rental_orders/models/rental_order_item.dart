
import 'package:mobo_rental/features/rental_orders/models/fetched_order_line_model.dart';

class RentalOrderItem {
  final int customerId;
  final String currencyName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerImage1920;
  final DateTime? writeDate;
  final DateTime? createDate;

  final String customer;
  final String customerAddress;
  final String street;
  final String street2;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String code;
  final double amount;
  final String status;
  final String startDate;
  final String endDate;
  final int id;

  final String? paymentTerm;
  final DateTime? orderDate;
  final String? deliveryAddress;
  final List<FetchedOrderLineModel> orderLine;
  final bool? isQuoteAvailable;

  final String salesperson;
  final String salesTeam;
  final bool onlineSignature;
  final bool onlinePayment;
  final String reference;
  final List<int> tagIds;
  final String fiscalPosition;
  final String incoterm;
  final String warehouse;
  final String deliveryDate;
  final String sourceDocument;
  final String opportunity;
  final String campaign;
  final String source;
  final String medium;
  final String signedBy;
  final String signedOn;
  final String signatureBytes;
  final int deliveryCount;
  final int invoiceCount;

  RentalOrderItem({
    this.createDate,
    required this.currencyName,
    this.writeDate,
    required this.customerId,
    required this.customer,
    this.customerPhone,
    this.customerEmail,
    this.customerImage1920,
    required this.customerAddress,
    required this.street,
    required this.street2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.code,
    required this.amount,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.paymentTerm,
    this.orderDate,
    this.deliveryAddress,
    required this.id,
    required this.orderLine,
    this.isQuoteAvailable,
    required this.salesperson,
    required this.salesTeam,
    required this.onlineSignature,
    required this.onlinePayment,
    required this.reference,
    required this.tagIds,
    required this.fiscalPosition,
    required this.incoterm,
    required this.warehouse,
    required this.deliveryDate,
    required this.sourceDocument,
    required this.opportunity,
    required this.campaign,
    required this.source,
    required this.medium,
    required this.signedBy,
    required this.signedOn,
    required this.signatureBytes,
    required this.deliveryCount,
    required this.invoiceCount,
  });

  factory RentalOrderItem.fromJson(
    Map<String, dynamic> order, {
    String serverVersion = '19',
  }) {
    String parseCurrencyName(dynamic value) {
      if (value == null) return 'USD';
      if (value is List && value.length > 1) {
        return value[1].toString();
      }
      if (value is Map && value.containsKey('display_name')) {
        return value['display_name'].toString();
      }
      return 'USD';
    }

    int safeId(dynamic value) {
      if (value is List && value.isNotEmpty && value[0] is int) {
        return value[0] as int;
      }
      return 0;
    }

    DateTime? parseCreateDate(dynamic value) {
      if (value == null || value == false) return null;
      try {
        return DateTime.parse(value.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    String safeString(dynamic value, {String fallback = ''}) {
      if (value == null || value == false) return fallback;
      if (value is List && value.length > 1) return value[1].toString();
      return value.toString();
    }

    String? safePartnerField(dynamic value) {
      if (value == null || value == false) return null;
      if (value is String && value.trim().isNotEmpty) return value.trim();
      return null;
    }

    List<int> getIds(dynamic field) {
      if (field is List) {
        return field.map((e) => e as int).toList();
      }
      return [];
    }

    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    }

    DateTime? parseWriteDate(dynamic value) {
      if (value == null || value == false) return null;
      try {
        return DateTime.parse(value.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    return RentalOrderItem(
      currencyName: parseCurrencyName(order['currency_id']),
      id: order['id'] as int,
      createDate: parseCreateDate(order['create_date']),
      writeDate: parseWriteDate(order['write_date']),
      customerId: safeId(order['partner_id']),
      customer: safeString(order['partner_id'], fallback: 'Unknown Customer'),
      customerPhone: safePartnerField(order['partner_phone']),
      customerEmail: safePartnerField(order['partner_email']),
      customerImage1920: safePartnerField(order['partner_image_1920']),
      code: safeString(order['name'], fallback: 'N/A'),
      amount: (order['amount_total'] as num?)?.toDouble() ?? 0.0,
      status: safeString(order['rental_status'], fallback: 'draft'),
      startDate: safeString(order['rental_start_date'], fallback: ''),
      endDate: safeString(order['rental_return_date'], fallback: ''),
      paymentTerm: _parsePaymentTerm(order['payment_term_id']),
      orderDate: _parseOrderDate(order['date_order']),
      deliveryAddress: _parseDeliveryAddress(order['partner_shipping_id']),
      orderLine: const [],
      isQuoteAvailable: order['is_pdf_quote_builder_available'] ?? false,
      salesperson: safeString(order['user_id']),
      salesTeam: safeString(order['team_id']),
      onlineSignature: order['require_signature'] == true,
      onlinePayment: order['require_payment'] == true,
      reference: safeString(order['client_order_ref']),
      tagIds: getIds(order['tag_ids']),
      fiscalPosition: safeString(order['fiscal_position_id']),
      incoterm: safeString(order['incoterm']),
      warehouse: safeString(order['warehouse_id']),
      deliveryDate: safeString(order['commitment_date']),
      sourceDocument: safeString(order['origin']),
      opportunity: safeString(order['opportunity_id']),
      campaign: safeString(order['campaign_id']),
      source: safeString(order['source_id']),
      medium: safeString(order['medium_id']),
      customerAddress: '',
      street: '',
      street2: '',
      city: '',
      state: '',
      zip: '',
      country: '',
      signedBy: safeString(order['signed_by']),
      signedOn: safeString(order['signed_on']),
      signatureBytes: safeString(order['signature']),
      deliveryCount: safeInt(order['delivery_count']),
      invoiceCount: safeInt(order['invoice_count']),
    );
  }

  RentalOrderItem copyWith({
    String? currencyName,
    DateTime? writeDate,
    int? customerId,
    String? customer,
    String? customerPhone,
    String? customerEmail,
    String? customerImage1920,
    String? customerAddress,
    String? street,
    String? street2,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? code,
    double? amount,
    String? status,
    String? startDate,
    String? endDate,
    int? id,
    String? paymentTerm,
    DateTime? orderDate,
    String? deliveryAddress,
    List<FetchedOrderLineModel>? orderLine,
    bool? isQuoteAvailable,
    String? salesperson,
    String? salesTeam,
    bool? onlineSignature,
    bool? onlinePayment,
    String? reference,
    List<int>? tagIds,
    String? fiscalPosition,
    String? incoterm,
    String? warehouse,
    String? deliveryDate,
    String? sourceDocument,
    String? opportunity,
    String? campaign,
    String? source,
    String? medium,
    String? signedBy,
    String? signedOn,
    String? signatureBytes,
    int? deliveryCount,
    int? invoiceCount,
  }) {
    return RentalOrderItem(
      writeDate: writeDate ?? this.writeDate,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerImage1920: customerImage1920 ?? this.customerImage1920,
      customerAddress: customerAddress ?? this.customerAddress,
      street: street ?? this.street,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      code: code ?? this.code,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      id: id ?? this.id,
      paymentTerm: paymentTerm ?? this.paymentTerm,
      orderDate: orderDate ?? this.orderDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderLine: orderLine ?? this.orderLine,
      isQuoteAvailable: isQuoteAvailable ?? this.isQuoteAvailable,
      salesperson: salesperson ?? this.salesperson,
      salesTeam: salesTeam ?? this.salesTeam,
      onlineSignature: onlineSignature ?? this.onlineSignature,
      onlinePayment: onlinePayment ?? this.onlinePayment,
      reference: reference ?? this.reference,
      tagIds: tagIds ?? this.tagIds,
      fiscalPosition: fiscalPosition ?? this.fiscalPosition,
      incoterm: incoterm ?? this.incoterm,
      warehouse: warehouse ?? this.warehouse,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      sourceDocument: sourceDocument ?? this.sourceDocument,
      opportunity: opportunity ?? this.opportunity,
      campaign: campaign ?? this.campaign,
      source: source ?? this.source,
      medium: medium ?? this.medium,
      signedBy: signedBy ?? this.signedBy,
      signedOn: signedOn ?? this.signedOn,
      signatureBytes: signatureBytes ?? this.signatureBytes,
      deliveryCount: deliveryCount ?? this.deliveryCount,
      invoiceCount: invoiceCount ?? this.invoiceCount,
      currencyName: currencyName ?? this.currencyName,
    );
  }

  static String? _parseDeliveryAddress(dynamic deliveryAddress) {
    if (deliveryAddress != null &&
        deliveryAddress is List &&
        deliveryAddress.isNotEmpty) {
      return deliveryAddress[1]?.toString();
    }
    return null;
  }

  static String? _parsePaymentTerm(dynamic paymentTermId) {
    if (paymentTermId != null &&
        paymentTermId is List &&
        paymentTermId.isNotEmpty) {
      return paymentTermId[1]?.toString();
    }
    return null;
  }

  static DateTime? _parseOrderDate(dynamic dateOrder) {
    if (dateOrder == null) {
      return null;
    }
    try {
      return DateTime.parse(dateOrder.toString());
    } catch (_) {
      return null;
    }
  }
}
