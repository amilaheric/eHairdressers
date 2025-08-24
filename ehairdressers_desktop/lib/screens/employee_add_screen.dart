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
                        _formKey.currentState?.saveAndValidate();

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
              decoration: InputDecoration(labelText: "Email"),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'phone',
              decoration: InputDecoration(labelText: "Phone"),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (value) {
                  if (value != null) {
                    var cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (cleanPhone.length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                  }
                  return null;
                },
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'username',
              decoration: InputDecoration(labelText: "Username"),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'password',
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(6),
              ]),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'passwordconfirm',
              decoration: InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (value) {
                  if (value != _formKey.currentState?.value['password']) {
                    return 'Passwords do not match';
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
