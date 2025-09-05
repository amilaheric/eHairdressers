import 'dart:convert';
import 'dart:io';

import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/providers/UserProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/widgets/validation_field.dart';
import 'package:ehairdressers_mobile/utils/validation_utils.dart';
import 'package:ehairdressers_mobile/utils/success_messages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class UserEditScreen extends StatefulWidget {
  final User user;
  final bool isCurrentUser;

  UserEditScreen({Key? key, required this.user, this.isCurrentUser = false}) : super(key: key);

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  File? selectedImage;
  String? _base64Image;
  bool isLoading = true;
  bool changePassword = false;
  final _formKey = GlobalKey<FormBuilderState>();
  late UserProvider _userProvider;
  String defaultImagePath = 'assets/images/default.jpg';

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    setState(() {
      isLoading = false;
    });
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
      changePassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
        title: widget.isCurrentUser ? "Edit Profile" : "Edit User",
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: SingleChildScrollView(
              child: Column(children: [
                isLoading ? Center(child: CircularProgressIndicator()) : _buildForm(),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          var request = Map<String, dynamic>.from(_formKey.currentState!.value);

                          // Convert DateTime objects to strings
                          if (request['birthDate'] is DateTime) {
                            request['birthDate'] = (request['birthDate'] as DateTime).toIso8601String().split('T')[0];
                          }

                          // Add image if selected
                          if (_base64Image != null) {
                            request['image'] = _base64Image;
                          }

                          // Remove password fields if not changing password
                          if (!changePassword) {
                            request.remove('oldPassword');
                            request.remove('password');
                            request.remove('passwordconfirm');
                          }

                          try {
                            await _userProvider.update(widget.user.userId!, request);
                            
                            if (widget.isCurrentUser) {
                              SuccessMessages.showProfileUpdated(context);
                            } else {
                              SuccessMessages.showUserUpdated(context);
                            }
                            
                            Navigator.pop(context);
                          } on Exception catch (e) {
                            _showErrorDialog(context, "Error", e.toString());
                          }
                        } else {
                          // Form validation failed
                          _showErrorDialog(context, "Validation Error", 
                              "Please fix the errors in the form before submitting.");
                        }
                      },
                      child: Text("Update"),
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
    // Initialize form values
    Map<String, dynamic> initialValues = {
      'name': widget.user.name ?? '',
      'surname': widget.user.surname ?? '',
      'email': widget.user.email ?? '',
      'phone': widget.user.phone ?? '',
      'username': widget.user.username ?? '',
      'citizenshipNumber': widget.user.citizenshipNumber ?? '',
      'birthDate': widget.user.birthDate ?? '',
      'address': widget.user.address ?? '',
    };

    return FormBuilder(
      key: _formKey,
      initialValue: initialValues,
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
            SizedBox(height: 20),
            
            // Password change section
            Text(
              'Password Change',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            
            // Checkbox to enable password change
            FormBuilderCheckbox(
              name: 'changePassword',
              title: Text('I want to change password'),
              onChanged: (value) {
                setState(() {
                  changePassword = value ?? false;
                });
              },
            ),
            SizedBox(height: 15),
            
            // Password fields - only shown if changePassword is true
            if (changePassword) ...[
              // For current user, require old password
              if (widget.isCurrentUser) ...[
                ValidationField(
                  name: 'oldPassword',
                  label: 'Current Password',
                  hint: 'Enter current password',
                  obscureText: true,
                  validator: (value) => ValidationUtils.validateRequired(value, 'Current Password'),
                ),
                SizedBox(height: 15),
              ],
              
              ValidationField(
                name: 'password',
                label: 'New Password',
                hint: 'Enter new password',
                obscureText: true,
                validator: changePassword ? ValidationUtils.validatePassword : null,
              ),
              SizedBox(height: 15),
              
              ValidationField(
                name: 'passwordconfirm',
                label: 'Confirm New Password',
                hint: 'Confirm new password',
                obscureText: true,
                validator: changePassword ? (value) => ValidationUtils.validatePasswordConfirm(
                  value, _formKey.currentState?.value['password']) : null,
              ),
              SizedBox(height: 20),
            ],
          ]),
        ),
      ),
    );
  }
}
