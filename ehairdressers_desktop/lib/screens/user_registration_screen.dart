import 'dart:convert';
import 'dart:io';

import 'package:ehairdressers_mobile/providers/UserProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/widgets/validation_field.dart';
import 'package:ehairdressers_mobile/utils/validation_utils.dart';
import 'package:ehairdressers_mobile/utils/success_messages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  File? selectedImage;
  String? _base64Image;
  bool isLoading = false;
  final _formKey = GlobalKey<FormBuilderState>();
  late UserProvider _userProvider;
  String defaultImagePath = 'assets/images/default.jpg';

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        selectedImage = file;
        _base64Image = base64Encode(selectedImage!.readAsBytesSync());
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      selectedImage = null;
      _base64Image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
        title: "User Registration",
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: SingleChildScrollView(
              child: Column(children: [
                _buildForm(),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          setState(() {
                            isLoading = true;
                          });

                          var request = Map<String, dynamic>.from(_formKey.currentState!.value);

                          // Convert DateTime objects to strings
                          if (request['birthDate'] is DateTime) {
                            request['birthDate'] = (request['birthDate'] as DateTime).toIso8601String().split('T')[0];
                          }

                          // Add image if selected
                          if (_base64Image != null) {
                            request['image'] = _base64Image;
                          }

                          try {
                            await _userProvider.insert(request);
                            SuccessMessages.showUserCreated(context);
                            _resetForm();
                          } on Exception catch (e) {
                            _showErrorDialog(context, "Error", e.toString());
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        } else {
                          // Form validation failed
                          _showErrorDialog(context, "Validation Error", 
                              "Please fix the errors in the form before submitting.");
                        }
                      },
                      child: isLoading 
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text("Registracija..."),
                              ],
                            )
                          : Text("Register User"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 247, 233, 211),
                          foregroundColor: Color(0x0FF938f94),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    )),
                SizedBox(height: 20),
              ]),
            )));
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK")
          )
        ],
      )
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: SizedBox(
          width: 600,
          child: Column(children: [
            // Image section
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                    : Image.asset(defaultImagePath, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text('Odaberi sliku'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 247, 233, 211),
                  foregroundColor: Color(0x0FF938f94)),
            ),
            SizedBox(height: 20),
            
            // Personal information
            Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'name',
              label: 'First Name',
              hint: 'Enter first name',
              validator: ValidationUtils.validateFirstName,
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'surname',
              label: 'Last Name',
              hint: 'Enter last name',
              validator: ValidationUtils.validateLastName,
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'email',
              label: 'Email Address',
              hint: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
              validator: ValidationUtils.validateEmail,
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'phone',
              label: 'Phone Number',
              hint: 'Enter phone number (+38761222333)',
              keyboardType: TextInputType.phone,
              validator: ValidationUtils.validatePhone,
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'citizenshipNumber',
              label: 'Citizenship Number',
              hint: 'Enter citizenship number',
              validator: ValidationUtils.validateCitizenshipNumber,
            ),
            SizedBox(height: 15),
            
            ValidationDateField(
              name: 'birthDate',
              label: 'Birth Date',
              hint: 'Select birth date',
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              validator: (value) => ValidationUtils.validatePastDate(
                value?.toIso8601String().split('T')[0], 'Birth Date'),
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'address',
              label: 'Address',
              hint: 'Enter address',
              maxLines: 3,
              validator: ValidationUtils.validateAddress,
            ),
            SizedBox(height: 20),
            
            // Account information
            Text(
              'Account Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'username',
              label: 'Username',
              hint: 'Enter username',
              validator: ValidationUtils.validateUsername,
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'password',
              label: 'Password',
              hint: 'Enter password',
              obscureText: true,
              validator: ValidationUtils.validatePassword,
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'passwordconfirm',
              label: 'Confirm Password',
              hint: 'Confirm password',
              obscureText: true,
              validator: (value) => ValidationUtils.validatePasswordConfirm(
                value, _formKey.currentState?.value['password']),
            ),
            SizedBox(height: 20),
            
            // Terms and conditions
            FormBuilderCheckbox(
              name: 'acceptTerms',
              title: Text('I accept the terms of use'),
              validator: (value) {
                if (value != true) {
                  return 'You must accept the terms of use';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            
            FormBuilderCheckbox(
              name: 'acceptPrivacy',
              title: Text('I accept the privacy policy'),
              validator: (value) {
                if (value != true) {
                  return 'You must accept the privacy policy';
                }
                return null;
              },
            ),
          ]),
        ),
      ),
    );
  }
}
