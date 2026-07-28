import '../models/employees.dart';
import 'base_provider.dart';

class EmployeesProvider extends BaseProvider<Employees> {
  EmployeesProvider() : super("Employee");

  @override
  Employees fromJson(data) {
    return Employees.fromJson(data);
  }
}
