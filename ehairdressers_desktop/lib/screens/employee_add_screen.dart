import 'dart:convert';
import 'dart:io';

import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/models/employee.dart';
import 'package:ehairdressers_mobile/providers/EmployeeProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/widgets/validation_field.dart';
import 'package:ehairdressers_mobile/utils/validation_utils.dart';
import 'package:ehairdressers_mobile/utils/success_messages.dart';
import 'package:ehairdressers_mobile/utils/error_messages.dart';
import 'package:ehairdressers_mobile/screens/employee_list_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmployeeAdd extends StatefulWidget {
  User? user;
  EmployeeAdd({Key? key, this.user}) : super(key: key);
  @override
  State<EmployeeAdd> createState() => _EmployeeAddState();
}

class _EmployeeAddState extends State<EmployeeAdd> {
  File? selectedImage;
  String? _base64Image;
  bool isLoading = true;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late EmployeeProvider _employeeProvider;
  SearchResult<Employee>? employee;
  String defaultImagePath = 'assets/images/default.jpg';

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
    } else {
     
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.user != null) {
      // Initialize form with existing user data for editing
      _initialValue = {
        'name': widget.user!.name ?? '',
        'surname': widget.user!.surname ?? '',
        'email': widget.user!.email ?? '',
        'phone': widget.user!.phone ?? '',
        'username': widget.user!.username ?? '',
        'citizenshipNumber': widget.user!.citizenshipNumber ?? '',
        'birthDate': widget.user!.birthDate ?? '',
        'address': widget.user!.address ?? '',
      };
    } else {
      _initialValue = {};
    }

    _employeeProvider = context.read<EmployeeProvider>();
    initForm();
  }

  Future initForm() async {
    try {
      employee = await _employeeProvider.get();
      print(employee);
    } catch (e) {
      print("Error loading employees: $e");
      employee = SearchResult<Employee>();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
        title: widget.user == null ? "Add Employee" : "Edit Employee",
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: SingleChildScrollView(
              child: Column(children: [
                isLoading ? Center(child: CircularProgressIndicator()) : _buildEmployeeform(),
                SizedBox(height: 30),
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
                          if (request['hireDate'] is DateTime) {
                            request['hireDate'] = (request['hireDate'] as DateTime).toIso8601String().split('T')[0];
                          }

                          // Add image if selected
                          if (_base64Image != null) {
                            request['image'] = _base64Image;
                          }

                          try {
                            if (widget.user == null) {
                              // Creating new employee
                              await _employeeProvider.createEmployeeWithRole(request);
                              SuccessMessages.showEmployeeCreated(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeListScreen(),
                                ),
                              );
                            } else {
                              // Updating existing employee
                              request['userId'] = widget.user!.userId;
                              await _employeeProvider.update(widget.user!.userId!, request);
                              SuccessMessages.showEmployeeUpdated(context);
                              Navigator.pop(context);
                            }
                          } on Exception catch (e) {
                            ErrorMessages.show(context, e);
                          }
                        } else {
                          // Form validation failed
                          ErrorMessages.show(context,
                              "Please fix the errors highlighted in the form before submitting.",
                              title: "Validation Error");
                        }
                      },
                      child: Text(widget.user == null ? "Save" : "Update"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 247, 233, 211),
                          foregroundColor: Color(0x0FF938f94),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    )),
                SizedBox(height: 20),
              ]),
            )));
  }

  FormBuilder _buildEmployeeform() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
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
              label: Text('Select Image'),
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
            
            // Password fields - only required for new employees
            if (widget.user == null) ...[
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
            ],
            
            // Employment information
            Text(
              'Employment Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            
            ValidationDateField(
              name: 'hireDate',
              label: 'Hire Date',
              hint: 'Select hire date',
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              validator: (value) => ValidationUtils.validatePastDate(
                value?.toIso8601String().split('T')[0], 'Hire Date'),
            ),
            SizedBox(height: 15),
            
            ValidationField(
              name: 'salary',
              label: 'Salary',
              hint: 'Enter salary',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: ValidationUtils.validateSalary,
            ),
          ]),
        ),
      ),
    );
  }

}
