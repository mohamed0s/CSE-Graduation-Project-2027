import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<List<AuthModel>> getAuths();
  Future<AuthModel> getAuthById(String id);
}
