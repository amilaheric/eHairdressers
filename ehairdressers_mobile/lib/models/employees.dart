import 'package:json_annotation/json_annotation.dart';

part 'employees.g.dart';

@JsonSerializable()
class Employees {
  @JsonKey(name: 'EmployeeId')
  int? employeeId;

  @JsonKey(name: 'Name')
  String? firstName;

  @JsonKey(name: 'Surname')
  String? surname;

  Employees(this.employeeId, this.firstName, this.surname);

  // Getter to combine first name and surname
  String? get name => '${firstName ?? ''} ${surname ?? ''}'.trim();

  factory Employees.fromJson(Map<String, dynamic> json) =>
      _$EmployeesFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeesToJson(this);
}
