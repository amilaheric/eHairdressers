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
import 'package:ehairdressers_mobile/widgets/validation_field.dart';
import 'package:ehairdressers_mobile/utils/validation_utils.dart';
import 'package:ehairdressers_mobile/utils/success_messages.dart';
import 'package:ehairdressers_mobile/utils/error_messages.dart';
import 'package:ehairdressers_mobile/screens/products_list_screen.dart';
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
    if (widget.product != null) {
      _initializeEditForm();
    }
  }

  void _initializeEditForm() {
    setState(() {});
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
    } catch (e) {}
  }

  Future initForm() async {
    try {
      brandResult = await _brandProvider.get();
      categoryResult = await _categoryProvider.get();
    } catch (e) {
      print("Error loading form data: $e");
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
        title: widget.product == null ? "Add Product" : "Edit Product",
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: SingleChildScrollView(
              child: Column(children: [
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildForm(),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          var request = Map<String, dynamic>.from(
                              _formKey.currentState!.value);

                          if (_base64Image != null) {
                            request['image'] = _base64Image;
                          }

                          try {
                            if (widget.product == null) {
                              await _productProvider.insert(request);
                              SuccessMessages.showProductCreated(context);
                              _resetForm();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsListScreen(),
                                ),
                              );
                            } else {
                              request['id'] = widget.product!.id;
                              await _productProvider.update(
                                  widget.product!.id!, request);
                              SuccessMessages.showProductUpdated(context);
                              Navigator.pop(context, true);
                            }
                          } on Exception catch (e) {
                            ErrorMessages.show(context, e);
                          }
                        } else {
                          ErrorMessages.show(context,
                              "Please fix the errors highlighted in the form before submitting.",
                              title: "Validation Error");
                        }
                      },
                      child: Text(widget.product == null ? "Save" : "Update"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 247, 233, 211),
                          foregroundColor: Color(0x0FF938f94),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15)),
                    )),
                SizedBox(height: 20),
              ]),
            )));
  }

  FormBuilder _buildForm() {
    Map<String, dynamic> initialValues = {};
    if (widget.product != null) {
      initialValues = {
        'name': widget.product!.name ?? '',
        'code': widget.product!.code ?? '',
        'price': widget.product!.price?.toString() ?? '',
        'description': widget.product!.description ?? '',
        'amount': widget.product!.amount?.toString() ?? '',
        'brandId': widget.product!.brandId?.toString() ?? '',
        'categoryId': widget.product!.categoryId?.toString() ?? '',
      };
    }

    return FormBuilder(
      key: _formKey,
      initialValue: initialValues,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: SizedBox(
            width: 600,
            child: Column(
              children: [
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
                ValidationField(
                  name: 'name',
                  label: 'Product Name',
                  hint: 'Enter product name',
                  validator: ValidationUtils.validateProductName,
                ),
                SizedBox(height: 15),
                ValidationField(
                  name: 'code',
                  label: 'Product Code',
                  hint: 'Enter product code',
                  validator: ValidationUtils.validateProductCode,
                ),
                SizedBox(height: 15),
                ValidationField(
                  name: 'price',
                  label: 'Price',
                  hint: 'Enter product price',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: ValidationUtils.validatePrice,
                ),
                SizedBox(height: 15),
                ValidationField(
                  name: 'description',
                  label: 'Description',
                  hint: 'Enter product description',
                  maxLines: 3,
                  maxLength: 500,
                  validator: ValidationUtils.validateProductDescription,
                ),
                SizedBox(height: 15),
                ValidationField(
                  name: 'amount',
                  label: 'Amount',
                  hint: 'Enter product amount',
                  keyboardType: TextInputType.number,
                  validator: ValidationUtils.validateAmount,
                ),
                SizedBox(height: 15),
                ValidationDropdown<String>(
                  name: 'brandId',
                  label: 'Brand',
                  hint: 'Select brand',
                  validator: (value) =>
                      ValidationUtils.validateRequired(value, 'Brand'),
                  items: _buildBrandItems(),
                ),
                SizedBox(height: 15),
                ValidationDropdown<String>(
                  name: 'categoryId',
                  label: 'Category',
                  hint: 'Select category',
                  validator: (value) =>
                      ValidationUtils.validateRequired(value, 'Category'),
                  items: _buildCategoryItems(),
                ),
              ],
            )),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildBrandItems() {
    return brandResult?.result
            ?.map((item) => DropdownMenuItem(
                  alignment: AlignmentDirectional.center,
                  value: item.id?.toString() ?? "",
                  child: Text(item.name ?? ""),
                ))
            .toList() ??
        [];
  }

  List<DropdownMenuItem<String>> _buildCategoryItems() {
    return categoryResult?.result
            ?.map((item) => DropdownMenuItem(
                  alignment: AlignmentDirectional.center,
                  value: item.id?.toString() ?? "",
                  child: Text(item.name ?? ""),
                ))
            .toList() ??
        [];
  }
}
