import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  @JsonKey(name: 'ServiceId')
  int? serviceId;

  @JsonKey(name: 'ServiceName')
  String? serviceName;
  Service(this.serviceId, this.serviceName);

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
