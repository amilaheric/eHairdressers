import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/models/product.dart';
import 'package:ehairdressers_mobile/providers/ProductProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductProvider _productProvider;
  SearchResult<Product>? result;

  TextEditingController _nameController = new TextEditingController();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Product list",
      child: Container(
        child: Column(children: [_buildSearch(), _buildDataView()]),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            decoration: InputDecoration(labelText: "Name"),
            controller: _nameController,
          )),
          Text("TEST"),
          SizedBox(height: 10),
          ElevatedButton(
              onPressed: () async {
                /* Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProductDetailScreen()));*/
                var data = await _productProvider.get(filter: {
                  'Name': _nameController.text,
                });
                setState(() {
                  result = data;
                });

                // print("data: ${data.result?[0].name}");
              },
              child: Text("Search"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildDataView() {
    return Expanded(
        child: SingleChildScrollView(
      child: DataTable(
          columns: [
            const DataColumn(
                label: const Expanded(
                    child: const Text("ID",
                        style: const TextStyle(fontStyle: FontStyle.italic)))),
            const DataColumn(
                label: const Expanded(
                    child: const Text("Name",
                        style: const TextStyle(fontStyle: FontStyle.italic)))),
            const DataColumn(
                label: const Expanded(
                    child: const Text("Description",
                        style: const TextStyle(fontStyle: FontStyle.italic)))),
          ],
          rows: result?.result
                  ?.map((Product e) => DataRow(cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.name ?? "")),
                        DataCell(Text(e.description ?? "")),
                      ]))
                  .toList()! ??
              []),
    ));
  }
}
