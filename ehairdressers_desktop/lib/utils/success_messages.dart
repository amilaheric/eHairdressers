import 'package:flutter/material.dart';

class SuccessMessages {
  // Show success message with specific context
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Product related success messages
  static void showProductCreated(BuildContext context) {
    showSuccess(context, 'Product created successfully!');
  }

  static void showProductUpdated(BuildContext context) {
    showSuccess(context, 'Product updated successfully!');
  }

  static void showProductDeleted(BuildContext context) {
    showSuccess(context, 'Product deleted successfully!');
  }

  // Employee related success messages
  static void showEmployeeCreated(BuildContext context) {
    showSuccess(context, 'Employee created successfully!');
  }

  static void showEmployeeUpdated(BuildContext context) {
    showSuccess(context, 'Employee updated successfully!');
  }

  static void showEmployeeDeleted(BuildContext context) {
    showSuccess(context, 'Employee deleted successfully!');
  }

  // User related success messages
  static void showUserCreated(BuildContext context) {
    showSuccess(context, 'User created successfully!');
  }

  static void showUserUpdated(BuildContext context) {
    showSuccess(context, 'User updated successfully!');
  }

  static void showUserDeleted(BuildContext context) {
    showSuccess(context, 'User deleted successfully!');
  }

  // Appointment related success messages
  static void showAppointmentCreated(BuildContext context) {
    showSuccess(context, 'Appointment created successfully!');
  }

  static void showAppointmentUpdated(BuildContext context) {
    showSuccess(context, 'Appointment updated successfully!');
  }

  static void showAppointmentCancelled(BuildContext context) {
    showSuccess(context, 'Appointment cancelled successfully!');
  }

  // Brand related success messages
  static void showBrandCreated(BuildContext context) {
    showSuccess(context, 'Brand created successfully!');
  }

  static void showBrandUpdated(BuildContext context) {
    showSuccess(context, 'Brand updated successfully!');
  }

  static void showBrandDeleted(BuildContext context) {
    showSuccess(context, 'Brand deleted successfully!');
  }

  // Category related success messages
  static void showCategoryCreated(BuildContext context) {
    showSuccess(context, 'Category created successfully!');
  }

  static void showCategoryUpdated(BuildContext context) {
    showSuccess(context, 'Category updated successfully!');
  }

  static void showCategoryDeleted(BuildContext context) {
    showSuccess(context, 'Category deleted successfully!');
  }

  // Password related success messages
  static void showPasswordChanged(BuildContext context) {
    showSuccess(context, 'Password changed successfully!');
  }

  // Profile related success messages
  static void showProfileUpdated(BuildContext context) {
    showSuccess(context, 'Profile updated successfully!');
  }

  // Generic success messages
  static void showDataSaved(BuildContext context) {
    showSuccess(context, 'Data saved successfully!');
  }

  static void showDataUpdated(BuildContext context) {
    showSuccess(context, 'Data updated successfully!');
  }

  static void showDataDeleted(BuildContext context) {
    showSuccess(context, 'Data deleted successfully!');
  }

  // Custom success message
  static void showCustomSuccess(BuildContext context, String message) {
    showSuccess(context, message);
  }
}
