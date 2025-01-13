import 'package:ehairdressers_mobile/providers/appointment_provider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppointmentTimeScreen extends StatefulWidget {
  final DateTime date;
  AppointmentTimeScreen({required this.date});

  @override
  State<AppointmentTimeScreen> createState() => _AppointmentTimeScreenState();
}

class _AppointmentTimeScreenState extends State<AppointmentTimeScreen> {
  String defaultImagePath = '.dart_tool/assets/logo.png';
  late AppointmentProvider _appointmentProvider;
  List<TimeOfDay>? availableTimes = [];

  @override
  void initState() {
    super.initState();
    _appointmentProvider = context.read<AppointmentProvider>();
    loadData();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future loadData() async {
    availableTimes = await _appointmentProvider
        .getTime(widget.date.toLocal().toString().split(' ')[0]);

    print('hhhhh${availableTimes}');

    setState(() {});
  }

  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Appointment time",
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: ListView.builder(
                  itemCount: availableTimes?.length,
                  itemBuilder: (context, index) {
                    final time = availableTimes![index];
                    return ListTile(
                      title: Text('${time.format(context)}',
                          style: TextStyle(color: Color(0x0FFe5c89d))),
                      trailing: ElevatedButton(
                        onPressed: () {
                          print('Button pressed for ${time.format(context)}');
                        },
                        child: Text('Book'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 247, 233, 211),
                            foregroundColor: Color(0x0FF938f94)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<TimeOfDay>> _fetchAvailableAppointments() async {
    return await AppointmentProvider()
        .getTime(DateTime.now().toLocal().toString().split(' ')[0]);
  }
}
