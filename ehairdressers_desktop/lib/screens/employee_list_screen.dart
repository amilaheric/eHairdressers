import 'dart:async';
import 'package:ehairdressers_mobile/models/employee.dart';
import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/providers/EmployeeProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/screens/employee_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late EmployeeProvider _employeeProvider;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  
  // Pagination
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalCount = 0;
  int totalPages = 0;
  
  // Filtering
  String searchQuery = '';
  int? minSalary;
  int? maxSalary;
  String? minHireDate;
  String? maxHireDate;
  
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
    _employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _employeeProvider = context.read<EmployeeProvider>();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
      
      print("=== LOADING EMPLOYEES ===");
      print("Page: $currentPage, PageSize: $itemsPerPage, Search: $searchQuery");
      print("SortBy: $sortField, SortOrder: ${sortAscending ? 'asc' : 'desc'}");
      print("Salary range: $minSalary - $maxSalary");
      print("Hire date range: $minHireDate - $maxHireDate");
      
      // Load all employees without query parameters (backend doesn't support them yet)
      // Apply client-side filtering, sorting, and pagination
      print("Loading all employees (client-side filtering will be applied)...");
      
      SearchResult<Employee> result = await _employeeProvider.get(filter: null);
      
      print("Employees result: $result");
      print("Employees count: ${result.result.length}");
      print("Employees data: ${result.result}");
      
      // Debug: Print detailed employee information
      for (var emp in result.result) {
        print("Employee details:");
        print("  EmployeeId: ${emp.employeeId}");
        print("  UserId: ${emp.userId}");
        print("  Name: ${emp.name}");
        print("  Surname: ${emp.surname}");
        print("  Phone: ${emp.phone}");
        print("  HireDate: ${emp.hireDate}");
        print("  BirthDate: ${emp.birthDate}");
        print("  Address: ${emp.address}");
        print("  CitizenshipNumber: ${emp.citizenshipNumber}");
        print("  Salary: ${emp.salary}");
      }
      print("========================");
      
      setState(() {
        employees = result.result;
        
        // Apply client-side filtering and sorting
        List<Employee> allFiltered = _getFilteredAndSortedEmployees();
        totalCount = allFiltered.length;
        totalPages = (totalCount / itemsPerPage).ceil();
        
        // Apply pagination to filtered list
        int startIndex = (currentPage - 1) * itemsPerPage;
        int endIndex = startIndex + itemsPerPage;
        filteredEmployees = allFiltered.sublist(
          startIndex.clamp(0, allFiltered.length),
          endIndex.clamp(0, allFiltered.length),
        );
        
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Error loading employees: $e";
      });
      print("Error loading employees: $e");
    }
  }

  List<Employee> _getFilteredAndSortedEmployees() {
    List<Employee> filtered = List.from(employees);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((emp) {
        final query = searchQuery.toLowerCase();
        final name = (emp.name ?? '').toLowerCase();
        final surname = (emp.surname ?? '').toLowerCase();
        final phone = (emp.phone ?? '').toLowerCase();
        return name.contains(query) || surname.contains(query) || phone.contains(query);
      }).toList();
    }
    
    // Apply salary filter
    if (minSalary != null || maxSalary != null) {
      filtered = filtered.where((emp) {
        final salary = emp.salary ?? 0;
        if (minSalary != null && salary < minSalary!) return false;
        if (maxSalary != null && salary > maxSalary!) return false;
        return true;
      }).toList();
    }
    
    // Apply hire date filter
    if ((minHireDate != null && minHireDate!.isNotEmpty) || 
        (maxHireDate != null && maxHireDate!.isNotEmpty)) {
      filtered = filtered.where((emp) {
        if (emp.hireDate == null || emp.hireDate!.isEmpty) return false;
        final hireDate = emp.hireDate!;
        if (minHireDate != null && minHireDate!.isNotEmpty && hireDate.compareTo(minHireDate!) < 0) return false;
        if (maxHireDate != null && maxHireDate!.isNotEmpty && hireDate.compareTo(maxHireDate!) > 0) return false;
        return true;
      }).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int compareResult = 0;
      switch (sortField) {
        case 'name':
          compareResult = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'surname':
          compareResult = (a.surname ?? '').compareTo(b.surname ?? '');
          break;
        case 'hireDate':
          compareResult = (a.hireDate ?? '').compareTo(b.hireDate ?? '');
          break;
        case 'salary':
          compareResult = (a.salary ?? 0).compareTo(b.salary ?? 0);
          break;
        default:
          compareResult = 0;
      }
      return sortAscending ? compareResult : -compareResult;
    });
    
    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 1; // Reset to first page when searching
    });
    
    // Debounce search to avoid too many API calls
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      _loadEmployees(); // Reload with new search
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
    _loadEmployees(); // Reload with new sort
  }
  
  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _loadEmployees(); // Reload with new page
  }

  void _onSalaryRangeChanged(int? min, int? max) {
    setState(() {
      minSalary = min;
      maxSalary = max;
      currentPage = 1; // Reset to first page
    });
    _loadEmployees();
  }

  void _onHireDateRangeChanged(String? min, String? max) {
    setState(() {
      minHireDate = min;
      maxHireDate = max;
      currentPage = 1; // Reset to first page
    });
    _loadEmployees();
  }

  void _clearFilters() {
    setState(() {
      minSalary = null;
      maxSalary = null;
      minHireDate = null;
      maxHireDate = null;
      currentPage = 1;
    });
    _loadEmployees();
  }

  Future<void> _deleteEmployee(Employee employee) async {
    try {
      if (employee.employeeId != null) {
        await _employeeProvider.delete(employee.employeeId!);
        _loadEmployees(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog("Error deleting employee: $e");
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }
    
    try {
      // Try to parse as ISO 8601 DateTime string (e.g., "2024-01-15T10:30:00" or "2024-01-15T10:30:00Z")
      DateTime date = DateTime.parse(dateString);
      // Format as readable date (e.g., "Jan 15, 2024" or "2024-01-15")
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      // If parsing fails, try to extract just the date part if it's in ISO format
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      // If it's already a date string, return as is
      return dateString;
    }
  }

  void _showDeleteConfirmation(Employee employee) {
    String employeeName = '${employee.name ?? ''} ${employee.surname ?? ''}'.trim();
    if (employeeName.isEmpty) {
      employeeName = 'this employee';
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Delete Employee"),
        content: Text("Are you sure you want to delete '$employeeName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEmployee(employee);
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
      title: "Employees List",
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
                      hintText: 'Search employees by name, surname, or phone...',
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
                      // Add Employee Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmployeeAdd(),
                            ),
                          ).then((_) {
                            // Refresh list when returning from add screen
                            _loadEmployees();
                          });
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add Employee'),
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
                      if (minSalary != null || maxSalary != null || 
                          (minHireDate != null && minHireDate!.isNotEmpty) || 
                          (maxHireDate != null && maxHireDate!.isNotEmpty))
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
                            
                            // Salary Range Filter
                            Text('Salary Range:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Min Salary',
                                      border: OutlineInputBorder(),
                                      prefixText: '\$',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      int? min = int.tryParse(value);
                                      _onSalaryRangeChanged(min, maxSalary);
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Max Salary',
                                      border: OutlineInputBorder(),
                                      prefixText: '\$',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      int? max = int.tryParse(value);
                                      _onSalaryRangeChanged(minSalary, max);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            // Hire Date Range Filter
                            Text('Hire Date Range:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Min Hire Date (YYYY-MM-DD)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onChanged: (value) {
                                      _onHireDateRangeChanged(value.isNotEmpty ? value : null, maxHireDate);
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Max Hire Date (YYYY-MM-DD)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onChanged: (value) {
                                      _onHireDateRangeChanged(minHireDate, value.isNotEmpty ? value : null);
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
                          DropdownMenuItem(value: 'surname', child: Text('Surname')),
                          DropdownMenuItem(value: 'hireDate', child: Text('Hire Date')),
                          DropdownMenuItem(value: 'salary', child: Text('Salary')),
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
                        'Showing ${filteredEmployees.length} of $totalCount employees',
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
                                _loadEmployees(); // Reload with new page size
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
            
            // Employees Table
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
                                onPressed: _loadEmployees,
                                child: Text("Retry"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 247, 233, 211),
                                  foregroundColor: Color(0x0FF938f94),
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredEmployees.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isNotEmpty ? "No employees match your search" : "No employees found",
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
                                  onTap: () => _onSortChanged('surname'),
                                  child: Row(
                                    children: [
                                      Text("Surname", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'surname')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('hireDate'),
                                  child: Row(
                                    children: [
                                      Text("Hire Date", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'hireDate')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text("Birth Date", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text("Citizenship Number", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('salary'),
                                  child: Row(
                                    children: [
                                      Text("Salary", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'salary')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredEmployees.map((employee) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(employee.name ?? "")),
                                  DataCell(Text(employee.surname ?? "")),
                                  DataCell(Text(employee.phone ?? "")),
                                  DataCell(Text(_formatDate(employee.hireDate))),
                                  DataCell(Text(_formatDate(employee.birthDate))),
                                  DataCell(Text(employee.address ?? "")),
                                  DataCell(Text(employee.citizenshipNumber ?? "")),
                                  DataCell(Text(employee.salary?.toString() ?? "")),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(employee),
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
