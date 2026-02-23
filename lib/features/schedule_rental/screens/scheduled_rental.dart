import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobo_rental/Core/Widgets/common/text_styles.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/products/widgets/permission_error_view.dart';
import 'package:mobo_rental/features/schedule_rental/model/renatl_shcedule_model.dart';
import 'package:mobo_rental/features/schedule_rental/provider/rental_schedule_provider.dart';
import 'package:mobo_rental/features/schedule_rental/widgets/shimmer.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/empty_state.dart';

class ScheduledRental extends StatefulWidget {
  const ScheduledRental({super.key});

  @override
  State<ScheduledRental> createState() => _ScheduledRentalState();
}

class _ScheduledRentalState extends State<ScheduledRental> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RentalScheduleProvider>();
      if (provider.items.isEmpty) {
        provider.fetchRentalSchedule(context);
      }
    });
  }

  Future<void> _refreshSchedule() async {
    await context.read<RentalScheduleProvider>().fetchRentalSchedule(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;

    return Scaffold(
      body: Consumer<RentalScheduleProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            final errorTitle =
                provider.error!.toLowerCase().contains('permission')
                ? 'Access Error'
                : 'Something went wrong';

            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchRentalSchedule(context);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  EmptyState(
                    title: errorTitle,
                    subtitle:
                    'Server side is not responding please check',
                    lottieAsset: 'assets/lotties/Error 404.json',
                    onAction: () async {
                      await provider.fetchRentalSchedule(context);
                    },
                    actionLabel: 'Retry',
                  ),
                ],
              ),
            );
          }
          final grouped = provider.groupedByProduct.entries.toList();
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark
                      ? Colors.grey[850]
                      : Theme.of(context).colorScheme.secondary,
                ),
                child: _monthHeader(context, provider, isDark),
              ),
              if (provider.loading)
                SheduledRentalShimmer(isdark: isDark)
              else if (grouped.isEmpty)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshSchedule,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCalendar02,
                                  size: 60,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No schedules for this month",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshSchedule,
                    child: Container(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: grouped.length,
                        itemBuilder: (context, index) {
                          final entry = grouped[index];

                          String productName = entry.key;
                          if (entry.key.contains('|')) {
                            final parts = entry.key.split('|');
                            if (parts.length > 1) {
                              productName = parts[1];
                            }
                          }
                          productName = productName.replaceAll(
                            RegExp(r'\s*\([^)]*\)$'),
                            '',
                          );

                          final imageBase64 =
                              entry.value.first.productImageBase64;

                          return Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[850] : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          offset: const Offset(0, 3),
                                          blurRadius: 8,
                                          color: Colors.black.withAlpha(25),
                                        ),
                                      ],
                              ),
                              child: ExpansionTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageBase64 != null
                                      ? Image.memory(
                                          base64Decode(imageBase64),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 40,
                                          height: 40,
                                          color: isDark
                                              ? Colors.grey[700]
                                              : Colors.grey.shade300,
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 22,
                                            color: isDark
                                                ? Colors.grey[300]
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                ),
                                backgroundColor: Colors.transparent,
                                collapsedBackgroundColor: Colors.transparent,
                                title: Text(
                                  productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  '${entry.value.length} Item${entry.value.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                childrenPadding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                children: entry.value
                                    .map((item) => _rentalTile(item, isDark))
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _monthHeader(
    BuildContext context,
    RentalScheduleProvider provider,
    bool isdark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        boxShadow: isdark
            ? [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                  spreadRadius: 1,
                  color: Colors.black.withAlpha(120),
                ),
              ]
            : [
                BoxShadow(
                  offset: const Offset(1, 2),
                  blurRadius: 5,
                  spreadRadius: 5,
                  color: Colors.grey.shade200,
                ),
              ],
        borderRadius: BorderRadius.circular(10),
        color: isdark
            ? Colors.grey[850]
            : Theme.of(context).colorScheme.secondary,
        border: Border(
          bottom: BorderSide(
            color: isdark ? Colors.grey[800]! : Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: isdark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              provider.changeMonth(
                DateTime(
                  provider.selectedMonth.year,
                  provider.selectedMonth.month - 1,
                ),
                context,
              );
            },
          ),
          Text(
            DateFormat.yMMMM().format(provider.selectedMonth),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isdark ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isdark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              provider.changeMonth(
                DateTime(
                  provider.selectedMonth.year,
                  provider.selectedMonth.month + 1,
                ),
                context,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _rentalTile(RentalScheduleItem item, bool isdark) {
    Color bg;
    Color textColor;

    switch (item.status) {
      case RentalScheduleStatus.warning:
        bg = isdark
            ? Colors.orange.shade900.withAlpha(40)
            : Colors.orange.shade50;
        textColor = isdark ? Colors.orange.shade300 : Colors.orange.shade900;
        break;
      case RentalScheduleStatus.info:
        bg = isdark
            ? Colors.green.shade900.withAlpha(40)
            : Colors.green.shade50;
        textColor = isdark ? Colors.green.shade300 : Colors.green.shade900;
        break;
      case RentalScheduleStatus.normal:
        bg = isdark ? Colors.blue.shade900.withAlpha(40) : Colors.blue.shade50;
        textColor = isdark ? Colors.blue.shade300 : Colors.blue.shade900;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isdark ? Colors.grey[700]! : Colors.grey.withAlpha(100),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.customerName}, ${item.orderName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: textColor.withAlpha(190),
              ),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('MMM dd').format(item.startDate)} - ${DateFormat('MMM dd, yyyy').format(item.endDate)}',
                style: TextStyle(fontSize: 13, color: textColor.withAlpha(190)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
