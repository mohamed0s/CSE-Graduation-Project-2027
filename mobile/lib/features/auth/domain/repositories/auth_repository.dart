import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, List<AuthEntity>>> getAuths();
  Future<Either<Failure, AuthEntity>> getAuthById(String id);
}
