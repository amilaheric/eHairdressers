import '../models/service.dart';
import 'base_provider.dart';

class ServiceProvider extends BaseProvider<Service> {
  ServiceProvider() : super("Service");

  @override
  Service fromJson(data) {
    return Service.fromJson(data);
  }
}
