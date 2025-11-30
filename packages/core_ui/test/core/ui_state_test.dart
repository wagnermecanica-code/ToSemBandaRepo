import 'package:core_ui/core/ui_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UIState', () {
    group('Constructors', () {
      test('initial creates Initial state', () {
        final state = UIState<int>.initial();
        expect(state, isA<Initial<int>>());
        expect(state.isInitial, isTrue);
      });

      test('loading creates Loading state', () {
        final state = UIState<String>.loading();
        expect(state, isA<Loading<String>>());
        expect(state.isLoading, isTrue);
      });

      test('success creates Success state with data', () {
        final state = UIState<List<int>>.success([1, 2, 3]);
        expect(state, isA<Success<List<int>>>());
        expect(state.isSuccess, isTrue);
      });

      test('error creates Error state with message', () {
        final state = UIState<bool>.error('Something went wrong');
        expect(state, isA<Error<bool>>());
        expect(state.isError, isTrue);
      });
    });

    group('Extension Methods', () {
      test('isInitial returns true only for Initial', () {
        expect(UIState<int>.initial().isInitial, isTrue);
        expect(UIState<int>.loading().isInitial, isFalse);
        expect(UIState<int>.success(42).isInitial, isFalse);
        expect(UIState<int>.error('error').isInitial, isFalse);
      });

      test('isLoading returns true only for Loading', () {
        expect(UIState<int>.initial().isLoading, isFalse);
        expect(UIState<int>.loading().isLoading, isTrue);
        expect(UIState<int>.success(42).isLoading, isFalse);
        expect(UIState<int>.error('error').isLoading, isFalse);
      });

      test('isSuccess returns true only for Success', () {
        expect(UIState<int>.initial().isSuccess, isFalse);
        expect(UIState<int>.loading().isSuccess, isFalse);
        expect(UIState<int>.success(42).isSuccess, isTrue);
        expect(UIState<int>.error('error').isSuccess, isFalse);
      });

      test('isError returns true only for Error', () {
        expect(UIState<int>.initial().isError, isFalse);
        expect(UIState<int>.loading().isError, isFalse);
        expect(UIState<int>.success(42).isError, isFalse);
        expect(UIState<int>.error('error').isError, isTrue);
      });

      test('dataOrNull returns data for Success, null otherwise', () {
        expect(UIState<int>.initial().dataOrNull, isNull);
        expect(UIState<int>.loading().dataOrNull, isNull);
        expect(UIState<int>.success(42).dataOrNull, equals(42));
        expect(UIState<int>.error('error').dataOrNull, isNull);
      });

      test('errorOrNull returns error for Error, null otherwise', () {
        expect(UIState<int>.initial().errorOrNull, isNull);
        expect(UIState<int>.loading().errorOrNull, isNull);
        expect(UIState<int>.success(42).errorOrNull, isNull);
        expect(UIState<int>.error('error').errorOrNull, equals('error'));
      });
    });

    group('Pattern Matching', () {
      test('when handles all cases', () {
        final initial = UIState<int>.initial();
        final loading = UIState<int>.loading();
        final success = UIState<int>.success(42);
        final error = UIState<int>.error('error');

        expect(
          initial.when(
            initial: () => 'initial',
            loading: () => 'loading',
            success: (_) => 'success',
            error: (_) => 'error',
          ),
          equals('initial'),
        );

        expect(
          loading.when(
            initial: () => 'initial',
            loading: () => 'loading',
            success: (_) => 'success',
            error: (_) => 'error',
          ),
          equals('loading'),
        );

        expect(
          success.when(
            initial: () => 'initial',
            loading: () => 'loading',
            success: (data) => 'success: $data',
            error: (_) => 'error',
          ),
          equals('success: 42'),
        );

        expect(
          error.when(
            initial: () => 'initial',
            loading: () => 'loading',
            success: (_) => 'success',
            error: (msg) => 'error: $msg',
          ),
          equals('error: error'),
        );
      });

      test('maybeWhen provides orElse fallback', () {
        final state = UIState<int>.success(42);

        expect(
          state.maybeWhen(
            success: (data) => data * 2,
            orElse: () => 0,
          ),
          equals(84),
        );

        expect(
          state.maybeWhen(
            loading: () => -1,
            orElse: () => 0,
          ),
          equals(0),
        );
      });
    });

    group('Type Safety', () {
      test('UIState preserves generic type', () {
        final intState = UIState<int>.success(42);
        final stringState = UIState<String>.success('hello');
        final listState = UIState<List<int>>.success([1, 2, 3]);

        expect(intState.dataOrNull, isA<int>());
        expect(stringState.dataOrNull, isA<String>());
        expect(listState.dataOrNull, isA<List<int>>());
      });
    });
  });
}
