import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mobo_rental/Core/services/connectivity_service.dart';
import 'package:mobo_rental/Core/services/session_service.dart';
import 'package:mobo_rental/shared/widgets/connection_status_widget.dart';
import 'package:mobo_rental/shared/widgets/forms/custom_dropdown_field.dart';
import 'package:mobo_rental/shared/widgets/forms/custom_text_field.dart';
import 'package:mobo_rental/shared/widgets/snackbars/custom_snackbar.dart';
import 'package:mobo_rental/features/customer/model/customer.dart';
import 'package:mobo_rental/features/customer/providers/customer_form_provider.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/customer/widgets/confetti.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/Core/utils/data_loss_warning.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  final bool isEditing;

  const CustomerFormScreen({super.key, this.customer, this.isEditing = false});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen>
    with DataLossWarningMixin {
  final _formKey = GlobalKey<FormState>();
  bool _hasBeenSaved = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _mobileController;
  late TextEditingController _websiteController;
  late TextEditingController _functionController;
  late TextEditingController _streetController;
  late TextEditingController _street2Controller;
  late TextEditingController _cityController;
  late TextEditingController _zipController;
  late TextEditingController _companyNameController;
  late TextEditingController _vatController;
  late TextEditingController _industryController;
  // late TextEditingController _creditLimitController;
  late TextEditingController _commentController;

  bool _isCompany = false;
  int? _selectedCountryId;
  int? _selectedStateId;
  String? _selectedTitle;
  String? _selectedCurrency;
  String? _selectedLanguage;
  String stripHtml(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  @override
  bool get hasUnsavedData {
    if (_hasBeenSaved) return false;
    final c = widget.customer;
    String clean(String? v) => (v == null || v == 'false') ? '' : v;

    return _nameController.text.trim() != clean(c?.name) ||
        _emailController.text.trim() != clean(c?.email) ||
        _phoneController.text.trim() != clean(c?.phone) ||
        _mobileController.text.trim() != clean(c?.mobile) ||
        _websiteController.text.trim() != clean(c?.website) ||
        _functionController.text.trim() != clean(c?.function) ||
        _streetController.text.trim() != clean(c?.street) ||
        _street2Controller.text.trim() != clean(c?.street2) ||
        _cityController.text.trim() != clean(c?.city) ||
        _zipController.text.trim() != clean(c?.zip) ||
        _vatController.text.trim() != clean(c?.vat) ||
        _commentController.text.trim() != clean(c?.comment) ||
        _isCompany != (c?.isCompany ?? false) ||
        _selectedCountryId != c?.countryId ||
        _selectedStateId != c?.stateId ||
        _selectedTitle != c?.title ||
        _selectedLanguage != c?.lang ||
        _companyNameController.text.trim() != clean(c?.companyName) ||
        _industryController.text.trim() != clean(c?.industry);
  }

  @override
  void onConfirmLeave() {
    // Optional: reset fields or perform cleanup
  }

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    String clean(String? v) => (v == null || v == 'false') ? '' : v;

    _nameController = TextEditingController(text: clean(c?.name));
    _emailController = TextEditingController(text: clean(c?.email));
    _phoneController = TextEditingController(text: clean(c?.phone));
    _mobileController = TextEditingController(text: clean(c?.mobile));
    _websiteController = TextEditingController(text: clean(c?.website));
    _functionController = TextEditingController(text: clean(c?.function));
    _streetController = TextEditingController(text: clean(c?.street));
    _street2Controller = TextEditingController(text: clean(c?.street2));
    _cityController = TextEditingController(text: clean(c?.city));
    _zipController = TextEditingController(text: clean(c?.zip));
    _companyNameController = TextEditingController(text: clean(c?.companyName));
    _vatController = TextEditingController(text: clean(c?.vat));
    _industryController = TextEditingController(text: clean(c?.industry));
    _commentController = TextEditingController(
      text: stripHtml(clean(c?.comment)),
    );

    _isCompany = c?.isCompany ?? false;
    _selectedCountryId = c?.countryId;
    _selectedStateId = c?.stateId;
    _selectedTitle = c?.title;
    _selectedLanguage = c?.lang;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formProvider = Provider.of<CustomerFormProvider>(
        context,
        listen: false,
      );
      formProvider.reset();
      formProvider.loadDropdownData();
      if (_selectedCountryId != null) {
        formProvider.fetchStates(_selectedCountryId!);
      }
    });

    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _websiteController.dispose();
    _functionController.dispose();
    _streetController.dispose();
    _street2Controller.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _companyNameController.dispose();
    _vatController.dispose();
    _industryController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dashboardProvider = context.read<DashboardProvider>();
    dashboardProvider.clearAll();

    try {
      await ConnectivityService.instance.ensureInternetOrThrow();
    } on NoInternetException catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final formProvider = Provider.of<CustomerFormProvider>(
      context,
      listen: false,
    );

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'is_company': _isCompany,
      'customer_rank': 1, // Ensure visibility in customer list
      'type': 'contact', // Ensure visibility in customer list
    };

    void addField(String key, String value) {
      if (value.trim().isNotEmpty && value.trim().toLowerCase() != 'false') {
        data[key] = value.trim();
      }
    }

    addField('email', _emailController.text);
    addField('phone', _phoneController.text);
    addField('mobile', _mobileController.text);
    addField('website', _websiteController.text);
    addField('function', _functionController.text);
    addField('street', _streetController.text);
    addField('street2', _street2Controller.text);
    addField('city', _cityController.text);
    addField('zip', _zipController.text);
    addField('vat', _vatController.text);
    addField('comment', _commentController.text);

    if (_selectedCountryId != null) data['country_id'] = _selectedCountryId;
    if (_selectedStateId != null) data['state_id'] = _selectedStateId;
    if (_selectedTitle != null) data['title'] = _selectedTitle;
    if (_selectedLanguage != null) data['lang'] = _selectedLanguage;
    if (_companyNameController.text.isNotEmpty) {
      data['company_name'] = _companyNameController.text.trim();
    }
    if (_industryController.text.isNotEmpty) {
      data['industry_id'] = _industryController.text.trim();
    }

    if (formProvider.pickedImage != null) {
      final bytes = await formProvider.pickedImage!.readAsBytes();
      data['image_1920'] = base64Encode(bytes);
    }

    bool success = false;
    bool retry = true;
    int retryCount = 0;
    const int maxRetries = 5;

    while (retry && retryCount < maxRetries) {
      retry = false;
      try {
        if (widget.isEditing) {
          success = await customerProvider.updateCustomer(
            widget.customer!.id!,
            data,
          );
        } else {
          final newId = await customerProvider.createCustomer(data);
          success = newId > 0;
        }
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('keyerror') ||
            errorStr.contains('invalid field')) {
          if (data.containsKey('mobile') && errorStr.contains('mobile')) {
            data.remove('mobile');
            retry = true;
            retryCount++;
            continue;
          }
        }

        if (mounted) {
          CustomSnackbar.showError(
            context,
            customerProvider.error ?? e.toString(),
          );
        }
        return; // Stop on other errors
      }
    }

    if (success && mounted) {
      setState(() {
        _hasBeenSaved = true;
      });
      if (!widget.isEditing) {
        await showCustomerCreatedConfettiDialog(
          context,
          _nameController.text.trim(),
        );
      } else {
        CustomSnackbar.showSuccess(context, 'Customer updated successfully');
      }
      if (mounted) Navigator.pop(context, true);
    } else if (mounted && !success) {
      CustomSnackbar.showError(
        context,
        customerProvider.error ?? 'Failed to save customer',
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Provider.of<CustomerFormProvider>(
                  context,
                  listen: false,
                ).pickImage(ImageSource.camera);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCamera02,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    const Text('Take Photo', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Provider.of<CustomerFormProvider>(
                  context,
                  listen: false,
                ).pickImage(ImageSource.gallery);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedImageCrop,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Choose from Gallery',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  void _showBusinessCardScanner() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                //   context,
                // ).scanBusinessCard(ImageSource.camera);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCamera02,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Scan with Camera',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                //   context,
                // ).scanBusinessCard(ImageSource.gallery);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedImageCrop,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Scan from Gallery',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<CustomerFormProvider>(
      builder: (context, formProvider, child) {
        if (formProvider.isDropdownLoading) {
          return _buildShimmerLoading(isDark, primaryColor);
        }

        return PopScope(
          canPop: !hasUnsavedData,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await handleWillPop();
            if (shouldPop && mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.isEditing ? 'Edit Customer' : 'Create Customer',
              ),
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              foregroundColor: isDark ? Colors.white : primaryColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () => handleNavigation(() => Navigator.pop(context)),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            body: RefreshIndicator(
              onRefresh: () => formProvider.loadDropdownData(),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),
                    _buildPhotoPicker(formProvider, isDark, primaryColor),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Name *',
                      hintText: 'Enter full name',
                      isDark: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter email address',
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                          );
                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Enter a valid email address';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone',
                      hintText: 'Enter phone number',
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _mobileController,
                      labelText: 'Mobile',
                      hintText: 'Enter mobile number',
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _websiteController,
                      labelText: 'Website',
                      hintText: 'Enter website URL',
                      isDark: isDark,
                      keyboardType: TextInputType.url,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _functionController,
                      labelText: 'Job Position',
                      hintText: 'Enter job title',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _isCompany,
                          onChanged: (v) =>
                              setState(() => _isCompany = v ?? false),
                        ),
                        const Text('Is Company'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _companyNameController,
                      labelText: 'Company Name',
                      hintText: 'Enter company name',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _vatController,
                      labelText: 'VAT Number',
                      hintText: 'Enter VAT/Tax ID',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _industryController,
                      labelText: 'Industry',
                      hintText: 'Enter industry type',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    //   controller: _creditLimitController,
                    //   labelText: 'Credit Limit',
                    //   hintText: 'Enter credit limit amount',
                    //   isDark: isDark,
                    //   keyboardType: TextInputType.number,
                    //   validator: (v) => null,
                    // ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _streetController,
                      labelText: 'Street',
                      hintText: 'Enter street address',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _street2Controller,
                      labelText: 'Street 2',
                      hintText: 'Enter additional address info',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _cityController,
                      labelText: 'City',
                      hintText: 'Enter city name',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),

                    CustomGenericDropdownField<int>(
                      value: _selectedCountryId,
                      labelText: 'Country',
                      hintText: 'Choose your country',
                      isDark: isDark,
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            'Select Country',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        ...formProvider.countryOptions.map(
                          (c) => DropdownMenuItem<int>(
                            value: c['id'],
                            child: Text(c['name']),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _selectedCountryId = v;
                          _selectedStateId = null;
                        });
                        if (v != null) formProvider.fetchStates(v);
                      },
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),

                    CustomGenericDropdownField<int>(
                      value: _selectedStateId,
                      labelText: 'State',
                      hintText: _selectedCountryId == null
                          ? 'Select a country first'
                          : 'Choose your state/province',
                      isDark: isDark,
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            'Select State',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        ...formProvider.stateOptions.map(
                          (s) => DropdownMenuItem<int>(
                            value: s['id'],
                            child: Text(s['name']),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedStateId = v),
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _zipController,
                      labelText: 'ZIP Code',
                      hintText: 'Enter postal code',
                      isDark: isDark,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    //   value: _selectedTitle,
                    //   labelText: 'Title',
                    //   hintText: 'Select title',
                    //   isDark: isDark,
                    //   items: formProvider.titleOptions
                    //       .map(
                    //         (m) => DropdownMenuItem(
                    //           value: m['value'],
                    //           child: Text(m['label']!),
                    //         ),
                    //       )
                    //       .toList(),
                    //   onChanged: (v) => setState(() => _selectedTitle = v),
                    //   validator: (v) => null,
                    // ),
                    const SizedBox(height: 12),
                    CustomDropdownField(
                      value: _selectedLanguage,
                      labelText: 'Language',
                      hintText: 'Select preferred language',
                      isDark: isDark,
                      items: formProvider.languageOptions
                          .map(
                            (m) => DropdownMenuItem(
                              value: m['value'],
                              child: Text(m['label']!),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedLanguage = v),
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _commentController,
                      labelText: 'Internal Notes',
                      hintText: 'Enter any additional information',
                      isDark: isDark,
                      maxLines: 3,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 24),

                    Consumer<CustomerProvider>(
                      builder: (context, customerProvider, child) {
                        return ElevatedButton(
                          onPressed:
                              (customerProvider.isLoading ||
                                  formProvider.isOcrLoading ||
                                  _nameController.text.trim().isEmpty)
                              ? null
                              : _save,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              (customerProvider.isLoading ||
                                  formProvider.isOcrLoading)
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Text(
                                  widget.isEditing
                                      ? 'Save Changes'
                                      : 'Create Customer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoPicker(
    CustomerFormProvider formProvider,
    bool isDark,
    Color primaryColor,
  ) {
    Widget photoWidget;
    if (formProvider.pickedImage != null) {
      photoWidget = CircleAvatar(
        radius: 48,
        backgroundImage: FileImage(formProvider.pickedImage!),
      );
    } else if (widget.customer?.image128 != null) {
      photoWidget = CircleAvatar(
        radius: 48,
        backgroundImage: MemoryImage(base64Decode(widget.customer!.image128!)),
      );
    } else {
      photoWidget = CircleAvatar(
        radius: 48,
        backgroundColor: isDark
            ? Colors.grey.shade200
            : primaryColor.withOpacity(.1),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedImage03,
          size: 48,
          color: isDark ? Colors.grey.shade800 : primaryColor,
        ),
      );
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          photoWidget,
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _showImageSourceActionSheet,
              borderRadius: BorderRadius.circular(24),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? Colors.grey : primaryColor,
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedImageAdd01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark, Color primaryColor) {
    final shimmerBase = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final shimmerHighlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Customer' : 'Create Customer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Container(
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Shimmer.fromColors(
            baseColor: shimmerBase,
            highlightColor: shimmerHighlight,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    15,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
