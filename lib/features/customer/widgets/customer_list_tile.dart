import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/Core/utils/constants/theme/app_theme.dart';

class CustomerListTile extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback? onTap;
  final Widget? popupMenu;
  final bool isDark;
  final Map<String, Uint8List>? imageCache;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onEmail;
  final VoidCallback? onLocation;

  const CustomerListTile({
    Key? key,
    required this.customer,
    this.onTap,
    this.popupMenu,
    required this.isDark,
    this.imageCache,
    this.onCall,
    this.onMessage,
    this.onEmail,
    this.onLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 12,
            top: 12,
            bottom: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name']?.toString() ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppTheme.primaryColor,
                            letterSpacing: -0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _hasValidPhone()
                                ? customer['phone']?.toString() ?? ''
                                : 'No phone number',
                            style: TextStyle(
                              fontSize: 12,
                              color: _hasValidPhone()
                                  ? (isDark
                                        ? Colors.grey[100]
                                        : const Color(0xff6D717F))
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[400]),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              fontStyle: _hasValidPhone()
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _hasValidAddress()
                                ? _getFormattedAddress()
                                : 'No address available',
                            style: TextStyle(
                              fontSize: 12,
                              color: _hasValidAddress()
                                  ? (isDark
                                        ? Colors.grey[100]
                                        : const Color(0xff6D717F))
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[400]),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              fontStyle: _hasValidAddress()
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildContactBadge(),
                      if (popupMenu != null) ...[
                        popupMenu!,
                      ] else ...[
                        _buildActionMenu(),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: isDark ? Colors.grey[800] : Colors.grey[100],

          child: _buildImageWidget(),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    final imageUrl = customer['image_128']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'false') {
      // Check if it's an HTTP URL
      if (imageUrl.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildAvatarFallback(),
        );
      } else {
        // Base64 image
        return _buildBase64Image();
      }
    }

    return _buildAvatarFallback();
  }

  Widget _buildBase64Image() {
    final imageUrl = customer['image_128']?.toString();
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildAvatarFallback();
    }

    if (imageUrl.toLowerCase() == 'false' || imageUrl.length < 24) {
      return _buildAvatarFallback();
    }

    if (imageCache?.containsKey(imageUrl) == true) {
      return Image.memory(
        imageCache![imageUrl]!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
      );
    }

    try {
      final base64String = imageUrl.contains(',')
          ? imageUrl.split(',').last
          : imageUrl;

      if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(base64String)) {
        return _buildAvatarFallback();
      }

      if (base64String.length < 4 ||
          (base64String.length % 4 != 0 &&
              base64String.length % 4 != 2 &&
              base64String.length % 4 != 3)) {
        return _buildAvatarFallback();
      }

      final bytes = base64Decode(base64String);

      if (imageCache != null) {
        imageCache![imageUrl] = bytes;
      }

      return Image.memory(
        bytes,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
      );
    } catch (e) {
      return _buildAvatarFallback();
    }
  }

  Widget _buildAvatarFallback() {
    final name = customer['name']?.toString() ?? '?';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty
              ? name.length >= 2
                    ? name.substring(0, 2).toUpperCase()
                    : name.substring(0, 1).toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContactBadge() {
    final isCompany =
        customer['is_company'] == true || customer['company_type'] == 'company';
    final badgeText = isCompany ? 'Company' : 'Customer';
    final badgeColor = isCompany ? Colors.blue : Colors.green;

    final textColor = isDark ? Colors.white : badgeColor;
    final backgroundColor = isDark
        ? Colors.white.withOpacity(0.15)
        : badgeColor.withOpacity(0.10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  bool _hasValidAddress() {
    return (customer['street'] != null &&
            customer['street'].toString().isNotEmpty &&
            customer['street'].toString() != 'false') ||
        (customer['street2'] != null &&
            customer['street2'].toString().isNotEmpty &&
            customer['street2'].toString() != 'false') ||
        (customer['city'] != null &&
            customer['city'].toString().isNotEmpty &&
            customer['city'].toString() != 'false') ||
        (customer['state'] != null &&
            customer['state'].toString().isNotEmpty &&
            customer['state'].toString() != 'false') ||
        (customer['zip'] != null &&
            customer['zip'].toString().isNotEmpty &&
            customer['zip'].toString() != 'false') ||
        (customer['country'] != null &&
            customer['country'].toString().isNotEmpty &&
            customer['country'].toString() != 'false');
  }

  bool _hasValidPhone() {
    final phone = customer['phone']?.toString();
    return phone != null && phone.isNotEmpty && phone != 'false';
  }

  bool _hasValidEmail() {
    final email = customer['email']?.toString();
    return email != null && email.isNotEmpty && email != 'false';
  }

  String _getFormattedAddress() {
    final addressParts = [
      if (customer['street'] != null &&
          customer['street'].toString().isNotEmpty &&
          customer['street'].toString() != 'false')
        customer['street'].toString(),
      if (customer['street2'] != null &&
          customer['street2'].toString().isNotEmpty &&
          customer['street2'].toString() != 'false')
        customer['street2'].toString(),
      if (customer['city'] != null &&
          customer['city'].toString().isNotEmpty &&
          customer['city'].toString() != 'false')
        customer['city'].toString(),
      if (customer['state'] != null &&
          customer['state'].toString().isNotEmpty &&
          customer['state'].toString() != 'false')
        customer['state'].toString(),
      if (customer['zip'] != null &&
          customer['zip'].toString().isNotEmpty &&
          customer['zip'].toString() != 'false')
        customer['zip'].toString(),
      if (customer['country'] != null &&
          customer['country'].toString().isNotEmpty &&
          customer['country'].toString() != 'false')
        customer['country'].toString(),
    ].where((part) => part.isNotEmpty && part != 'false').toList();

    return addressParts.join(', ');
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'call',
          enabled: _hasValidPhone(),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedCall,
                color: _hasValidPhone()
                    ? (isDark ? Colors.grey[300] : Colors.grey[800])
                    : Colors.grey[500],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Call Contact',
                style: TextStyle(
                  color: _hasValidPhone()
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'message',
          enabled: _hasValidPhone(),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedMessage01,
                color: _hasValidPhone()
                    ? (isDark ? Colors.grey[300] : Colors.grey[800])
                    : Colors.grey[500],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Send Message',
                style: TextStyle(
                  color: _hasValidPhone()
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'email',
          enabled: _hasValidEmail(),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedMail01,
                color: _hasValidEmail()
                    ? (isDark ? Colors.grey[300] : Colors.grey[800])
                    : Colors.grey[500],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Send Email',
                style: TextStyle(
                  color: _hasValidEmail()
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'location',
          child: Row(
            children: [
              HugeIcon(
                icon: _hasValidCoordinates()
                    ? HugeIcons.strokeRoundedLocation01
                    : HugeIcons.strokeRoundedLocation04,
                color: (isDark ? Colors.white : Colors.black87),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'View Location',
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'call':
            if (_hasValidPhone() && onCall != null) {
              onCall!();
            }
            break;
          case 'message':
            if (_hasValidPhone() && onMessage != null) {
              onMessage!();
            }
            break;
          case 'email':
            if (_hasValidEmail() && onEmail != null) {
              onEmail!();
            }
            break;
          case 'location':
            if (onLocation != null) {
              onLocation!();
            }
            break;
        }
      },

      child: SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: Icon(
            Icons.more_vert,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );
  }

  bool _hasValidCoordinates() {
    final lat = customer['partner_latitude'];
    final lng = customer['partner_longitude'];
    return lat != null && lng != null && lat != 0.0 && lng != 0.0;
  }
}
