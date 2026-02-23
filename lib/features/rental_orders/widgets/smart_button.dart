import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum RentalSmartAction {
  confirmOrder,
  returnOrder,
  cancelOrder,
  convertToRental,
  downloadQuotation,
  deleteOrder,
  sendByEmail,
  shareViaWhatsapp,
}

class SmartButton extends StatelessWidget {
  final String state;
  final bool isRental;
  final void Function(RentalSmartAction action) onSelected;

  const SmartButton({
    super.key,
    required this.state,
    required this.isRental,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = <PopupMenuEntry<RentalSmartAction>>[];

    // 1. QUOTATION (Draft)
    if (state == 'draft') {
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.confirmOrder,
          HugeIcons.strokeRoundedRecycle03,
          'Confirm Order',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.cancelOrder,
          HugeIcons.strokeRoundedCancel01,
          'Cancel Quotation',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.deleteOrder,
          HugeIcons.strokeRoundedDelete02,
          'Delete',
          isDeletable: true,
        ),
      );

      // Common actions
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.downloadQuotation,
          HugeIcons.strokeRoundedFileDownload,
          'Print Quotation',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.sendByEmail,
          HugeIcons.strokeRoundedShare01,
          'Send by Email',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.shareViaWhatsapp,
          HugeIcons.strokeRoundedWhatsapp,
          'Share via WhatsApp',
        ),
      );
    } else if (isRental && (state == 'sale' || state == 'pickup')) {
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.returnOrder,
          HugeIcons.strokeRoundedContainerTruck01,
          'Pickup',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.cancelOrder,
          HugeIcons.strokeRoundedCancel01,
          'Cancel Order',
        ),
      );

      // Common actions
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.downloadQuotation,
          HugeIcons.strokeRoundedFileDownload,
          'Print Order',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.sendByEmail,
          HugeIcons.strokeRoundedShare01,
          'Send by Email',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.shareViaWhatsapp,
          HugeIcons.strokeRoundedWhatsapp,
          'Share via WhatsApp',
        ),
      );
    } else if (state == 'return') {
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.returnOrder,
          HugeIcons.strokeRoundedReturnRequest,
          'Return Items',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.cancelOrder,
          HugeIcons.strokeRoundedCancel01,
          'Cancel Order',
        ),
      );

      // Common actions
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.downloadQuotation,
          HugeIcons.strokeRoundedFileDownload,
          'Print Order',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.sendByEmail,
          HugeIcons.strokeRoundedShare01,
          'Send by Email',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.shareViaWhatsapp,
          HugeIcons.strokeRoundedWhatsapp,
          'Share via WhatsApp',
        ),
      );
    }
    // 4. RETURNED
    else if (state == 'returned') {
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.cancelOrder,
          HugeIcons.strokeRoundedCancel01,
          'Cancel Order',
        ),
      );

      // Common actions
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.downloadQuotation,
          HugeIcons.strokeRoundedFileDownload,
          'Print Order',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.sendByEmail,
          HugeIcons.strokeRoundedShare01,
          'Send by Email',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.shareViaWhatsapp,
          HugeIcons.strokeRoundedWhatsapp,
          'Share via WhatsApp',
        ),
      );
    }
    // 5. CANCELLED
    else if (state == 'cancel') {
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.deleteOrder,
          HugeIcons.strokeRoundedDelete02,
          'Delete Order',
          isDeletable: true,
        ),
      );

      // Common actions
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.downloadQuotation,
          HugeIcons.strokeRoundedFileDownload,
          'Print Order',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.sendByEmail,
          HugeIcons.strokeRoundedShare01,
          'Send by Email',
        ),
      );
      items.add(
        _item(
          context,
          isDark,
          RentalSmartAction.shareViaWhatsapp,
          HugeIcons.strokeRoundedWhatsapp,
          'Share via WhatsApp',
        ),
      );
    }

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    return PopupMenuButton<RentalSmartAction>(
      constraints: BoxConstraints(maxWidth: width * 0.6),
      onSelected: onSelected,
      color: isDark
          ? Colors.grey[900]
          : Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => items,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark
              ? Colors.grey[900]
              : Theme.of(context).colorScheme.secondary,
        ),
        child: Icon(
          Icons.more_vert,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  PopupMenuItem<RentalSmartAction> _item(
    BuildContext context,
    bool isDark,
    RentalSmartAction value,
    List<List<dynamic>> icon,
    String label, {
    bool isDeletable = false,
  }) {
    final Color textColor = isDeletable
        ? Colors.red
        : (isDark ? Colors.white : Colors.black);

    return PopupMenuItem<RentalSmartAction>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: isDeletable ? Colors.red : textColor),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(fontSize: 15, color: textColor)),
        ],
      ),
    );
  }
}
