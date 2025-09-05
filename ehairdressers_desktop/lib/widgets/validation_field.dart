import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ValidationField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final List<String? Function(String?)>? validators;
  final String? initialValue;
  final void Function(String?)? onChanged;
  final void Function()? onTap;

  const ValidationField({
    Key? key,
    required this.name,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.suffixIcon,
    this.validator,
    this.validators,
    this.initialValue,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          name: name,
          initialValue: initialValue,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          validator: validators != null 
              ? FormBuilderValidators.compose(validators!)
              : validator,
        ),
        // Error message display below the field
        FormBuilderField<String>(
          name: name,
          builder: (FormFieldState<String> field) {
            return field.hasError
                ? Container(
                    margin: EdgeInsets.only(top: 4.0),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.0,
                      ),
                    ),
                  )
                : SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class ValidationDropdown<T> extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final List<String? Function(T?)>? validators;
  final T? initialValue;
  final void Function(T?)? onChanged;

  const ValidationDropdown({
    Key? key,
    required this.name,
    required this.label,
    this.hint,
    required this.items,
    this.validator,
    this.validators,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderDropdown<T>(
          name: name,
          initialValue: initialValue,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          items: items,
          onChanged: onChanged,
          validator: validators != null 
              ? FormBuilderValidators.compose(validators!)
              : validator,
        ),
        // Error message display below the field
        FormBuilderField<T>(
          name: name,
          builder: (FormFieldState<T> field) {
            return field.hasError
                ? Container(
                    margin: EdgeInsets.only(top: 4.0),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.0,
                      ),
                    ),
                  )
                : SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class ValidationDateField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(DateTime?)? validator;
  final List<String? Function(DateTime?)>? validators;
  final DateTime? initialValue;
  final void Function(DateTime?)? onChanged;

  const ValidationDateField({
    Key? key,
    required this.name,
    required this.label,
    this.hint,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.validators,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderDateTimePicker(
          name: name,
          initialValue: initialValue,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          inputType: InputType.date,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime.now(),
          onChanged: onChanged,
          validator: validators != null 
              ? FormBuilderValidators.compose(validators!)
              : validator,
        ),
        // Error message display below the field
        FormBuilderField<DateTime>(
          name: name,
          builder: (FormFieldState<DateTime> field) {
            return field.hasError
                ? Container(
                    margin: EdgeInsets.only(top: 4.0),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.0,
                      ),
                    ),
                  )
                : SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
