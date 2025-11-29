import 'dart:async';
import 'package:flutter/material.dart';

/// Debouncer genérico com Timer cancelável
/// 
/// Implementação robusta que substitui lógica manual com Timer
/// Cancela timers anteriores automaticamente
/// 
/// Uso:
/// ```dart
/// final _debouncer = Debouncer(milliseconds: 300);
/// 
/// // Em onChanged:
/// _debouncer.run(() {
///   // Ação debounced (ex: busca API)
///   _performSearch(query);
/// });
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Executa ação após delay
  /// 
  /// Cancela timer anterior se existir
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancela timer pendente
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose (chame no dispose do StatefulWidget)
  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler - executa ação no máximo 1x por intervalo
/// 
/// Diferente do debouncer: executa IMEDIATAMENTE e bloqueia por X ms
/// Útil para eventos de scroll, drag, etc
/// 
/// Uso:
/// ```dart
/// final _throttler = Throttler(milliseconds: 100);
/// 
/// // Em onScroll:
/// _throttler.run(() {
///   // Ação throttled
///   _updateVisibleMarkers();
/// });
/// ```
class Throttler {
  final int milliseconds;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({required this.milliseconds});

  /// Executa ação se não estiver throttled
  void run(VoidCallback action) {
    if (_isThrottled) return;

    action();
    _isThrottled = true;

    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _isThrottled = false;
    });
  }

  /// Cancela throttle e permite execução imediata
  void reset() {
    _timer?.cancel();
    _isThrottled = false;
  }

  /// Dispose
  void dispose() {
    _timer?.cancel();
  }
}

/// ValueNotifierDebouncer - debouncer especializado para ValueNotifier
/// 
/// Útil para sincronizar UI com estado debounced
/// 
/// Exemplo:
/// ```dart
/// final searchDebouncer = ValueNotifierDebouncer<String>(
///   milliseconds: 300,
///   onValue: (query) => _performSearch(query),
/// );
/// 
/// // Listener
/// searchDebouncer.addListener(() {
///   print('Searching: ${searchDebouncer.value}');
/// });
/// 
/// // Trigger
/// searchDebouncer.value = 'flutter';
/// ```
class ValueNotifierDebouncer<T> extends ValueNotifier<T?> {
  final int milliseconds;
  final ValueChanged<T> onValue;
  Timer? _timer;

  ValueNotifierDebouncer({
    required this.milliseconds,
    required this.onValue,
  }) : super(null);

  @override
  set value(T? newValue) {
    super.value = newValue;
    
    _timer?.cancel();
    if (newValue != null) {
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        onValue(newValue);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
