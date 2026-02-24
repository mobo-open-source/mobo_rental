import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';

class OtherInfoView extends StatelessWidget {
  final RentalOrderItem order;
  final double height;

  const OtherInfoView({super.key, required this.order, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OtherInfoHeading(title: 'SALES'),
            _buildInfoCard(context, isDark, [
              _buildOtherInfoRow(
                context,
                isDark,
                "Salesperson",
                order.salesperson,
              ),
              _buildOtherInfoRow(
                context,
                isDark,
                "Sales Team",
                order.salesTeam,
              ),
              _buildOtherInfoRow(
                context,
                isDark,
                "Online\nSignature",
                order.onlineSignature ? "Yes" : "No",
              ),
              _buildOtherInfoRow(
                context,
                isDark,
                "Online\nPayment",
                order.onlinePayment ? "Yes" : "No",
              ),
              _buildOtherInfoRow(context, isDark, "Reference", order.reference),
              _buildOtherInfoRow(
                context,
                isDark,
                "Tags",
                order.tagIds.isEmpty
                    ? "Not specified"
                    : order.tagIds.join(', '),
                isLast: true,
              ),
            ]),

            SizedBox(height: height * 0.01),
            const OtherInfoHeading(title: 'INVOICING'),
            _buildInfoCard(context, isDark, [
              _buildOtherInfoRow(
                context,
                isDark,
                "Payment\nTerms",
                order.paymentTerm ?? 'No Payment Terms',
              ),
              _buildOtherInfoRow(
                context,
                isDark,
                "Fiscal Position",
                order.fiscalPosition,
                isLast: true,
              ),
            ]),

            SizedBox(height: height * 0.01),
            const OtherInfoHeading(title: 'SHIPPING'),
            _buildInfoCard(context, isDark, [
              _buildOtherInfoRow(context, isDark, "Incoterm", order.incoterm),
              _buildOtherInfoRow(context, isDark, "Warehouse", order.warehouse),
              _buildOtherInfoRow(
                context,
                isDark,
                "Delivery Date",
                order.deliveryDate,
                isLast: true,
              ),
            ]),

            SizedBox(height: height * 0.01),
            const OtherInfoHeading(title: 'TRACKING'),
            _buildInfoCard(context, isDark, [
              _buildOtherInfoRow(
                context,
                isDark,
                "Source\nDocument",
                order.sourceDocument,
              ),
              _buildOtherInfoRow(
                context,
                isDark,
                "Opportunity",
                order.opportunity,
              ),
              _buildOtherInfoRow(context, isDark, "Campaign", order.campaign),
              _buildOtherInfoRow(context, isDark, "Source", order.source),
              _buildOtherInfoRow(
                context,
                isDark,
                "Medium",
                order.medium,
                isLast: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOtherInfoRow(
    BuildContext context,
    bool isDark,
    String label,
    String value, {
    bool isLast = false,
  }) {
    final bool isNotSpecified =
        value.isEmpty ||
        value == "Not specified" ||
        value == "false" ||
        value == "null";

    final String displayValue = isNotSpecified ? "Not specified" : value;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Text(
                  displayValue,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: isNotSpecified
                        ? (isDark ? Colors.grey[500] : Colors.grey.shade400)
                        : (isDark ? Colors.white : Colors.black87),
                    fontStyle: isNotSpecified
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}

class OtherInfoHeading extends StatelessWidget {
  final String title;
  const OtherInfoHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 10),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          letterSpacing: 2,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[400] : Colors.grey.shade600,
        ),
      ),
    );
  }
}
