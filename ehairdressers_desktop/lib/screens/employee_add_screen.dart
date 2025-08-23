import 'dart:convert';
import 'dart:io';

import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/models/employee.dart';
import 'package:ehairdressers_mobile/providers/EmployeeProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
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
    // TODO: implement initState
    super.initState();
    _initialValue = {};

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
        title: "Upload employee",
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: SingleChildScrollView(
              child: Column(children: [
                isLoading ? Container() : _buildEmployeeform(),
                SizedBox(height: 30),
                Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate form before proceeding
                        if (_formKey.currentState?.saveAndValidate() != true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fix all validation errors before submitting'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        var request =
                            Map<String, dynamic>.from(_formKey.currentState!.value);

                        request['image'] = _base64Image;

                        try {
                          if (widget.user == null) {
                         
                            await _employeeProvider.createEmployeeWithRole(request);
                      
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Employee created successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                
                            Navigator.pop(context);
                          }
                        } on Exception catch (e) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text("Error"),
                                    content: Text(e.toString()),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("OK"))
                                    ],
                                  ));
                        }
                      },
                      child: Text("Save"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 247, 233, 211),
                          foregroundColor: Color(0x0FF938f94)),
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
            SizedBox(
              width: 200,
              height: 200,
              child: selectedImage != null
                  ? Image.file(selectedImage!)
                  : Image.asset(defaultImagePath),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                pickImage();
              },
              child: Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 247, 233, 211),
                  foregroundColor: Color(0x0FF938f94)),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(labelText: "Name"),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'surname',
              decoration: InputDecoration(labelText: "Surname"),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "example@email.com",
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
                (value) {
                  if (value != null) {
                    // Additional email format validation
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    // Check for common invalid patterns
                    if (value.contains('..') || value.startsWith('.') || value.endsWith('.')) {
                      return 'Email format is invalid';
                    }
                  }
                  return null;
                },
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'phone',
              decoration: InputDecoration(
                labelText: "Phone",
                hintText: "+387 XX XXX-XXXX or 06X XXX-XXXX",
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (value) {
                  if (value != null && value.isNotEmpty) {
                    // Remove all non-digit characters for validation
                    var cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                    
                    // Check minimum length
                    if (cleanPhone.length < 8) {
                      return 'Phone number must be at least 8 digits';
                    }
                    
                    // Check maximum length  
                    if (cleanPhone.length > 15) {
                      return 'Phone number cannot exceed 15 digits';
                    }
                    
                    // Check for valid Bosnian phone number patterns
                    if (value.startsWith('+387')) {
                      // International format for Bosnia
                      if (cleanPhone.length < 11 || cleanPhone.length > 12) {
                        return 'Invalid international phone format';
                      }
                    } else if (value.startsWith('06') || value.startsWith('03')) {
                      // Local mobile/landline format
                      if (cleanPhone.length < 8 || cleanPhone.length > 9) {
                        return 'Invalid local phone format';
                      }
                    } else {
                      // Generic validation for other formats
                      if (!RegExp(r'^[\+]?[0-9\s\-\(\)]{8,15}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                  }
                  return null;
                },
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'username',
              decoration: InputDecoration(
                labelText: "Username",
                hintText: "At least 3 characters, no spaces",
                prefixIcon: Icon(Icons.person),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(3),
                FormBuilderValidators.maxLength(20),
                (value) {
                  if (value != null) {
                    // Username format validation
                    if (value.contains(' ')) {
                      return 'Username cannot contain spaces';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    if (value.startsWith('_') || value.endsWith('_')) {
                      return 'Username cannot start or end with underscore';
                    }
                  }
                  return null;
                },
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'password',
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "At least 8 characters with letters and numbers",
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(8),
                (value) {
                  if (value != null) {
                    // Strong password validation
                    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                      return 'Password must contain both letters and numbers';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9@#$%^&*()_+\-=\[\]{}|;:,.<>?]+$').hasMatch(value)) {
                      return 'Password contains invalid characters';
                    }
                  }
                  return null;
                },
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'passwordconfirm',
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "Re-enter your password",
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (value) {
                  final password = _formKey.currentState?.value['password'];
                  if (value != password) {
                    return 'Passwords do not match';
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'citizenshipNumber',
              decoration: InputDecoration(labelText: "Citizenship number"),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 10),
            _buildDateField('birthDate', 'Birth Date'),
            SizedBox(height: 10),
            _buildDateField('hireDate', 'Hire Date'),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'salary',
              decoration: InputDecoration(labelText: "Salary"),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'address',
              decoration: InputDecoration(labelText: "Address"),
              maxLines: 3,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (value) {
                  if (value != null && value.length > 50) {
                    return 'Address cannot exceed 50 characters';
                  }
                  return null;
                },
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildDateField(String name, String label) {
    return FormBuilderTextField(
      name: name,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              _formKey.currentState?.fields[name]?.didChange(
                DateFormat('yyyy-MM-dd').format(picked),
              );
            }
          },
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
      ]),
    );
  }
}
