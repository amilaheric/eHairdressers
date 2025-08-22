import 'package:ehairdressers_mobile/models/SearchResult.dart';
import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/providers/AppointmentProvider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ReservationList extends StatefulWidget {
  const ReservationList({Key? key}) : super(key: key);

  @override
  State<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  String _selectedDate = '';
  String _userId = '';
  String _comment = '';
  String _employeeId = '';
  String _serviceId = '';

  late TextEditingController _dateController;
  late TextEditingController _usernameController;
  late TextEditingController _employeeController;
  late TextEditingController _serviceTypeController;
  late TextEditingController _commentController;

  late AppointmentProvider _appointmentProvider;
  SearchResult<Appointment>? _searchResult;

  bool isLoading = false;
  
  int _currentPage = 1;
  int _appointmentsPerPage = 5;
  int _selectedAppointmentIndex = 0;

  @override
  void initState() {
    super.initState();

    _dateController = TextEditingController();
    _usernameController = TextEditingController();
    _employeeController = TextEditingController();
    _serviceTypeController = TextEditingController();
    _commentController = TextEditingController();

    _appointmentProvider = context.read<AppointmentProvider>();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _usernameController.dispose();
    _employeeController.dispose();
    _serviceTypeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        _selectedDate = DateFormat('M/d/yyyy').format(args.value);
        fetchAppointmentData(_selectedDate);
      }
    });
  }

  Future<void> fetchAppointmentData(String selectedDate) async {
    setState(() {
      isLoading = true;
      _currentPage = 1;
      _selectedAppointmentIndex = 0;
    });
    try {
      var filter = {'AppointmentDate': selectedDate};
      _searchResult = await _appointmentProvider.get(filter: filter);
      if (_searchResult?.result != null && _searchResult!.result!.isNotEmpty) {
        var appointment = _searchResult!.result!.first;
        
        
        setState(() {
          _userId = appointment.username?.toString() ?? appointment.userId?.toString() ?? '';
          _employeeId = appointment.employeeName?.toString() ?? '';
          _serviceId = appointment.serviceName?.toString() ?? appointment.serviceId?.toString() ?? '';
          _comment = appointment.comment?.toString() ?? '';
        });
        
    
        _dateController.text = _selectedDate;
        _usernameController.text = _userId;
        _employeeController.text = _employeeId;
        _serviceTypeController.text = _serviceId;
        _commentController.text = _comment;
        
        for (var item in _searchResult!.result!) {
          print('Appointment ID: ${item.appointmentId}, Employee: ${item.employeeName}, Time: ${item.appointmentTime}');
        }
      } else {
        setState(() {
          _userId = '';
          _employeeId = '';
          _serviceId = '';
          _comment = '';
        });
        _dateController.text = _selectedDate;
        _usernameController.text = '';
        _employeeController.text = '';
        _serviceTypeController.text = '';
        _commentController.text = '';
      }
    } catch (e) {
      
      setState(() {
        _userId = '';
        _employeeId = '';
        _serviceId = '';
        _comment = '';
      });
     
      _dateController.text = _selectedDate;
      _usernameController.text = '';
      _employeeController.text = '';
      _serviceTypeController.text = '';
      _commentController.text = '';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAppointment(int appointmentId) async {
    try {
      await _appointmentProvider.delete(appointmentId);
      fetchAppointmentData(_selectedDate);
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }
  
  void _selectAppointment(int index) {
    if (_searchResult?.result != null && index < _searchResult!.result!.length) {
      setState(() {
        _selectedAppointmentIndex = index;
      });
      
      var appointment = _searchResult!.result![index];
      setState(() {
        _userId = appointment.username?.toString() ?? appointment.userId?.toString() ?? '';
        _employeeId = appointment.employeeName?.toString() ?? '';
        _serviceId = appointment.serviceName?.toString() ?? appointment.serviceId?.toString() ?? '';
        _comment = appointment.comment?.toString() ?? '';
      });
      
      _dateController.text = _selectedDate;
      _usernameController.text = _userId;
      _employeeController.text = _employeeId;
      _serviceTypeController.text = _serviceId;
      _commentController.text = _comment;
    }
  }

  List<Appointment> get _paginatedAppointments {
    if (_searchResult?.result == null) return [];
    
    int startIndex = (_currentPage - 1) * _appointmentsPerPage;
    int endIndex = startIndex + _appointmentsPerPage;
    
    if (startIndex >= _searchResult!.result!.length) return [];
    
    return _searchResult!.result!.sublist(
      startIndex, 
      endIndex > _searchResult!.result!.length ? _searchResult!.result!.length : endIndex
    );
  }

  int get _totalPages {
    if (_searchResult?.result == null) return 0;
    return (_searchResult!.result!.length / _appointmentsPerPage).ceil();
  }

  Widget _setDate() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Date"),
                    controller: _dateController,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "User"),
                    controller: _usernameController,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Employee"),
                    controller: _employeeController,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Service"),
                    controller: _serviceTypeController,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Comment"),
                    controller: _commentController,
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  if (_searchResult?.result != null && _searchResult!.result!.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        var appointment = _searchResult?.result?[_selectedAppointmentIndex].appointmentId;
                        if (appointment != null) {
                          _deleteAppointment(appointment);
                        }
                      },
                      color: Color(0x0FF938f94),
                      iconSize: 30,
                      icon: Icon(Icons.delete_forever_rounded),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 300,
                    child: SfDateRangePicker(
                      onSelectionChanged: _onSelectionChanged,
                      selectionMode: DateRangePickerSelectionMode.single,
                      initialSelectedRange: PickerDateRange(
                        DateTime.now().subtract(const Duration(days: 4)),
                        DateTime.now().add(const Duration(days: 3)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_searchResult?.result != null && _searchResult!.result!.isNotEmpty) ...[
                    Text(
                      'Appointments for ${_selectedDate}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _paginatedAppointments.length,
                        itemBuilder: (context, index) {
                          var appointment = _paginatedAppointments[index];
                          var globalIndex = (_currentPage - 1) * _appointmentsPerPage + index;
                          bool isSelected = globalIndex == _selectedAppointmentIndex;
                          
                          return Card(
                            color: isSelected ? Colors.blue.shade100 : null,
                            child: ListTile(
                              title: Text('${appointment.employeeName ?? "Unknown"} - ${appointment.appointmentTime ?? "No time"}'),
                              subtitle: Text('ID: ${appointment.appointmentId} | User: ${appointment.userId} | Service: ${appointment.serviceId}'),
                              selected: isSelected,
                              onTap: () => _selectAppointment(globalIndex),
                            ),
                          );
                        },
                      ),
                    ),
              
                    if (_totalPages > 1) ...[
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 1 ? () {
                              setState(() {
                                _currentPage--;
                              });
                            } : null,
                            icon: Icon(Icons.chevron_left),
                          ),
                          Text('Page $_currentPage of $_totalPages'),
                          IconButton(
                            onPressed: _currentPage < _totalPages ? () {
                              setState(() {
                                _currentPage++;
                              });
                            } : null,
                            icon: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
        title: "Reservations",
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              SingleChildScrollView(child: Column(children: [_setDate()])),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ));
  }
}
