import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:provider/provider.dart';

class quoteBuilderHeading extends StatelessWidget {
  final String title;
  const quoteBuilderHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

class quoteBuilderContainer extends StatefulWidget {
  const quoteBuilderContainer({
    super.key,
    required this.order,
    required this.height,
  });

  final RentalOrderItem order;
  final double height;

  @override
  State<quoteBuilderContainer> createState() => _quoteBuilderContainerState();
}

class _quoteBuilderContainerState extends State<quoteBuilderContainer> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<RentalOrderProvider>(
      builder: (context, provider, child) {
        final quoteData = provider.quoteBuilderData;
        final headers = quoteData?.headers ?? [];
        final footers = quoteData?.footers ?? [];
        final lines = quoteData?.lines ?? [];

        final activeBorderColor = Theme.of(context).colorScheme.primary;
        final activeBgColor = Theme.of(
          context,
        ).colorScheme.primary.withAlpha(30);
        final activeIconColor = Theme.of(context).colorScheme.primary;

        final inactiveBorderColor = isDark ? Colors.grey[700]! : Colors.grey;
        final inactiveBgColor = isDark ? Colors.grey[850]! : Colors.white;
        final inactiveIconColor = isDark ? Colors.grey[400]! : Colors.grey;

        if (widget.order.isQuoteAvailable != true) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedFile02,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: widget.height * 0.01),
                Center(
                  child: Text(
                    "Quote Builder",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                SizedBox(height: widget.height * 0.01),
                Center(
                  child: Text(
                    "This feature is only available in Odoo 18 or 19",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quote Builder',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: provider.savingQuote
                            ? null
                            : () async {
                                if (isEditing) {
                                  await provider.saveAllQuoteBuilderChanges(
                                    context,
                                    widget.order.id,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      isEditing = false;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    isEditing = true;
                                  });
                                }
                              },
                        icon: provider.savingQuote
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : Icon(
                                isEditing ? Icons.save : Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                    ],
                  ),

                  SizedBox(height: widget.height * 0.02),
                  quoteBuilderHeading(title: 'Headers'),
                  SizedBox(height: widget.height * 0.01),

                  if (headers.isNotEmpty)
                    ...headers.map((doc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: isEditing
                              ? () {
                                  provider.toggleDocumentSelection(
                                    doc.id,
                                    true,
                                  );
                                }
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 18,
                            ),
                            decoration: BoxDecoration(
                              color: doc.isSelected
                                  ? activeBgColor
                                  : inactiveBgColor,
                              border: Border.all(
                                color: doc.isSelected
                                    ? activeBorderColor
                                    : inactiveBorderColor,
                                width: doc.isSelected ? 1.5 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  doc.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: doc.isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: doc.isSelected
                                        ? activeBorderColor
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black),
                                  ),
                                ),
                                doc.isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: activeIconColor,
                                      )
                                    : HugeIcon(
                                        icon: HugeIcons.strokeRoundedAddCircle,
                                        color: inactiveIconColor,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  else
                    NoDocumentState(),

                  SizedBox(height: widget.height * 0.02),
                  quoteBuilderHeading(title: 'Footers'),
                  SizedBox(height: widget.height * 0.01),

                  if (footers.isNotEmpty)
                    ...footers.map((doc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: isEditing
                              ? () {
                                  provider.toggleDocumentSelection(
                                    doc.id,
                                    false,
                                  );
                                }
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 18,
                            ),
                            decoration: BoxDecoration(
                              color: doc.isSelected
                                  ? activeBgColor
                                  : inactiveBgColor,
                              border: Border.all(
                                color: doc.isSelected
                                    ? activeBorderColor
                                    : inactiveBorderColor,
                                width: doc.isSelected ? 1.5 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  doc.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: doc.isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: doc.isSelected
                                        ? activeBorderColor
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black),
                                  ),
                                ),
                                doc.isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: activeIconColor,
                                      )
                                    : HugeIcon(
                                        icon: HugeIcons.strokeRoundedAddCircle,
                                        color: inactiveIconColor,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                  else
                    NoDocumentState(),

                  SizedBox(height: widget.height * 0.02),
                  quoteBuilderHeading(title: 'Product Document'),
                  SizedBox(height: widget.height * 0.01),

                  if (lines.isNotEmpty)
                    ...lines.map((line) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...line.files.map(
                            (file) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: isEditing
                                    ? () =>
                                          provider.toggleLineDocumentSelection(
                                            line.lineId,
                                            file.id,
                                          )
                                    : null,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: file.isSelected
                                        ? activeBgColor
                                        : inactiveBgColor,
                                    border: Border.all(
                                      color: file.isSelected
                                          ? activeBorderColor
                                          : inactiveBorderColor,
                                      width: file.isSelected ? 1.5 : 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          file.name,
                                          style: TextStyle(
                                            color: file.isSelected
                                                ? activeBorderColor
                                                : (isDark
                                                      ? Colors.white
                                                      : Colors.black),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        file.isSelected
                                            ? Icons.check_circle
                                            : Icons.add_circle_outline,
                                        color: file.isSelected
                                            ? activeIconColor
                                            : inactiveIconColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList()
                  else
                    NoDocumentState(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NoDocumentState extends StatelessWidget {
  const NoDocumentState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey),
        color: isDark ? Colors.grey[850] : Colors.grey.shade300,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.folder_open, color: Colors.grey, size: 45),
            Text(
              'No document Available',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
