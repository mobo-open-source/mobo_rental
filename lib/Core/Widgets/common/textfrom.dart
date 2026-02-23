import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobo_rental/Core/utils/constants/colors.dart';

class TextFormForAuth extends StatelessWidget {
  final String hinttext;
  final TextEditingController textEditingController;
  final String? Function(String?) validator;
  const TextFormForAuth({
    super.key,
    required this.hinttext,
    required this.textEditingController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: textEditingController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: hinttext,
        hintStyle: GoogleFonts.montserrat(color: Colors.black.withAlpha(100)),
      ),
    );
  }
}

Widget CustomText({
  required String text,
  double? size,
  FontWeight? fontweight,
  Color? textcolor,
}) {
  return Text(
    text,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(fontSize: size, fontWeight: fontweight, color: textcolor),
  );
}

class AppName extends StatelessWidget {
  const AppName({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'mobo rental',
      style: TextStyle(
        fontFamily: 'YaroRg',
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.w400,
        fontSize: 30,
      ),
    );
  }
}

final TextStyle textStyle = GoogleFonts.montserrat(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: Colors.grey,
);


TextStyle floatingActionTextStyle = GoogleFonts.montserrat(
  fontSize: 14.0,
  color: Colors.black87,
);
Widget EmailContainer({
  required TextEditingController textEditingController,
  double? height,
  bool? obsecure,
  required String hinttext,
  Widget? icon,
  Widget? suffixicon,
  String? textvalue,
  required BuildContext context,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Theme.of(context).colorScheme.secondary,
    ),
    padding: EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      children: [
        if (icon != null) icon,
        if (icon != null) SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black),

            controller: textEditingController,
            obscureText: obsecure ?? false,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 10,
              ),
              hintText: hinttext,
              hintStyle: GoogleFonts.montserrat(
                color: Colors.black.withAlpha(100),
              ),
            ),
          ),
        ),
        if (suffixicon != null) suffixicon,
      ],
    ),
  );
}
