import 'package:form_builder_validators/form_builder_validators.dart';

class ValidationUtils {
  // Email validation with clear error message
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address (e.g. user@domain.com)';
    }
    
    return null;
  }

  // Phone validation with clear error message
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Check for Bosnia and Herzegovina phone format: +38761222333
    final phoneRegex = RegExp(r'^\+387[0-9]{8}$');
    
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number in format +38761222333';
    }
    
    return null;
  }

  // Password validation with clear error message
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must have at least 6 characters';
    }
    
    if (value.length > 50) {
      return 'Password cannot have more than 50 characters';
    }
    
    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirm(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Required field validation with custom message
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Generic required validation
  static String? validateRequiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Name validation (first name, last name, etc.)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName must have at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return '$fieldName cannot have more than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-ZčćđšžČĆĐŠŽ\s\-']+$").hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens and apostrophes';
    }
    
    return null;
  }

  // Name validation for specific fields
  static String? validateFirstName(String? value) => validateName(value, 'First Name');
  static String? validateLastName(String? value) => validateName(value, 'Last Name');
  static String? validateProductName(String? value) => validateName(value, 'Product Name');

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    if (value.trim().length < 3) {
      return 'Username must have at least 3 characters';
    }
    
    if (value.trim().length > 30) {
      return 'Username cannot have more than 30 characters';
    }
    
    // Check for valid characters (letters, numbers, underscores)
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers and underscores';
    }
    
    return null;
  }

  // Numeric validation with clear error message
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number for $fieldName';
    }
    
    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;
    
    final num = double.parse(value!.trim());
    if (num <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) => validatePositiveNumber(value, 'Price');

  // Integer validation
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid integer for $fieldName';
    }
    
    return null;
  }

  // Positive integer validation
  static String? validatePositiveInteger(String? value, String fieldName) {
    final integerError = validateInteger(value, fieldName);
    if (integerError != null) return integerError;
    
    final num = int.parse(value!.trim());
    if (num <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) => validatePositiveInteger(value, 'Amount');

  // Text length validation
  static String? validateTextLength(String? value, String fieldName, int minLength, int maxLength) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName must have at least $minLength characters';
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName cannot have more than $maxLength characters';
    }
    
    return null;
  }

  // Citizenship number validation
  static String? validateCitizenshipNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Citizenship number is required';
    }
    
    final cleanValue = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.length != 9) {
      return 'Citizenship number must have exactly 9 digits';
    }
    
    return null;
  }

  // Date validation
  static String? validateDate(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    try {
      DateTime.parse(value.trim());
    } catch (e) {
      return 'Please enter a valid date for $fieldName (format: YYYY-MM-DD)';
    }
    
    return null;
  }

  // Future date validation
  static String? validateFutureDate(String? value, String fieldName) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;
    
    final date = DateTime.parse(value!.trim());
    if (date.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }
    
    return null;
  }

  // Past date validation
  static String? validatePastDate(String? value, String fieldName) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;
    
    final date = DateTime.parse(value!.trim());
    if (date.isAfter(DateTime.now())) {
      return '$fieldName must be in the past';
    }
    
    return null;
  }

  // Code validation (for product codes, etc.)
  static String? validateCode(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName must have at least 2 characters';
    }
    
    if (value.trim().length > 20) {
      return '$fieldName cannot have more than 20 characters';
    }
    
    // Check for valid characters (letters, numbers, hyphens, underscores)
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(value.trim())) {
      return '$fieldName can only contain letters, numbers, hyphens and underscores';
    }
    
    return null;
  }

  // Product code validation
  static String? validateProductCode(String? value) => validateCode(value, 'Product Code');

  // Description validation
  static String? validateDescription(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 10) {
      return '$fieldName must have at least 10 characters';
    }
    
    if (value.trim().length > 500) {
      return '$fieldName cannot have more than 500 characters';
    }
    
    return null;
  }

  // Product description validation
  static String? validateProductDescription(String? value) => validateDescription(value, 'Description');

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    
    if (value.trim().length < 10) {
      return 'Address must have at least 10 characters';
    }
    
    if (value.trim().length > 200) {
      return 'Address cannot have more than 200 characters';
    }
    
    return null;
  }

  // Salary validation
  static String? validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Salary is required';
    }
    
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number for salary';
    }
    
    final salary = double.parse(value.trim());
    if (salary < 0) {
      return 'Salary cannot be negative';
    }
    
    if (salary > 100000) {
      return 'Salary cannot be greater than 100,000';
    }
    
    return null;
  }

  // Image validation
  static String? validateImage(String? base64Image, String fieldName) {
    if (base64Image == null || base64Image.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  // Optional image validation
  static String? validateOptionalImage(String? base64Image) {
    // This is for optional images - no validation needed
    return null;
  }
}
