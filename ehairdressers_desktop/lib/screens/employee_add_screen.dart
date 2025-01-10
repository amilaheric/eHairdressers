import 'dart:convert';
import 'dart:io';

import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/providers/EmployeeProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  SearchResult<User>? employee;
  String defaultImagePath = '.dart_tool/assets/default.jpg';

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
      // User canceled the selection
      // Handle accordingly
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
    employee = await _employeeProvider.get();
    print(employee);

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

                        print(_formKey.currentState?.value);
                        print(_formKey.currentState?.value['name']);
                        var request =
                            new Map.from(_formKey.currentState!.value);

                        request['image'] = _base64Image;

                        print(request['image']);
                        try {
                          if (widget.user == null) {
                            await _employeeProvider.insert(request);
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
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'surname',
              decoration: InputDecoration(labelText: "Surname"),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'phone',
              decoration: InputDecoration(labelText: "Phone"),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'username',
              decoration: InputDecoration(labelText: "Username"),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'password',
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'passwordconfirm',
              decoration: InputDecoration(labelText: "Passwordconfirm"),
            ),
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'citizenshipnumber',
              decoration: InputDecoration(labelText: "Citizenship number"),
            ),
          ]),
        ),
      ),
    );
  }
}
