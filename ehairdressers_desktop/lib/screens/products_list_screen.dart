import 'dart:async';
import 'package:ehairdressers_mobile/models/product.dart';
import 'package:ehairdressers_mobile/models/brand.dart';
import 'package:ehairdressers_mobile/models/product_category.dart';
import 'package:ehairdressers_mobile/providers/ProductProvider.dart';
import 'package:ehairdressers_mobile/providers/BrandProvider.dart';
import 'package:ehairdressers_mobile/providers/ProductCategoryProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/screens/product_insert_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProductsListScreen extends StatefulWidget {
  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  late ProductProvider _productProvider;
  late BrandProvider _brandProvider;
  late ProductCategoryProvider _categoryProvider;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Brand> brands = [];
  List<ProductCategory> categories = [];
  
  // Pagination
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalCount = 0;
  int totalPages = 0;
  
  // Filtering
  String searchQuery = '';
  int? selectedBrandId;
  int? selectedCategoryId;
  double? minPrice;
  double? maxPrice;
  
  // Filter state
  bool showFilters = false;
  
  // Sorting
  String sortField = 'name';
  bool sortAscending = true;
  
  // Search debounce
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _categoryProvider = Provider.of<ProductCategoryProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
    _brandProvider = context.read<BrandProvider>();
    _categoryProvider = context.read<ProductCategoryProvider>();
    _loadProducts();
    _loadBrandsAndCategories();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBrandsAndCategories() async {
    try {
      // Load brands
      var brandResult = await _brandProvider.get();
      setState(() {
        brands = brandResult.result;
      });
      
      // Load categories
      var categoryResult = await _categoryProvider.get();
      setState(() {
        categories = categoryResult.result;
      });
    } catch (e) {
      print("Error loading brands/categories: $e");
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
      
      print("=== LOADING PRODUCTS ===");
      print("Page: $currentPage, PageSize: $itemsPerPage, Search: $searchQuery");
      print("SortBy: $sortField, SortOrder: ${sortAscending ? 'asc' : 'desc'}");
      print("BrandId: $selectedBrandId, CategoryId: $selectedCategoryId");
      print("Price range: $minPrice - $maxPrice");
      
      // Build filter parameters - always include pagination and sorting
      Map<String, dynamic> filterParams = {
        'page': currentPage,
        'pageSize': itemsPerPage,
      };
      
      // Add sorting parameters
      filterParams['sortBy'] = sortField;
      filterParams['sortOrder'] = sortAscending ? 'asc' : 'desc';
      
      // Add search filter
      if (searchQuery.isNotEmpty) {
        filterParams['name'] = searchQuery;
      }
      
      // Add brand filter
      if (selectedBrandId != null) {
        filterParams['brandId'] = selectedBrandId;
      }
      
      // Add category filter
      if (selectedCategoryId != null) {
        filterParams['categoryId'] = selectedCategoryId;
      }
      
      // Add price range filters
      if (minPrice != null) {
        filterParams['minPrice'] = minPrice;
      }
      if (maxPrice != null) {
        filterParams['maxPrice'] = maxPrice;
      }
      
      print("Filter parameters: $filterParams");
      
      var result = await _productProvider.get(filter: filterParams);
      print("Products result: $result");
      print("Products count: ${result.result.length}");
      print("Total count from backend: ${result.count}");
      print("Products data: ${result.result}");
      print("========================");
      
      setState(() {
        products = result.result;
        // No need for client-side filtering/sorting since backend handles it
        filteredProducts = result.result;
        totalCount = result.count ?? 0;
        totalPages = (totalCount / itemsPerPage).ceil();
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Error loading products: $e";
      });
      print("Error loading products: $e");
    }
  }

  
  
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 1; // Reset to first page when searching
    });
    
    // Debounce search to avoid too many API calls
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      _loadProducts(); // Reload from backend with new search
    });
  }
  
  void _onSortChanged(String field) {
    setState(() {
      if (sortField == field) {
        sortAscending = !sortAscending;
      } else {
        sortField = field;
        sortAscending = true;
      }
      currentPage = 1; // Reset to first page when sorting
    });
    _loadProducts(); // Reload from backend with new sort
  }
  
  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _loadProducts(); // Reload from backend with new page
  }

  void _onBrandChanged(int? brandId) {
    setState(() {
      selectedBrandId = brandId;
      currentPage = 1; // Reset to first page
    });
    _loadProducts();
  }

  void _onCategoryChanged(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      currentPage = 1; // Reset to first page
    });
    _loadProducts();
  }

  void _onPriceRangeChanged(double? min, double? max) {
    setState(() {
      minPrice = min;
      maxPrice = max;
      currentPage = 1; // Reset to first page
    });
    _loadProducts();
  }

  void _clearFilters() {
    setState(() {
      selectedBrandId = null;
      selectedCategoryId = null;
      minPrice = null;
      maxPrice = null;
      currentPage = 1;
    });
    _loadProducts();
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await _productProvider.delete(product.id!);
      _loadProducts(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog("Error deleting product: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Error"),
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

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Delete Product"),
        content: Text("Are you sure you want to delete '${product.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red))
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Products List",
      child: Container(
        margin: EdgeInsets.only(top: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Search and Filter Controls
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () => _onSearchChanged(''),
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Add Product Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductInsert(),
                            ),
                          );
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      // Filter Toggle Button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showFilters = !showFilters;
                          });
                        },
                        icon: Icon(showFilters ? Icons.filter_list_off : Icons.filter_list),
                        label: Text(showFilters ? 'Hide Filters' : 'Show Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showFilters ? Colors.orange : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      if (selectedBrandId != null || selectedCategoryId != null || minPrice != null || maxPrice != null)
                        ElevatedButton.icon(
                          onPressed: _clearFilters,
                          icon: Icon(Icons.clear),
                          label: Text('Clear Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Advanced Filters (Collapsible)
                  if (showFilters) ...[
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Advanced Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16),
                            
                            // Brand and Category Filters
                            Row(
                              children: [
                                // Brand Filter
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Brand:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8),
                                      DropdownButton<int>(
                                        value: selectedBrandId,
                                        hint: Text('All Brands'),
                                        isExpanded: true,
                                        items: [
                                          DropdownMenuItem<int>(value: null, child: Text('All Brands')),
                                          ...brands.map((brand) => 
                                            DropdownMenuItem<int>(
                                              value: brand.id,
                                              child: Text(brand.name ?? ''),
                                            )
                                          ),
                                        ],
                                        onChanged: _onBrandChanged,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                
                                // Category Filter
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8),
                                      DropdownButton<int>(
                                        value: selectedCategoryId,
                                        hint: Text('All Categories'),
                                        isExpanded: true,
                                        items: [
                                          DropdownMenuItem<int>(value: null, child: Text('All Categories')),
                                          ...categories.map((category) => 
                                            DropdownMenuItem<int>(
                                              value: category.id,
                                              child: Text(category.name ?? ''),
                                            )
                                          ),
                                        ],
                                        onChanged: _onCategoryChanged,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            // Price Range Filter
                            Text('Price Range:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Min Price',
                                      border: OutlineInputBorder(),
                                      prefixText: '\$',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      double? min = double.tryParse(value);
                                      _onPriceRangeChanged(min, maxPrice);
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Max Price',
                                      border: OutlineInputBorder(),
                                      prefixText: '\$',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      double? max = double.tryParse(value);
                                      _onPriceRangeChanged(minPrice, max);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Sort Controls
                  Row(
                    children: [
                      Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 16),
                      DropdownButton<String>(
                        value: sortField,
                        items: [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(value: 'price', child: Text('Price')),
                          DropdownMenuItem(value: 'code', child: Text('Code')),
                        ],
                        onChanged: (value) {
                          if (value != null) _onSortChanged(value);
                        },
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                        onPressed: () => _onSortChanged(sortField),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Pagination Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${filteredProducts.length} of $totalCount products',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text('Items per page:'),
                          SizedBox(width: 8),
                          DropdownButton<int>(
                            value: itemsPerPage,
                            items: [5, 10, 20, 50].map((count) => 
                              DropdownMenuItem(value: count, child: Text(count.toString()))
                            ).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  itemsPerPage = value;
                                  currentPage = 1;
                                });
                                _loadProducts(); // Reload with new page size
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Products Table
            Container(
              height: 400, // Fixed height for the table
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                errorMessage,
                                style: TextStyle(fontSize: 16, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProducts,
                                child: Text("Retry"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 247, 233, 211),
                                  foregroundColor: Color(0x0FF938f94),
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredProducts.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isNotEmpty ? "No products match your search" : "No products found",
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('name'),
                                  child: Row(
                                    children: [
                                      Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'name')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('code'),
                                  child: Row(
                                    children: [
                                      Text("Code", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'code')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('price'),
                                  child: Row(
                                    children: [
                                      Text("Price", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'price')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(label: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Brand ID", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Category ID", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredProducts.map((product) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(product.name ?? "")),
                                  DataCell(Text(product.code ?? "")),
                                  DataCell(Text(product.price?.toString() ?? "")),
                                  DataCell(Text(product.description ?? "")),
                                  DataCell(Text(product.brandId?.toString() ?? "")),
                                  DataCell(Text(product.categoryId?.toString() ?? "")),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(product),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
            ),
            
            // Pagination Controls
            if (totalPages > 1)
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.first_page),
                      onPressed: currentPage > 1 ? () => _onPageChanged(1) : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: currentPage > 1 ? () => _onPageChanged(currentPage - 1) : null,
                    ),
                    ...List.generate(
                      totalPages.clamp(0, 5), // Show max 5 page numbers
                      (index) {
                        int pageNumber;
                        if (totalPages <= 5) {
                          pageNumber = index + 1;
                        } else {
                          // Show pages around current page
                          int startPage = (currentPage - 2).clamp(1, totalPages - 4);
                          pageNumber = startPage + index;
                        }
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => _onPageChanged(pageNumber),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentPage == pageNumber 
                                  ? Color.fromARGB(255, 247, 233, 211)
                                  : Colors.grey[300],
                              foregroundColor: currentPage == pageNumber 
                                  ? Color(0x0FF938f94)
                                  : Colors.black,
                            ),
                            child: Text(pageNumber.toString()),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: currentPage < totalPages ? () => _onPageChanged(currentPage + 1) : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.last_page),
                      onPressed: currentPage < totalPages ? () => _onPageChanged(totalPages) : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}
