

import 'package:ehairdressers_mobile/models/appointment.dart';
import 'base_provider.dart';

class AppointmentProvider extends BaseProvider<Appointment> {
  AppointmentProvider() : super("Appointment");

  @override
  Appointment fromJson(data) {
    // TODO: implement fromJson
    return Appointment.fromJson(data);
  }
}