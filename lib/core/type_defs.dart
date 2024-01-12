import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
