// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      (json['ServiceId'] as num?)?.toInt(),
      json['ServiceName'] as String?,
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'ServiceId': instance.serviceId,
      'ServiceName': instance.serviceName,
    };
