import 'package:flutter/material.dart';
import 'package:mobo_rental/features/rental_orders/models/fetched_order_line_model.dart';

class OrderLineTable extends StatelessWidget {
  final List<FetchedOrderLineModel> orderItems;

  const OrderLineTable({super.key, required this.orderItems});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
        ),
      ),
      constraints: BoxConstraints(maxHeight: height * 0.4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: orderItems.isEmpty
            ? Center(
                child: Text(
                  'No order lines found',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey[400] : Colors.black,
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Scrollbar(
                  thickness: 4,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 60,
                      horizontalMargin: 20,
                      headingRowHeight: 50,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      headingRowColor: WidgetStateProperty.all(
                        isDark ? Colors.grey[800] : Colors.grey.shade50,
                      ),
                      dividerThickness: 1,
                      columns: [
                        DataColumn(
                          label: Text(
                            'Product',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Unit Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Tax',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                      rows: List<DataRow>.generate(orderItems.length, (index) {
                        final item = orderItems[index];
                        final itemNumber = index + 1;
                        String taxDisplay = " -";
                        if (item.taxes.isNotEmpty) {
                          taxDisplay = item.taxes.map((t) => t.name).join(', ');
                        }
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  Text(
                                    '${itemNumber.toString()}. ',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    item.productName,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "\$${item.priceUnit.toString()}",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                taxDisplay,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.black,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "\$${item.priceTotal.toString()}",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
