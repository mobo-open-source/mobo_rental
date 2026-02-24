import 'package:flutter/material.dart';
import 'package:mobo_rental/features/customer/model/contact_model.dart';
import '../../../Core/const/app_colors.dart' as AppTheme;

import 'dart:convert';
import 'dart:typed_data';

class CustomerSelector extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isDark;
  final bool showBorder;
  final Contact? selectedCustomer;
  final bool isSearching;
  final bool showDropdown;
  final List<Contact> customers;
  final VoidCallback? onClearCustomer;
  final VoidCallback? onToggleDropdown;
  final ValueChanged<String>? onChanged;
  final ValueChanged<Contact>? onCustomerSelected;
  final String? Function(String?)? validator;

  const CustomerSelector({
    required this.controller,
    required this.labelText,
    required this.isDark,
    required this.selectedCustomer,
    required this.isSearching,
    required this.showDropdown,
    required this.customers,
    this.hintText,
    this.showBorder = false,
    this.onClearCustomer,
    this.onToggleDropdown,
    this.onChanged,
    this.onCustomerSelected,
    this.validator,
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
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white70 : const Color(0xff7F7F7F),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            TextFormField(
              controller: controller,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xff000000),
              ),
              decoration: InputDecoration(
                hintText: hintText ?? 'Type to search customers...',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: showBorder ? _getBorderColor() : Colors.transparent,
                    width: showBorder ? 2 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: showBorder ? _getBorderColor() : Colors.transparent,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 1,
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xffF8FAFB),
                prefixIcon: Icon(
                  Icons.person,
                  color: isDark ? Colors.white70 : Color(0xff7F7F7F),
                ),
                suffixIcon: _buildSuffixIcon(),
              ),
              onChanged: onChanged,
              validator: validator,
            ),
            if (showDropdown && customers.isNotEmpty) _buildDropdown(),
          ],
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (selectedCustomer != null) {
      return IconButton(
        icon: Icon(
          Icons.cancel,
          color: isDark ? Colors.white70 : const Color(0xff7F7F7F),
        ),
        onPressed: onClearCustomer,
      );
    }

    if (isSearching) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        showDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        color: isDark ? Colors.white70 : const Color(0xff7F7F7F),
      ),
      onPressed: onToggleDropdown,
    );
  }

  Widget _buildDropdown() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return ListTile(
            dense: true,
            leading: _buildAvatar(customer),
            title: Text(
              customer.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            subtitle: _hasValidEmail(customer.email)
                ? Text(
                    customer.email!,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  )
                : null,
            onTap: () => onCustomerSelected?.call(customer),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(Contact contact) {
    if (contact.imageUrl != null && contact.imageUrl!.isNotEmpty) {
      try {
        final bytes = _safeBase64Decode(contact.imageUrl!);
        if (bytes != null) {
          return CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
            backgroundImage: MemoryImage(bytes),
            onBackgroundImageError: (_, __) {},
          );
        }
      } catch (e) {
        // Fall through to default avatar
      }
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
      child: Text(
        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Uint8List? _safeBase64Decode(String raw) {
    try {
      var data = raw.contains(',') ? raw.split(',').last : raw;
      data = data.replaceAll(RegExp(r"\s+"), '');
      final rem = data.length % 4;
      if (rem != 0) {
        data = data.padRight(data.length + (4 - rem), '=');
      }
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  Color _getBorderColor() {
    return isDark ? Colors.grey[700]! : Colors.grey[400]!;
  }

  bool _hasValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    if (email.toLowerCase() == 'false') return false;
    return true;
  }
}
