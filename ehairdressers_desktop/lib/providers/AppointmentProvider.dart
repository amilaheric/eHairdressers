import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/providers/BaseProvider.dart';

class AppointmentProvider extends BaseProvider<Appointment> {
  AppointmentProvider() : super("Appointment");

  @override
  Appointment fromJson(data) {
    return Appointment.fromJson(data);
  }
}
