import 'package:ehairdressers_mobile/models/product.dart';
import 'package:ehairdressers_mobile/providers/cart_provider.dart';
import 'package:ehairdressers_mobile/providers/product_provider.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  static const String routeName = "/product";

  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  ProductProvider? _productProvider;
  CartProvider? _cartProvider;
  List<Product> data = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _cartProvider = context.read<CartProvider>();
    loadData();
  }

  Future loadData() async {
    var tempData = await _productProvider?.get();
    setState(() {
      data = tempData!;
      print(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("called build $data");
    return MasterScreenWidget(
      title: "Product list",
      child: SingleChildScrollView(
          child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductSearch(),
            Container(
              height: 500,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4 / 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                scrollDirection: Axis.vertical,
                children: _buildProductCardList(),
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget _buildProductSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) async {
                var tmpData = await _productProvider?.get({'name': value});
                setState(() {
                  data = tmpData!;
                });
              },
              decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0x0FFe5c89d)))),
            ),
          ),
        ),
        /* Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              var tmpData =
                  await _productProvider?.get({'name': _searchController.text});
              setState(() {
                data = tmpData!;
              });
            },
          ),
        )*/
      ],
    );
  }

  List<Widget> _buildProductCardList() {
    if (data.length == 0) {
      return [Text("Loading...")];
    }

    List<Widget> list = data
        .map((x) => SingleChildScrollView(
              child: Container(
                child: Column(children: [
                  InkWell(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: imageFromBase64String(x.image!),
                    ),
                  ),
                  Text(x.name ?? ""),
                  Text(x.price.toString()),
                  Container(
                    height: 20,
                    child: IconButton(
                        onPressed: () {
                          _cartProvider?.addToCart(x);
                          print("dodaje se $x");
                        },
                        icon: Icon(Icons.shopping_cart)),
                  )
                ]),
              ),
            ))
        .cast<Widget>()
        .toList();
    return list;
  }
}
