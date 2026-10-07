import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String id;
  final String name;

  const AuthEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
