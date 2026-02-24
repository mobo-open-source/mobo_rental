import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/features/rental_orders/screens/create_rental_order.dart';
import 'package:mobo_rental/Core/utils/constants/colors.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:provider/provider.dart';

class floatingActionText extends StatelessWidget {
  final String title;
  const floatingActionText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withAlpha(150),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomText(text: title),
      ),
    );
  }
}

Widget ordersFab(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return SpeedDial(
    activeChild: HugeIcon(
      icon: HugeIcons.strokeRoundedCancel01,
      color: isDark ? Colors.black : Colors.white,
    ),
    onOpen: () {
      Provider.of<CreateRentalProvider>(
        context,
        listen: false,
      ).restEdittoCreate();
      Provider.of<CreateRentalProvider>(
        context,
        listen: false,
      ).clearRentalQutationStates();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreateRentalOrder()),
      );
    },
    backgroundColor: isDark ? Colors.white : Theme.of(context).primaryColor,
    foregroundColor: isDark ? Colors.black : Colors.white,
    activeBackgroundColor: isDark
        ? Colors.white
        : Theme.of(context).primaryColor,
    activeForegroundColor: isDark ? Colors.black : Colors.white,
    overlayColor: Colors.black,
    overlayOpacity: 0.12,
    elevation: 8.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    direction: SpeedDialDirection.up,
    spacing: 12,
    spaceBetweenChildren: 12,
    child: HugeIcon(
      icon: HugeIcons.strokeRoundedFileAdd,
      color: isDark ? Colors.black : Colors.white,
    ),
  );
}
