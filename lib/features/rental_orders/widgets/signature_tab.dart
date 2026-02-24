import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mobo_rental/Core/Widgets/common/snack_bar.dart';
import 'package:mobo_rental/features/rental_orders/widgets/quoute_builder_widget.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';

class SignatureTab extends StatefulWidget {
  final int orderID;
  final String? existingSignedBy;
  final String? existingSignedOn;
  final String? signatureBytes;

  const SignatureTab({
    super.key,
    required this.orderID,
    this.existingSignedBy,
    this.existingSignedOn,
    this.signatureBytes,
  });

  @override
  State<SignatureTab> createState() => _SignatureTabState();
}

class _SignatureTabState extends State<SignatureTab> {
  late SignatureController _signatureController;
  final TextEditingController _signedByController = TextEditingController();
  DateTime? _signedOnDate;
  Uint8List? _capturedSignature;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    if (widget.existingSignedBy != null) {
      _signedByController.text = widget.existingSignedBy!;
    }

    if (widget.existingSignedOn != null) {
      try {
        _signedOnDate = DateTime.parse(widget.existingSignedOn!);
      } catch (_) {
      }
    }

    if (widget.signatureBytes != null && widget.signatureBytes!.isNotEmpty) {
      try {
        _capturedSignature = base64Decode(widget.signatureBytes!);
      } catch (_) {
        CustomSnackbar.showError(context, 'Failed to load Signature');
      }
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _signedByController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePickerPlatform.instance;
      final image = await picker.getImageFromSource(
        source: source,
        options: const ImagePickerOptions(
          imageQuality: 50,
        ), // Default args if needed
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _capturedSignature = bytes;
          _signatureController.clear();
        });
        if (mounted) {
          CustomSnackbar.showSuccess(context, 'Image uploaded successfully');
        }
      }
    } catch (_) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to pick image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Consumer<RentalOrderProvider>(
        builder: (context, value, child) => Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              quoteBuilderHeading(title: 'Signed By'),
              const SizedBox(height: 15),
              TextFormField(
                controller: _signedByController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  hintText: "Enter name of person signing",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefix: const SizedBox(width: 5),
                  filled: true,
                  fillColor: isDark ? Colors.grey[700] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),

              const SizedBox(height: 15),
              quoteBuilderHeading(title: 'Signed On'),
              const SizedBox(height: 15),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _signedOnDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate == null) return;

                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      _signedOnDate ?? DateTime.now(),
                    ),
                  );

                  if (pickedTime == null) return;

                  setState(() {
                    _signedOnDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : const Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Text(
                        _signedOnDate != null
                            ? DateFormat(
                                'MMM dd, yyyy hh:mm a',
                              ).format(_signedOnDate!)
                            : 'Select date and time',
                        style: TextStyle(
                          fontSize: 16,
                          color: _signedOnDate != null
                              ? (isDark ? Colors.white : Colors.black)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              quoteBuilderHeading(title: 'Signature'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 200,
                    color: Colors.white,
                    child: _capturedSignature != null
                        ? Image.memory(
                            _capturedSignature!,
                            fit: BoxFit.scaleDown,
                          )
                        : Signature(
                            controller: _signatureController,
                            backgroundColor: Colors.transparent,
                          ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(
                      Icons.upload_file_outlined,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    label: const Text('Upload'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(
                      color: Colors.grey,
                      thickness: 1,
                      width: 8,
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () async {
                      if (_signatureController.isEmpty) {
                        CustomSnackbar.showError(
                          context,
                          'Please draw signature first!',
                        );
                        return;
                      }
                      final data = await _signatureController.toPngBytes();
                      setState(() {
                        _capturedSignature = data;
                      });
                      if (context.mounted) {
                        CustomSnackbar.showSuccess(
                          context,
                          'Signature captured successfully',
                        );
                      }
                    },
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    label: const Text("Capture"),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(
                      color: Colors.grey,
                      thickness: 1,
                      width: 8,
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () {
                      _signatureController.clear();
                      setState(() {
                        _capturedSignature = null;
                      });
                      CustomSnackbar.showSuccess(context, 'Signature cleared');
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: const Text("Clear"),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_signedByController.text.isEmpty) {
                      CustomSnackbar.showError(
                        context,
                        'Please enter who signed the document!',
                      );
                      return;
                    }

                    if (_capturedSignature == null) {
                      if (_signatureController.isNotEmpty) {
                        final data = await _signatureController.toPngBytes();
                        setState(() {
                          _capturedSignature = data;
                        });
                      } else {
                        CustomSnackbar.showError(
                          context,
                          'Please provide a signature',
                        );
                        return;
                      }
                    }

                    if (_capturedSignature != null && context.mounted) {
                      await value.saveSignature(
                        context,
                        widget.orderID,
                        _capturedSignature!,
                        _signedByController.text,
                        _signedOnDate!,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: value.savingSignature
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: value.savingSignature
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.grey),
                            SizedBox(width: 5),
                            const Text(
                              "Saving",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 5),
                            const Text(
                              "Save Signature",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
