import 'dart:async';
import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/providers/AppointmentProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReservationList extends StatefulWidget {
  const ReservationList({Key? key}) : super(key: key);

  @override
  State<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  late AppointmentProvider _appointmentProvider;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<Appointment> appointments = [];
  List<Appointment> filteredAppointments = [];
  
  // Pagination
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalCount = 0;
  int totalPages = 0;
  
  // Filtering
  String searchQuery = '';
  String? minDate;
  String? maxDate;
  int? selectedEmployeeId;
  int? selectedServiceId;
  
  // Filter state
  bool showFilters = false;
  
  // Sorting
  String sortField = 'appointmentDate';
  bool sortAscending = true;
  
  // Search debounce
  Timer? _searchTimer;

  // Scroll controllers so the table can show visible, draggable scrollbars
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appointmentProvider = context.read<AppointmentProvider>();
    _loadAppointments();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
      
      print("=== LOADING APPOINTMENTS ===");
      print("Page: $currentPage, PageSize: $itemsPerPage, Search: $searchQuery");
      print("SortBy: $sortField, SortOrder: ${sortAscending ? 'asc' : 'desc'}");
      print("Date range: $minDate - $maxDate");
      
      // Load all appointments (filtering applied client-side)
      SearchResult<Appointment> result = await _appointmentProvider.get(filter: null);
      
      print("Appointments result: $result");
      print("Appointments count: ${result.result.length}");
      print("Total count from backend: ${result.count}");
      print("========================");
      
      setState(() {
        appointments = result.result;
        
        // Apply client-side filtering, sorting, and pagination
        List<Appointment> allFiltered = _getFilteredAndSortedAppointments();
        totalCount = allFiltered.length;
        totalPages = (totalCount / itemsPerPage).ceil();
        
        // Apply pagination to filtered list
        int startIndex = (currentPage - 1) * itemsPerPage;
        int endIndex = startIndex + itemsPerPage;
        filteredAppointments = allFiltered.sublist(
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
        errorMessage = "Error loading appointments: $e";
      });
      print("Error loading appointments: $e");
    }
  }

  List<Appointment> _getFilteredAndSortedAppointments() {
    List<Appointment> filtered = List.from(appointments);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((apt) {
        final query = searchQuery.toLowerCase();
        final employeeName = (apt.employeeName ?? '').toLowerCase();
        final username = (apt.username ?? '').toLowerCase();
        final serviceName = (apt.serviceName ?? '').toLowerCase();
        final comment = (apt.comment ?? '').toLowerCase();
        return employeeName.contains(query) || 
               username.contains(query) || 
               serviceName.contains(query) ||
               comment.contains(query);
      }).toList();
    }
    
    // Apply date range filter
    if ((minDate != null && minDate!.isNotEmpty) || 
        (maxDate != null && maxDate!.isNotEmpty)) {
      filtered = filtered.where((apt) {
        if (apt.appointmentDate == null || apt.appointmentDate!.isEmpty) return false;
        final aptDate = apt.appointmentDate!;
        if (minDate != null && minDate!.isNotEmpty && aptDate.compareTo(minDate!) < 0) return false;
        if (maxDate != null && maxDate!.isNotEmpty && aptDate.compareTo(maxDate!) > 0) return false;
        return true;
      }).toList();
    }
    
    // Apply employee filter
    if (selectedEmployeeId != null) {
      filtered = filtered.where((apt) => apt.employeeId == selectedEmployeeId).toList();
    }
    
    // Apply service filter
    if (selectedServiceId != null) {
      filtered = filtered.where((apt) => apt.serviceId == selectedServiceId).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int compareResult = 0;
      switch (sortField) {
        case 'appointmentDate':
          compareResult = _compareAppointmentDates(a.appointmentDate, b.appointmentDate);
          if (compareResult == 0) {
            // If dates are same, sort by time
            compareResult = _compareAppointmentTimes(a.appointmentTime, b.appointmentTime);
          }
          break;
        case 'appointmentTime':
          compareResult = _compareAppointmentTimes(a.appointmentTime, b.appointmentTime);
          break;
        case 'employeeName':
          compareResult = (a.employeeName ?? '').compareTo(b.employeeName ?? '');
          break;
        case 'serviceName':
          compareResult = (a.serviceName ?? '').compareTo(b.serviceName ?? '');
          break;
        case 'username':
          compareResult = (a.username ?? '').compareTo(b.username ?? '');
          break;
        default:
          compareResult = 0;
      }
      return sortAscending ? compareResult : -compareResult;
    });
    
    return filtered;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }
    
    // Extract only the date part (strip time, timezone, etc.)
    String dateOnly = dateString.trim();
    if (dateOnly.contains('T')) {
      dateOnly = dateOnly.split('T')[0];
    } else if (dateOnly.contains(' ')) {
      dateOnly = dateOnly.split(' ')[0];
    }
    
    try {
      // Try ISO format first (yyyy-MM-dd)
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateOnly));
    } catch (_) {
      // Try MM/dd/yyyy (e.g. "07/22/2025" from API)
      try {
        final date = DateFormat('MM/dd/yyyy').parse(dateOnly);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {
        // Try to reorder yyyy-MM-dd or return as-is
        final parts = dateOnly.split('-');
        if (parts.length == 3 && parts[0].length == 4) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
        return dateOnly;
      }
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '';
    }
    
    try {
      // Handle full ISO datetime (e.g. "2024-01-15T10:30:00")
      if (timeString.contains('T')) {
        DateTime dt = DateTime.parse(timeString);
        return DateFormat('HH:mm').format(dt);
      }
      // Handle time-only strings (e.g. "10:30" or "10:30:00")
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  // Parses an appointment date string into an actual DateTime so it can be
  // sorted chronologically. The API isn't guaranteed to always return ISO
  // (yyyy-MM-dd) - it has been observed sending culture-formatted strings
  // like "MM/dd/yyyy" - and comparing those as raw strings sorts wrong
  // whenever appointments span a year boundary (e.g. "01/05/2026" would
  // sort before "12/20/2025" as text, even though it's chronologically
  // later). Parsing to a real DateTime avoids that regardless of format.
  DateTime? _parseAppointmentDateValue(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    String dateOnly = dateString.trim();
    if (dateOnly.contains('T')) {
      dateOnly = dateOnly.split('T')[0];
    } else if (dateOnly.contains(' ')) {
      dateOnly = dateOnly.split(' ')[0];
    }

    final iso = DateTime.tryParse(dateOnly);
    if (iso != null) {
      return iso;
    }

    try {
      return DateFormat('MM/dd/yyyy').parse(dateOnly);
    } catch (_) {
      return null;
    }
  }

  // Converts an appointment time string into minutes-since-midnight for a
  // reliable chronological comparison, regardless of exact source format.
  int? _parseAppointmentTimeValue(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null;
    }

    try {
      if (timeString.contains('T')) {
        final dt = DateTime.parse(timeString);
        return dt.hour * 60 + dt.minute;
      }
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          return h * 60 + m;
        }
      }
    } catch (_) {}
    return null;
  }

  int _compareAppointmentDates(String? a, String? b) {
    final dateA = _parseAppointmentDateValue(a);
    final dateB = _parseAppointmentDateValue(b);
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return -1;
    if (dateB == null) return 1;
    return dateA.compareTo(dateB);
  }

  int _compareAppointmentTimes(String? a, String? b) {
    final timeA = _parseAppointmentTimeValue(a);
    final timeB = _parseAppointmentTimeValue(b);
    if (timeA == null && timeB == null) {
      // Fall back to a plain string compare if neither parses.
      return (a ?? '').compareTo(b ?? '');
    }
    if (timeA == null) return -1;
    if (timeB == null) return 1;
    return timeA.compareTo(timeB);
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 1;
    });
    
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      _loadAppointments();
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
      currentPage = 1;
    });
    _loadAppointments();
  }
  
  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _loadAppointments();
  }

  void _onDateRangeChanged(String? min, String? max) {
    setState(() {
      minDate = min;
      maxDate = max;
      currentPage = 1;
    });
    _loadAppointments();
  }

  void _onEmployeeFilterChanged(int? employeeId) {
    setState(() {
      selectedEmployeeId = employeeId;
      currentPage = 1;
    });
    _loadAppointments();
  }

  void _onServiceFilterChanged(int? serviceId) {
    setState(() {
      selectedServiceId = serviceId;
      currentPage = 1;
    });
    _loadAppointments();
  }

  void _clearFilters() {
    setState(() {
      minDate = null;
      maxDate = null;
      selectedEmployeeId = null;
      selectedServiceId = null;
      currentPage = 1;
    });
    _loadAppointments();
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    try {
      if (appointment.appointmentId != null) {
        await _appointmentProvider.delete(appointment.appointmentId!);
        _loadAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog("Error deleting appointment: $e");
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

  void _showDeleteConfirmation(Appointment appointment) {
    String appointmentInfo = '${appointment.employeeName ?? "Unknown"} - ${appointment.appointmentTime ?? "No time"}';
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Delete Appointment"),
        content: Text("Are you sure you want to delete appointment '$appointmentInfo'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointment);
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
      title: "Reservations",
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
                      hintText: 'Search appointments by employee, user, service ...',
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
                      if (minDate != null || maxDate != null || 
                          selectedEmployeeId != null || selectedServiceId != null)
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
                            
                            // Date Range Filter
                            Text('Date Range:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Min Date (YYYY-MM-DD)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onChanged: (value) {
                                      _onDateRangeChanged(value.isNotEmpty ? value : null, maxDate);
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Max Date (YYYY-MM-DD)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onChanged: (value) {
                                      _onDateRangeChanged(minDate, value.isNotEmpty ? value : null);
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
                          DropdownMenuItem(value: 'appointmentDate', child: Text('Date')),
                          DropdownMenuItem(value: 'appointmentTime', child: Text('Time')),
                          DropdownMenuItem(value: 'employeeName', child: Text('Employee')),
                          DropdownMenuItem(value: 'serviceName', child: Text('Service')),
                          DropdownMenuItem(value: 'username', child: Text('User')),
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
                        'Showing ${filteredAppointments.length} of $totalCount appointments',
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
                                _loadAppointments();
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
            
            // Appointments Table
            Container(
              height: 400,
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
                                onPressed: _loadAppointments,
                                child: Text("Retry"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 247, 233, 211),
                                  foregroundColor: Color(0x0FF938f94),
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredAppointments.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isNotEmpty || minDate != null || maxDate != null 
                                    ? "No appointments match your search" 
                                    : "No appointments found",
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility: true,
                          notificationPredicate: (notification) => notification.depth == 1,
                          child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('appointmentDate'),
                                  child: Row(
                                    children: [
                                      Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'appointmentDate')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('appointmentTime'),
                                  child: Row(
                                    children: [
                                      Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'appointmentTime')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('employeeName'),
                                  child: Row(
                                    children: [
                                      Text("Employee", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'employeeName')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('username'),
                                  child: Row(
                                    children: [
                                      Text("User", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'username')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: GestureDetector(
                                  onTap: () => _onSortChanged('serviceName'),
                                  child: Row(
                                    children: [
                                      Text("Service", style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (sortField == 'serviceName')
                                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredAppointments.map((appointment) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(_formatDate(appointment.appointmentDate))),
                                  DataCell(Text(_formatTime(appointment.appointmentTime))),
                                  DataCell(Text(appointment.employeeName ?? "")),
                                  DataCell(Text(appointment.username ?? "")),
                                  DataCell(Text(appointment.serviceName ?? "")),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(appointment),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        ),
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
                      totalPages.clamp(0, 5),
                      (index) {
                        int pageNumber;
                        if (totalPages <= 5) {
                          pageNumber = index + 1;
                        } else {
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
