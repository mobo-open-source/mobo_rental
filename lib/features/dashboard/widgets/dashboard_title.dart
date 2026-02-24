import 'package:flutter/material.dart';

class DashbordTitle extends StatelessWidget {
  final bool isdark;
  final String dashboard;
  const DashbordTitle({
    super.key,
    required this.dashboard,
    required this.isdark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Text(
        dashboard,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: isdark
              ? Theme.of(context).colorScheme.secondary
              : Colors.black,
        ),
      ),
    );
  }
}
