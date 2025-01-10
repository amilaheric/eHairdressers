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
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  Appointment? _appointment;

  late AppointmentProvider _appointmentProvider;
  SearchResult<Appointment>? _searchResult;

  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    _appointmentProvider = context.read<AppointmentProvider>();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = DateFormat('dd/MM/yyyy').format(args.value);
        fetchAppointmentData(_selectedDate);
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  Future<void> fetchAppointmentData(String selectedDate) async {
    setState(() {
      isLoading = true;
    });
    try {
      var filter = {'AppointmentDate': selectedDate};
      _searchResult = await _appointmentProvider.get(filter: filter);
      if (_searchResult?.result != null) {
        for (var item in _searchResult!.result!) {
          print(item.appointmentId);
        }
      }
    } catch (e) {
      print('Error fetching appointment data: $e');
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
                    controller: TextEditingController(text: _selectedDate),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Username"),
                    controller: TextEditingController(
                        text: _searchResult?.result?.firstOrNull?.userId
                                .toString() ??
                            ''),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Employee"),
                    controller: TextEditingController(
                        text: _searchResult?.result?.firstOrNull?.employeeName
                                .toString() ??
                            ''),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Service type"),
                    controller: TextEditingController(
                        text: _searchResult?.result?.firstOrNull?.serviceId
                                .toString() ??
                            ''),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  IconButton(
                    onPressed: () {
                      var appointment =
                          _searchResult?.result?.firstOrNull?.appointmentId;
                      _deleteAppointment(appointment!);
                    },
                    color: Color(0x0FF938f94),
                    iconSize: 30,
                    icon: Icon(
                      Icons.delete_forever_rounded,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: "Comment"),
                    controller: TextEditingController(
                        text: _searchResult?.result?.firstOrNull?.comment
                                .toString() ??
                            ''),
                    readOnly: true,
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
                  Expanded(
                    child: SfDateRangePicker(
                      onSelectionChanged: _onSelectionChanged,
                      selectionMode: DateRangePickerSelectionMode.single,
                      initialSelectedRange: PickerDateRange(
                        DateTime.now().subtract(const Duration(days: 4)),
                        DateTime.now().add(const Duration(days: 3)),
                      ),
                    ),
                  ),
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
