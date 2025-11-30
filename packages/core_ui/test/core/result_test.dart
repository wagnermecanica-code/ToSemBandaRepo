import 'package:core_ui/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    group('Constructors', () {
      test('success creates Success result with value', () {
        final result = Result<int, String>.success(42);
        expect(result, isA<Success<int, String>>());
        expect(result.isSuccess, isTrue);
      });

      test('failure creates Failure result with error', () {
        final result = Result<int, String>.failure('Something went wrong');
        expect(result, isA<Failure<int, String>>());
        expect(result.isFailure, isTrue);
      });
    });

    group('Extension Methods', () {
      test('isSuccess returns true only for Success', () {
        expect(Result<int, String>.success(42).isSuccess, isTrue);
        expect(Result<int, String>.failure('error').isSuccess, isFalse);
      });

      test('isFailure returns true only for Failure', () {
        expect(Result<int, String>.success(42).isFailure, isFalse);
        expect(Result<int, String>.failure('error').isFailure, isTrue);
      });

      test('valueOrNull returns value for Success, null otherwise', () {
        expect(Result<int, String>.success(42).valueOrNull, equals(42));
        expect(Result<int, String>.failure('error').valueOrNull, isNull);
      });

      test('errorOrNull returns error for Failure, null otherwise', () {
        expect(Result<int, String>.success(42).errorOrNull, isNull);
        expect(
            Result<int, String>.failure('error').errorOrNull, equals('error'));
      });

      test('getOrThrow returns value for Success, throws for Failure', () {
        final success = Result<int, String>.success(42);
        final failure = Result<int, String>.failure('error');

        expect(success.getOrThrow(), equals(42));
        expect(() => failure.getOrThrow(), throwsA(equals('error')));
      });

      test('getOrElse returns value for Success, default for Failure', () {
        final success = Result<int, String>.success(42);
        final failure = Result<int, String>.failure('error');

        expect(success.getOrElse(() => 0), equals(42));
        expect(failure.getOrElse(() => 0), equals(0));
      });

      test('transform transforms success value', () {
        final result = Result<int, String>.success(42);
        final mapped = result.transform((value) => value * 2);

        expect(mapped.valueOrNull, equals(84));
      });

      test('transform preserves failure', () {
        final result = Result<int, String>.failure('error');
        final mapped = result.transform((value) => value * 2);

        expect(mapped.errorOrNull, equals('error'));
      });

      test('transformError transforms failure error', () {
        final result = Result<int, String>.failure('error');
        final mapped = result.transformError((error) => error.toUpperCase());

        expect(mapped.errorOrNull, equals('ERROR'));
      });

      test('transformError preserves success', () {
        final result = Result<int, String>.success(42);
        final mapped = result.transformError((error) => error.toUpperCase());

        expect(mapped.valueOrNull, equals(42));
      });

      test('flatMap chains operations for success', () {
        final result = Result<int, String>.success(42);
        final chained = result.flatMap(
          (value) => Result<String, String>.success('Value: $value'),
        );

        expect(chained.valueOrNull, equals('Value: 42'));
      });

      test('flatMap short-circuits on failure', () {
        final result = Result<int, String>.failure('error');
        final chained = result.flatMap(
          (value) => Result<String, String>.success('Value: $value'),
        );

        expect(chained.errorOrNull, equals('error'));
      });
    });

    group('Pattern Matching', () {
      test('when handles both cases', () {
        final success = Result<int, String>.success(42);
        final failure = Result<int, String>.failure('error');

        expect(
          success.when(
            success: (value) => 'success: $value',
            failure: (error) => 'failure: $error',
          ),
          equals('success: 42'),
        );

        expect(
          failure.when(
            success: (value) => 'success: $value',
            failure: (error) => 'failure: $error',
          ),
          equals('failure: error'),
        );
      });

      test('maybeWhen provides orElse fallback', () {
        final result = Result<int, String>.success(42);

        expect(
          result.maybeWhen(
            success: (value) => value * 2,
            orElse: () => 0,
          ),
          equals(84),
        );

        expect(
          result.maybeWhen(
            failure: (error) => -1,
            orElse: () => 0,
          ),
          equals(0),
        );
      });
    });

    group('Type Safety', () {
      test('Result preserves generic types', () {
        final intResult = Result<int, String>.success(42);
        final stringResult = Result<String, Exception>.success('hello');
        final listResult = Result<List<int>, String>.success([1, 2, 3]);

        expect(intResult.valueOrNull, isA<int>());
        expect(stringResult.valueOrNull, isA<String>());
        expect(listResult.valueOrNull, isA<List<int>>());
      });

      test('Result preserves error types', () {
        final stringError = Result<int, String>.failure('error');
        final exceptionError =
            Result<int, Exception>.failure(Exception('error'));

        expect(stringError.errorOrNull, isA<String>());
        expect(exceptionError.errorOrNull, isA<Exception>());
      });
    });

    group('Chaining Operations', () {
      test('multiple transform operations chain correctly', () {
        final result = Result<int, String>.success(5)
            .transform((v) => v * 2) // 10
            .transform((v) => v + 10) // 20
            .transform((v) => v.toString()); // "20"

        expect(result.valueOrNull, equals('20'));
      });

      test('flatMap chains multiple operations', () {
        Result<int, String> divide(int a, int b) {
          if (b == 0) return Result.failure('Division by zero');
          return Result.success(a ~/ b);
        }

        final result = Result<int, String>.success(100)
            .flatMap((v) => divide(v, 2)) // 50
            .flatMap((v) => divide(v, 5)); // 10

        expect(result.valueOrNull, equals(10));

        final failResult = Result<int, String>.success(100)
            .flatMap((v) => divide(v, 0)); // Fails here

        expect(failResult.errorOrNull, equals('Division by zero'));
      });
    });
  });
}
