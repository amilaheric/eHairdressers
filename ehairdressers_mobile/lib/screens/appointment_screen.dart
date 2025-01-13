import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:ehairdressers_mobile/models/service.dart';
import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/providers/service_provider.dart';
import 'package:ehairdressers_mobile/providers/user_provider.dart';
import 'package:ehairdressers_mobile/screens/appointment_time_screen.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  bool isLoading = true;
  String defaultImagePath = '.dart_tool/assets/logo.png';
  late ServiceProvider _serviceProvider;
  late UserProvider _userProvider;
  SearchResult<Service>? serviceResult;
  SearchResult<User>? userResult;
  @override
  void initState() {
    super.initState();
    _initialValue = {};
    _serviceProvider = context.read<ServiceProvider>();
    _userProvider = context.read<UserProvider>();

    loadData();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future loadData() async {
    serviceResult = await _serviceProvider.getResult();
    userResult = await _userProvider.getResult();
    print('hhhhh${serviceResult}');
    if (serviceResult?.result != null) {
      for (var item in serviceResult!.result!) {
        print(item.ServiceName);
      }
    }
    if (userResult?.result != null) {
      for (var item in userResult!.result!) {
        print(item.username);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Appointment",
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              isLoading ? Container() : _buildForm(),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      var formData = _formKey.currentState!.value;

                      var request = new Map.from(_formKey.currentState!.value);
                      DateTime date = formData['date'];
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AppointmentTimeScreen(
                                date: date,
                              )));
                      print(formData);
                      print(request);
                    }
                  },
                  child: Text('Check time'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 247, 233, 211),
                      foregroundColor: Color(0x0FF938f94))),
            ],
          ),
        ),
      ),
    );
  }

  FormBuilder _buildForm() {
    print("Service Result: $serviceResult");
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: 600,
                child: Image.asset(defaultImagePath),
              ),
              FormBuilderDateTimePicker(
                name: 'date',
                decoration: InputDecoration(
                  labelText: 'Select Date',
                ),
                inputType: InputType.date,
                format: DateFormat('dd/MM/yyyy'),
                enabled: true,
              ),
              SizedBox(height: 10),
              FormBuilderDropdown<String>(
                name: 'userid',
                decoration: InputDecoration(
                  labelText: 'Select Employee',
                ),
                items: userResult?.result
                        ?.map((item) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: item.userid.toString(),
                              child: Text(item.name ?? "Nema "),
                            ))
                        .toList() ??
                    [],
              ),
            ],
          )),
    );
  }
}
