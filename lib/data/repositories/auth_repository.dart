import '../datasources/mock_api_datasource.dart';
import '../models/app_user.dart';
import '../models/requests.dart';

abstract interface class AuthRepository {
  Future<AppUser> register(RegisterRequest request);
  Future<List> getCountries();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);
  final MockApiDataSource _api;

  @override
  Future<AppUser> register(RegisterRequest request) => _api.register(request);

  @override
  Future<List> getCountries() => _api.getCountries();
}
