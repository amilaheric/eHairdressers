import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  int? employeeId;
  int? userId;
  String? name;
  String? surname;
  String? hireDate;
  String? birthDate;
  String? address;
  String? citizenshipNumber;
  String? phone;
  int? salary;

  Employee({
    this.employeeId,
    this.userId,
    this.name,
    this.surname,
    this.hireDate,
    this.birthDate,
    this.address,
    this.citizenshipNumber,
    this.phone,
    this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  // Method to create employee with default employee role
  static Employee createWithEmployeeRole({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required String username,
    required String citizenshipNumber,
    String? birthDate,
    String? address,
    String? hireDate,
    int? salary,
  }) {
    return Employee(
      name: name,
      surname: surname,
      phone: phone,
      citizenshipNumber: citizenshipNumber,
      birthDate: birthDate,
      address: address,
      hireDate: hireDate ?? DateTime.now().toIso8601String(),
      salary: salary ?? 0,
    );
  }
}
