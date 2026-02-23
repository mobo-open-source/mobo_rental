import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final String labelText;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final bool isDark;
  final List<DropdownMenuItem<String>> items;

  const CustomDropdownField({
    required this.value,
    required this.labelText,
    required this.onChanged,
    this.validator,
    required this.items,
    this.hintText,
    this.isDark = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xff7F7F7F),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: hintText != null
              ? Text(
                  hintText!,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xffF8FAFB),
          ),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xff000000),
          ),
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
