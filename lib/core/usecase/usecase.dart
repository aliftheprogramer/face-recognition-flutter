// lib/core/usecase/usecase.dart

class NoParams {}

abstract class Usecase<T, Param> {
  Future<T> call({Param? param});
}
