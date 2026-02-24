import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_rental/shared/widgets/dialogs/common_dialog.dart';
import 'package:mobo_rental/Core/Widgets/common/alert_dialog.dart';
import 'package:mobo_rental/Core/Widgets/common/snack_bar.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/rental_orders/models/customer_model.dart';
import 'package:mobo_rental/features/rental_orders/models/payment_term_model.dart';
import 'package:mobo_rental/features/home/screens/home_screen.dart';
import 'package:mobo_rental/Core/Widgets/common/icons.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/rental_orders/widgets/create_rental_order_widgets.dart';
import 'package:mobo_rental/features/rental_orders/widgets/rental_order_widget.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/Core/utils/dashbord_clear_helper.dart';
import 'package:mobo_rental/Core/utils/data_loss_warning.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class CreateRentalOrder extends StatefulWidget {
  const CreateRentalOrder({super.key});

  @override
  State<CreateRentalOrder> createState() => _CreateRentalOrderState();
}

class _CreateRentalOrderState extends State<CreateRentalOrder>
    with DataLossWarningMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CreateRentalProvider>(
      builder: (context, createRentalProvider, child) {
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
            appBar: CustomAppBar(
              title: createRentalProvider.isEditMode
                  ? 'Edit ${createRentalProvider.editingOrderName}'
                  : 'Create Rental Order',
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: createRentalProvider.editRentalLoading
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildShimmerCard(height: 180),
                              const SizedBox(height: 20),
                              _buildShimmerCard(height: 180),
                              const SizedBox(height: 20),
                              _buildShimmerCard(height: 300),
                              const SizedBox(height: 20),
                              _buildShimmerCard(height: 180),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mainCard(
                          title: "Customer Information",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),

                              createRentalProvider.customerIsSelected
                                  ? Visibility(
                                      visible:
                                          createRentalProvider
                                              .customerIsSelected ==
                                          true,
                                      child: CustomerCardWidget(
                                        isTrailing: true,
                                        context: context,
                                        trailingIcon: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedCancelCircleHalfDot,
                                        ),
                                        trailingFunction: () {
                                          createRentalProvider.removeCustomer();
                                        },
                                      ),
                                    )
                                  : TypeAheadField<Customer>(
                                      hideOnEmpty: false,
                                      hideOnLoading: false,

                                      suggestionsCallback: (pattern) async {
                                        await createRentalProvider
                                            .searchCustomers(context, pattern);

                                        return createRentalProvider
                                            .customerList;
                                      },

                                      decorationBuilder: (context, child) {
                                        return Material(
                                          elevation: 4,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: isDark
                                              ? Colors.grey[850]
                                              : Colors.white,
                                          child: Container(
                                            constraints: BoxConstraints(
                                              maxHeight: 250,
                                            ),
                                            child: child,
                                          ),
                                        );
                                      },

                                      builder: (context, controller, focusNode) {
                                        return TextFormField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          onTapOutside: (event) {
                                            focusNode.unfocus();
                                            createRentalProvider
                                                .closeCustomerDropdown();
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                "Type to search customer...",
                                            hintStyle: TextStyle(
                                              color: isDark
                                                  ? Colors.grey[500]
                                                  : Colors.black38,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            prefixIcon: Transform.scale(
                                              scale: 0.5,

                                              child: HugeIcon(
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black,

                                                icon: HugeIcons
                                                    .strokeRoundedUser03,
                                                size: 10,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                createRentalProvider
                                                            .showCustomerDropdown ==
                                                        false
                                                    ? Icons.arrow_drop_down
                                                    : Icons.arrow_drop_up,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.black45,
                                              ),
                                              onPressed: () {
                                                if (createRentalProvider
                                                        .showCustomerDropdown ==
                                                    true) {
                                                  createRentalProvider
                                                      .closeCustomerDropdown();
                                                  focusNode.unfocus();
                                                } else {
                                                  createRentalProvider
                                                      .openCustomerDropdown();
                                                  focusNode.requestFocus();
                                                }
                                              },
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: isDark
                                                ? Colors.grey[900]
                                                : const Color(0xfff5f5f5),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 18,
                                                ),
                                          ),
                                        );
                                      },

                                      itemBuilder: (context, Customer item) {
                                        return ListTile(
                                          minVerticalPadding: 10,
                                          title: Text(
                                            item.name,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,

                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            item.email ?? 'No email available',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.black54,
                                            ),
                                          ),
                                        );
                                      },

                                      onSelected: (Customer item) {
                                        createRentalProvider.setCustomer(item);
                                      },

                                      loadingBuilder: (context) => SizedBox(
                                        height: 80,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            padding: EdgeInsets.all(8),
                                          ),
                                        ),
                                      ),

                                      emptyBuilder: (context) => Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          "No results found",
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),

                              SizedBox(height: 10),
                            ],
                          ),
                          isDark: isDark,
                        ),
                        SizedBox(height: 20),
                        mainCard(
                          isDark: isDark,
                          title: "Rental Details",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Expiration Date",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              dateField(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(createRentalProvider.expirationDate),
                                () => chooseExpirationDate(context),
                                isDark,
                              ),
                              SizedBox(height: 16),

                              Text(
                                "Quotation Date",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              dateField(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(createRentalProvider.quotationDate),
                                () => chooseQuotationDate(context),
                                isDark,
                              ),
                              SizedBox(height: 16),

                              Text(
                                "Payment Terms",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),

                              TypeAheadField<PaymentTerm>(
                                controller:
                                    createRentalProvider.paymentTermController,
                                hideOnEmpty: false,
                                debounceDuration: Duration(milliseconds: 500),
                                suggestionsCallback: (pattern) async {
                                  await createRentalProvider.fetchPaymentTerms(
                                    context,
                                    pattern,
                                  );
                                  return createRentalProvider.paymentTermsList;
                                },
                                decorationBuilder: (context, child) {
                                  return Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 250,
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                builder: (context, controller, focusNode) {
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    onTapOutside: (event) {
                                      focusNode.unfocus();
                                      createRentalProvider
                                          .closePaymentDropdown();
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Select Payment Term',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Colors.grey[500]
                                            : Colors.black38,
                                      ),
                                      prefixIcon: Transform.scale(
                                        scale: 0.5,
                                        child: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedCreditCardPos,
                                          color: isDark
                                              ? Color(0xfff5f5f5)
                                              : Colors.black45,
                                        ),
                                      ),

                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          createRentalProvider
                                                      .showPaymentDropdown ==
                                                  true
                                              ? Icons.arrow_drop_up
                                              : Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.black45,
                                        ),
                                        onPressed: () {
                                          if (createRentalProvider
                                              .showPaymentDropdown) {
                                            createRentalProvider
                                                .closePaymentDropdown();
                                            focusNode.unfocus();
                                          } else {
                                            createRentalProvider
                                                .openPaymentDropdown();
                                            focusNode.requestFocus();
                                          }
                                        },
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey[900]
                                          : const Color(0xfff5f5f5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 18,
                                      ),
                                    ),
                                  );
                                },
                                itemBuilder: (context, PaymentTerm item) {
                                  return ListTile(
                                    minVerticalPadding: 10,
                                    title: Text(
                                      item.name,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  );
                                },
                                onSelected: (PaymentTerm item) {
                                  createRentalProvider
                                          .paymentTermController
                                          .text =
                                      item.name;
                                  createRentalProvider.setPaymentTerm(item);
                                },
                                loadingBuilder: (context) => SizedBox(
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                emptyBuilder: (context) {
                                  return Padding(
                                    padding: EdgeInsetsGeometry.all(16),
                                    child: Text(
                                      'No Payment Term Available',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.black54,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10),
                              SizedBox(height: 10),

                              Text(
                                "Rental period",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "From:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              dateField(
                                DateFormat(
                                  'MMM dd, yyyy – hh:mm a',
                                ).format(createRentalProvider.fromDate),
                                () => chooseFromDateTime(context),
                                isDark,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "To:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              dateField(
                                DateFormat(
                                  'MMM dd, yyyy – hh:mm a',
                                ).format(createRentalProvider.toDate),
                                () => chooseToDateTime(context),
                                isDark,
                              ),

                              SizedBox(height: 8),
                              Text(
                                "Duration:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              dateField(
                                createRentalProvider.duration,
                                () {},
                                isDark,
                              ),
                              Consumer<CreateRentalProvider>(
                                builder: (context, provider, _) {
                                  if (!provider.rentalDatesChanged ||
                                      provider.selectedProducts.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: ElevatedButton(
                                      onPressed: provider.updatingRentalPrices
                                          ? null
                                          : () => _confirmUpdateRentalPrices(
                                              context,
                                            ),
                                      child: const Text('Update Rental Prices'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        mainCard(
                          isDark: isDark,
                          title: "Products",
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  createRentalProvider.fetchProducts(
                                    context,
                                    '',
                                  );
                                  openProduct(context);
                                  createRentalProvider.fetchTaxes(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[700]
                                        : const Color.fromARGB(
                                            255,
                                            245,
                                            245,
                                            245,
                                          ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedSquareLockAdd01,
                                        color: isDark ? Colors.white70 : null,
                                      ),
                                      SizedBox(width: 8),
                                      CustomText(
                                        fontweight: FontWeight.w800,
                                        text: "Add Product",
                                        size: 16,
                                        textcolor: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              createRentalProvider.selectedProducts.isNotEmpty
                                  ? productShowing(context)
                                  : Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[800]
                                            : const Color.fromARGB(
                                                255,
                                                245,
                                                245,
                                                245,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedShoppingBasket02,
                                            color: isDark
                                                ? Colors.grey.withAlpha(180)
                                                : Colors.grey.withAlpha(100),
                                            size: 50,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            "No products added yet",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Tap "Add Product" to get started',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (createRentalProvider.selectedCustomer != null &&
                                createRentalProvider
                                    .selectedProducts
                                    .isNotEmpty) {
                              bool success;

                              if (createRentalProvider.isEditMode) {
                                success = await createRentalProvider
                                    .updateRentalOrder(context);
                              } else {
                                success = await createRentalProvider
                                    .createRentalOrder(context);
                              }

                              if (success && context.mounted) {
                                context.refreshDashboard();
                               
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const HomeScreen(initialIndex: 1),
                                  ),
                                );

                                CustomSnackbar.showSuccess(
                                  context,
                                  createRentalProvider.isEditMode
                                      ? 'Rental Order updated successfully'
                                      : 'Rental Order created successfully',
                                );
                              }
                            } else {
                              CustomSnackbar.showError(
                                context,
                                'Some required fields are missing or invalid',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            backgroundColor:
                                createRentalProvider.selectedCustomer == null ||
                                    createRentalProvider
                                        .selectedProducts
                                        .isEmpty
                                ? (isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[400]!)
                                : Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedFileAdd,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                if (createRentalProvider.isCreatingRental ||
                                    createRentalProvider.isUpdatingRental)
                                  Row(
                                    children: [
                                      Text(
                                        createRentalProvider.isUpdatingRental
                                            ? 'Updating Rental Order'
                                            : 'Creating Rental Order',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      LoadingAnimationWidget.staggeredDotsWave(
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  )
                                else
                                  CustomText(
                                    text: createRentalProvider.isEditMode
                                        ? 'Update Rental'
                                        : 'Create Rental',
                                    size: 16,
                                    textcolor: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontweight: FontWeight.w600,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Future<void> chooseExpirationDate(BuildContext context) async {
    final provider = Provider.of<CreateRentalProvider>(context, listen: false);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.expirationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            datePickerTheme: DatePickerThemeData(
              dividerColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      provider.setExpirationDate(pickedDate);
    }
  }

  Future<void> chooseQuotationDate(BuildContext context) async {
    final provider = Provider.of<CreateRentalProvider>(context, listen: false);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.quotationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            datePickerTheme: DatePickerThemeData(
              dividerColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      provider.setQuotationDate(pickedDate);
    }
  }

  Future<void> chooseFromDateTime(BuildContext context) async {
    final provider = Provider.of<CreateRentalProvider>(context, listen: false);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            datePickerTheme: DatePickerThemeData(
              dividerColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(provider.fromDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        provider.setFromDate(finalDateTime, context);
      }
    }
  }

  Future<void> chooseToDateTime(BuildContext context) async {
    final provider = Provider.of<CreateRentalProvider>(context, listen: false);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            datePickerTheme: DatePickerThemeData(
              dividerColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(provider.toDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        provider.setToDate(finalDateTime, context);
      }
    }
  }

  @override
  bool get hasUnsavedData {
    final provider = context.read<CreateRentalProvider>();
    return provider.hasUnsavedChanges;
  }

  void _confirmUpdateRentalPrices(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CommonDialog(
        title: 'Update Rental Prices',
        message:
            'This will update the unit price of all rental products based on the new period.',
        icon: HugeIcons.strokeRoundedRefresh,
        primaryLabel: 'Update',
        secondaryLabel: 'Cancel',
        onPrimary: () {
          Navigator.of(ctx).pop();
          _showRentalUpdateLoading(context);
        },
        onSecondary: () => Navigator.of(ctx).pop(),
        topIconCentered: true,
      ),
    );
  }

  Future<void> _showRentalUpdateLoading(BuildContext context) async {
    loadingDialog(
      context,
      'Updating rental prices',
      'Please hold for a moment!',
      LoadingAnimationWidget.fourRotatingDots(
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );

    try {
      await context.read<CreateRentalProvider>().actionUpdateRentalPrices(
        context,
      );
    } finally {
      hideLoadingDialog(context);
    }
  }
}
