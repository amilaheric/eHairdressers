import 'dart:convert';
import 'dart:io';

import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/models/brand.dart';
import 'package:ehairdressers_mobile/models/product.dart';
import 'package:ehairdressers_mobile/models/product_category.dart';
import 'package:ehairdressers_mobile/providers/BrandProvider.dart';
import 'package:ehairdressers_mobile/providers/ProductCategoryProvider.dart';
import 'package:ehairdressers_mobile/providers/ProductProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class ProductInsert extends StatefulWidget {
  Product? product;
  ProductInsert({Key? key, this.product}) : super(key: key);
  @override
  State<ProductInsert> createState() => _ProductInsertState();
}

class _ProductInsertState extends State<ProductInsert> {
  File? selectedImage;
  String? _base64Image;

  String defaultImagePath = '.dart_tool/assets/default.jpg';
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late BrandProvider _brandProvider;
  late ProductCategoryProvider _categoryProvider;
  late ProductProvider _productProvider;
  SearchResult<Brand>? brandResult;
  SearchResult<ProductCategory>? categoryResult;

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _initialValue = {};

    _productProvider = context.read<ProductProvider>();
    _brandProvider = context.read<BrandProvider>();
    _categoryProvider = context.read<ProductCategoryProvider>();
    initForm();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future initForm() async {
    brandResult = await _brandProvider.get();
    categoryResult = await _categoryProvider.get();
    if (brandResult?.result != null) {
      for (var item in brandResult!.result!) {
        print(item.id);
      }
    }

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

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
        title: "Product upload",
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: SingleChildScrollView(
              child: Column(children: [
                isLoading ? Container() : _buildForm(),
                SizedBox(height: 10),
                Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        _formKey.currentState?.saveAndValidate();
                        print(_formKey.currentState?.value['name']);
                        var request =
                            new Map.from(_formKey.currentState!.value);
                        request['image'] = _base64Image;
                        _formKey.currentState?.reset();
                        print(request);
                        try {
                          if (widget.product == null) {
                            await _productProvider.insert(request);
                          }
                        } on Exception catch (e) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text("Error"),
                                    content: Text(e.toString()),
                                    actions: [
                                      TextButton(
                                          onPressed: (() =>
                                              Navigator.pop(context)),
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

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: SizedBox(
            width: 600,
            child: Column(
              children: [
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
                        foregroundColor: Color(0x0FF938f94))),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(labelText: "Name"),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'code',
                  decoration: InputDecoration(labelText: "Code"),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'price',
                  decoration: InputDecoration(labelText: "Price"),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'description',
                  decoration: InputDecoration(labelText: "Description"),
                ),
                SizedBox(height: 10),
                FormBuilderDropdown<String>(
                  name: 'brandId',
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    hintText: 'Select Brand',
                  ),
                  items: brandResult?.result
                          ?.map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.id.toString(),
                                child: Text(item.name ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
                SizedBox(height: 10),
                FormBuilderDropdown<String>(
                  name: 'categoryId',
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Select Category',
                  ),
                  items: categoryResult?.result
                          ?.map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.id.toString(),
                                child: Text(item.name ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              ],
            )),
      ),
    );
  }
}
