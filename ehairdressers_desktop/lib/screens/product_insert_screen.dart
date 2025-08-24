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
import 'package:form_builder_validators/form_builder_validators.dart';
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
  bool isLoading = true;
  final _formKey = GlobalKey<FormBuilderState>();
  late ProductProvider _productProvider;
  late BrandProvider _brandProvider;
  late ProductCategoryProvider _categoryProvider;
  SearchResult<Brand>? brandResult;
  SearchResult<ProductCategory>? categoryResult;
  String defaultImagePath = 'assets/images/default.jpg';

  @override
  void initState() {
    super.initState();
  
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    try {
      _productProvider = context.read<ProductProvider>();
      _brandProvider = context.read<BrandProvider>();
      _categoryProvider = context.read<ProductCategoryProvider>();
      
      if (_brandProvider != null && _categoryProvider != null) {
        initForm();
      }
    } catch (e) {

    }
  }

  Future initForm() async {
    try {
      brandResult = await _brandProvider.get();
      categoryResult = await _categoryProvider.get();
    } catch (e) { // Error in initForm
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
                        var request =
                            new Map.from(_formKey.currentState!.value);
                        if (_base64Image != null) {
                          request['image'] = _base64Image;
                        }
                        
                        try {
                          if (widget.product == null) {
                            await _productProvider.insert(request);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Product uploaded successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            
                            _resetForm();
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
      initialValue: {}, // Removed _initialValue
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
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Name is required'),
                  ]),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'code',
                  decoration: InputDecoration(labelText: "Code"),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Code is required'),
                  ]),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'price',
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Price is required'),
                    FormBuilderValidators.numeric(errorText: 'Price must be a number'),
                    (value) {
                      if (value != null && double.tryParse(value) == null) {
                        return 'Price must be a valid number';
                      }
                      return null;
                    },
                  ]),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'description',
                  decoration: InputDecoration(labelText: "Description"),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Description is required'),
                  ]),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'amount',
                  decoration: InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Amount is required'),
                    FormBuilderValidators.numeric(errorText: 'Amount must be a number'),
                    (value) {
                      if (value != null && int.tryParse(value) == null) {
                        return 'Amount must be a valid integer';
                      }
                      return null;
                    },
                  ]),
                ),
                SizedBox(height: 10),
                FormBuilderDropdown<String>(
                  name: 'brandId',
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    hintText: 'Select Brand',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Brand is required'),
                  ]),
                  items: (() {
                    var items = brandResult?.result
                            ?.map((item) {
                              return DropdownMenuItem(
                                  alignment: AlignmentDirectional.center,
                                  value: item.id?.toString() ?? "",
                                  child: Text(item.name ?? ""),
                                );
                            })
                            .toList() ??
                        [];
                    return items;
                  })(),
                ),
                SizedBox(height: 10),
                FormBuilderDropdown<String>(
                  name: 'categoryId',
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Select Category',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Category is required'),
                  ]),
                  items: (() {
                    var items = categoryResult?.result
                            ?.map((item) {
                               return DropdownMenuItem(
                                  alignment: AlignmentDirectional.center,
                                  value: item.id?.toString() ?? "",
                                  child: Text(item.name ?? ""),
                                );
                            })
                            .toList() ??
                        [];
                          return items;
                  })(),
                ),
              ],
            )),
      ),
    );
  }
}
