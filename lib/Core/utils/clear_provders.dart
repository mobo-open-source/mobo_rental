// lib/utils/provider_utils.dart
import 'package:flutter/material.dart';
import 'package:mobo_rental/features/profile/providers/profile_provider.dart';
import 'package:mobo_rental/features/customer/providers/customer_form_provider.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/home/provider/navigation_provider.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/schedule_rental/provider/rental_schedule_provider.dart';
import 'package:provider/provider.dart';
// ... import your providers here

void resetAllAppProviders(BuildContext context) {
  // Clear Profile & User Data
  context.read<ProfileProvider>().resetState();
  context.read<UserProvider>().resetUser();
  context.read<CustomerProvider>().clearData();
  context.read<CustomerFormProvider>().reset();

  // Clear Dashboard & Sales
  context.read<DashboardProvider>().clearAll();
  context.read<RentalScheduleProvider>().resetProvider();

  // Clear Orders & Products
  context.read<CreateRentalProvider>().clearRentalQutationStates();
  context.read<RentalOrderProvider>().clearRentalOrderProviderState();
  context.read<ProductProvider>().clearData();

  // Reset Navigation
  context.read<NavigationProvider>().resetScreenIndex();

}
