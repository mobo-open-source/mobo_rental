import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:shimmer/shimmer.dart';

class GreetingContainer extends StatelessWidget {
  final UserProvider userProvider;
  final bool? isLoading;

  const GreetingContainer({
    super.key,
    required this.userProvider,
    this.isLoading,
  });
  @override
  Widget build(BuildContext context) {
    final hasImage =
        userProvider.userImage != null && userProvider.userImage!.isNotEmpty;

    if (isLoading == true) {
      return Container(
        margin: EdgeInsets.only(bottom: 20),

        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.black45.withAlpha(50),
                    highlightColor: Colors.white54.withAlpha(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 28,
                      width: 150,
                    ),
                  ),
                  SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.black45.withAlpha(50),
                    highlightColor: Colors.white54.withAlpha(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 18,
                      width: 200,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Shimmer.fromColors(
              baseColor: Colors.black45.withAlpha(50),
              highlightColor: Colors.white54.withAlpha(50),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(30),
                ),
                height: 60,
                width: 60,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: Theme.of(context).primaryColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${userProvider.getGreeting()} ${userProvider.userName ?? 'Unknown'}!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Manage Your Rental Operation \nEfficiently",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
              image: hasImage
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(userProvider.userImage!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

Widget analyticCardWidget({
  required String title,
  required String amount,
  required bool dollar,
  required String sub,
  required Color color,
  bool? isLoading,
  required bool isdark,
}) {
  if (isLoading == true) {
    final Color baseColor = isdark ? Colors.grey[850]! : Colors.grey.shade300;
    final Color highlightColor = isdark
        ? Colors.grey[600]!
        : Colors.grey.shade100;
    final Color blockColor = isdark ? Colors.grey[800]! : Colors.white;

    return Padding(
      padding: EdgeInsets.only(right: 8, top: 10, bottom: 10, left: 3),
      child: Container(
        width: 280,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isdark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isdark
              ? []
              : [
                  BoxShadow(
                    offset: Offset(-2, 2),
                    color: Colors.grey.shade200,
                    blurRadius: 3,
                    spreadRadius: 3,
                  ),
                ],
        ),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(height: 14, width: 150, color: blockColor),
              SizedBox(height: 8),
              Container(height: 25, width: 120, color: blockColor),
              SizedBox(height: 8),
              Container(height: 12, width: 120, color: blockColor),
              SizedBox(height: 8),
              Container(height: 3, width: 60, color: blockColor),
            ],
          ),
        ),
      ),
    );
  }

  return Padding(
    padding: EdgeInsets.only(right: 8, top: 10, bottom: 10, left: 3),
    child: Container(
      width: 280,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isdark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isdark
            ? []
            : [
                BoxShadow(
                  offset: Offset(-2, 2),
                  color: Colors.grey.shade200,
                  blurRadius: 3,
                  spreadRadius: 3,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isdark ? Colors.grey[400] : Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              Text(
                '≈',
                style: TextStyle(
                  color: isdark ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              Flexible(
                child: Text(
                  ' $amount',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: isdark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: isdark ? Colors.grey[500] : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    ),
  );
}
