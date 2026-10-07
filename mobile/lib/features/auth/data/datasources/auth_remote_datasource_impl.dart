import 'package:mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/auth/data/models/auth_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<List<AuthModel>> getAuths() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthModel> getAuthById(String id) async {
    throw UnimplementedError();
  }
}
