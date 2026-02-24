import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_rental/Core/Widgets/common/alert_dialog.dart';
import 'package:mobo_rental/Core/Widgets/common/icons.dart';
import 'package:mobo_rental/Core/Widgets/common/loading_dialog.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/rental_orders/screens/create_rental_order.dart';
import 'package:mobo_rental/features/rental_orders/service/pdf_service_custom.dart';
import 'package:mobo_rental/features/rental_orders/widgets/orde_line.dart';
import 'package:mobo_rental/features/rental_orders/widgets/other_info.dart';
import 'package:mobo_rental/features/rental_orders/widgets/quoute_builder_widget.dart';
import 'package:mobo_rental/features/rental_orders/widgets/signature_tab.dart';
import 'package:mobo_rental/features/rental_orders/widgets/smart_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ViewRentalOrder extends StatefulWidget {
  final int orderID;
  final String states;
  const ViewRentalOrder({
    super.key,
    required this.orderID,
    required this.states,
  });

  @override
  State<ViewRentalOrder> createState() => _ViewRentalOrderState();
}

class _ViewRentalOrderState extends State<ViewRentalOrder>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final provider = Provider.of<RentalOrderProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchOrderById(context, widget.orderID);
    });
  }

  Future<void> _refreshOrder() async {
    await context.read<RentalOrderProvider>().fetchOrderById(
      context,
      widget.orderID,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;

    return Consumer<RentalOrderProvider >(
      builder: (context, provider,  _) {
        if (provider.isViewOrderLoading) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Rental Order'),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Shimmer.fromColors(
                  baseColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[300]!,
                  highlightColor: isDark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerCard(height: 180, isDark: isDark),
                      const SizedBox(height: 20),
                      _buildShimmerCard(height: 180, isDark: isDark),
                      const SizedBox(height: 20),
                      _buildShimmerCard(height: 300, isDark: isDark),
                      const SizedBox(height: 20),
                      _buildShimmerCard(height: 180, isDark: isDark),
                    ],
                  ),
                ),
              ),
            ),
            bottomSheet: const SizedBox(),
          );
        }

        if (provider.selectedOrder == null) {
          return const Scaffold(body: Center(child: Text('Order not found')));
        }

        final order = provider.selectedOrder!;
        double totalTax = 0.0;
        for (var line in provider.fetchOrderline) {
          totalTax += line.taxAmount;
        }

        double totalAmount = order.amount;
        double untaxedAmount = totalAmount - totalTax;

        final orderDate = DateFormat(
          'MMM dd,yyyy',
        ).format(order.orderDate as DateTime);

        final String orderLength = provider.fetchOrderline.length.toString();

        return Scaffold(
          backgroundColor: isDark
              ? Colors.grey[900]
              : Theme.of(context).colorScheme.secondary,
          appBar: CustomAppBar(
            backgroundColor: isDark
                ? Colors.grey[900]
                : Theme.of(context).colorScheme.secondary,
            title: 'Rental Order',
            actions: [
              provider.selectedOrder!.deliveryCount == 0
                  ? const SizedBox.shrink()
                  : Badge(
                      offset: const Offset(-5, 5),
                      label: Text(
                        provider.selectedOrder!.deliveryCount.toString(),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedContainerTruck01,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
              provider.selectedOrder!.invoiceCount == 0
                  ? const SizedBox.shrink()
                  : Badge(
                      offset: const Offset(-5, 5),
                      label: Text(
                        provider.selectedOrder!.invoiceCount.toString(),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedInvoice03,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
              IconButton(
                onPressed: () {
                  final createProvider = context.read<CreateRentalProvider>();
                  final viewProvider = context.read<RentalOrderProvider>();

                  createProvider.loadFromExistingOrder(
                    context: context,
                    order: viewProvider.selectedOrder!,
                    orderLines: viewProvider.fetchOrderline,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateRentalOrder(),
                    ),
                  );
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedPencilEdit02,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SmartButton(
                  isRental: true,
                  state: order.status,
                  onSelected: (action) {
                    switch (action) {
                      case RentalSmartAction.confirmOrder:
                        provider.confirmOrder(context, order.id);
                        break;
                      case RentalSmartAction.returnOrder:
                        provider.nextStageOnOrder(
                          context,
                          order.id,
                          order.status,
                        );
                        break;
                      case RentalSmartAction.cancelOrder:
                        provider.cancelOrder(context, order.id);
                        break;
                      case RentalSmartAction.convertToRental:
                        provider.convertToRental(context, order.id);
                        break;
                      case RentalSmartAction.downloadQuotation:
                        provider.downloadQuotationWithDialog(context, order.id);
                        break;

                      case RentalSmartAction.deleteOrder:
                        provider.confirmDeleteOrder(
                          context,
                          order.id,
                          provider,
                        );
                        break;
                      case RentalSmartAction.sendByEmail:
                        provider.sendRentalOrderByEmail(context, order.id);
                        break;
                      case RentalSmartAction.shareViaWhatsapp:
                        provider.shareRentalOrderViaWhatsapp(context, order.id);
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: RefreshIndicator(
              onRefresh: _refreshOrder,

              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Card Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  offset: const Offset(0, 2),
                                  blurRadius: 10,
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.code,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      order.status.toLowerCase() == 'returned'
                                      ? (isDark
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!)
                                      : statusColor(order.status).withAlpha(40),
                                  borderRadius: BorderRadius.circular(16),
                                ),

                                child: Text(
                                  state(order.status),
                                  style: TextStyle(
                                    color: statusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            order.customer,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (order.street.isNotEmpty) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${[order.street, if (order.street2.isNotEmpty) order.street2, order.city, order.state].where((s) => s.isNotEmpty).join(', ')},",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                                if (order.zip.isNotEmpty)
                                  Text(
                                    order.zip,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                if (order.country.isNotEmpty)
                                  Text(
                                    order.country,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 5),
                          Text(
                            'Payment Terms: ${order.paymentTerm ?? 'Immediate'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[300] : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            orderDate,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.blue[300]
                                  : Colors.blueAccent,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTabItem(
                                "Order Lines $orderLength",
                                0,
                                isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildTabItem("Quote Builder", 1, isDark),
                              const SizedBox(width: 8),
                              _buildTabItem("Other Info", 2, isDark),
                              const SizedBox(width: 8),
                              _buildTabItem("Signature", 3, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          constraints: BoxConstraints(maxHeight: height * 0.34),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(30),
                                      offset: const Offset(1, 2),
                                      blurRadius: 10,
                                    ),
                                  ],
                          ),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(
                                child: OrderLineTable(
                                  orderItems: provider.fetchOrderline,
                                ),
                              ),
                              quoteBuilderContainer(
                                order: order,
                                height: height,
                              ),
                              OtherInfoView(height: height, order: order),
                              SignatureTab(
                                orderID: widget.orderID,
                                existingSignedBy: order.signedBy,
                                existingSignedOn: order.signedOn,
                                signatureBytes: order.signatureBytes,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomSheet: provider.isViewOrderLoading
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : const Color(0xFFFCE4EC),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        offset: const Offset(0, -2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Untaxed Amount",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  "\$ ${untaxedAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tax",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  "\$ ${totalTax.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        color: Theme.of(context).colorScheme.primary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$ ${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTabItem(String text, int index, bool isDark) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isCurrentlySelected = _tabController.index == index;

        return GestureDetector(
          onTap: () {
            _tabController.animateTo(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrentlySelected
                  ? (isDark ? Colors.grey[850] : Colors.black)
                  : (isDark ? Colors.transparent : Colors.white),

              border: Border.all(
                color: isCurrentlySelected
                    ? (isDark ? Colors.grey[850]! : Colors.black)
                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isCurrentlySelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
                fontSize: 14,
                fontWeight: isCurrentlySelected
                    ? FontWeight.bold
                    : FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCard({required double height, required bool isDark}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  String state(String state) {
    switch (state.toLowerCase()) {
      case "pickup":
        return 'Reserved';
      case "return":
        return 'Pickedup';
      case "cancel":
        return 'Cancelled';
      case "draft":
        return 'Quotation';
      case "sale":
        return 'Sale Order';
      case "returned":
        return 'Returned';
      default:
        return '';
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "sale":
        return const Color.fromARGB(255, 175, 120, 76);
      case "pickup":
        return const Color.fromARGB(255, 91, 156, 7);
      case "cancel":
        return const Color.fromARGB(255, 185, 185, 185);
      case "return":
        return const Color.fromARGB(255, 245, 166, 35);
      case "draft":
        return const Color.fromARGB(255, 55, 158, 226);
      case "returned":
        return const Color.fromARGB(255, 168, 4, 4);
      default:
        return Colors.white;
    }
  }
}
