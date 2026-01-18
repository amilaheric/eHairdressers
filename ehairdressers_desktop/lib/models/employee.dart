import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  @JsonKey(name: 'EmployeeId')
  int? employeeId;
  @JsonKey(name: 'UserId')
  int? userId;
  @JsonKey(name: 'Name')
  String? name;
  @JsonKey(name: 'Surname')
  String? surname;
  @JsonKey(name: 'HireDate')
  String? hireDate;
  @JsonKey(name: 'BirthDate')
  String? birthDate;
  @JsonKey(name: 'Address')
  String? address;
  @JsonKey(name: 'CitizenshipNumber')
  String? citizenshipNumber;
  @JsonKey(name: 'Phone')
  String? phone;
  @JsonKey(name: 'Salary')
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
