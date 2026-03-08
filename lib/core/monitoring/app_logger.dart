import 'package:flutter/foundation.dart';

class AppLogEvent {
  const AppLogEvent({
    required this.feature,
    required this.message,
    this.level = 'INFO',
    this.error,
    this.stackTrace,
    this.data,
  });

  final String feature;
  final String message;
  final String level;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, Object?>? data;

  @override
  String toString() {
    final payload = <String, Object?>{
      'level': level,
      'feature': feature,
      'message': message,
      if (data != null) 'data': data,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
    return payload.toString();
  }
}

@immutable
class AppLogger {
  const AppLogger();

  void info(String feature, String message, {Map<String, Object?>? data}) {
    _print(AppLogEvent(feature: feature, message: message, data: data));
  }

  void warn(
    String feature,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    _print(
      AppLogEvent(
        feature: feature,
        message: message,
        level: 'WARN',
        error: error,
        stackTrace: stackTrace,
        data: data,
      ),
    );
  }

  void error(
    String feature,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    _print(
      AppLogEvent(
        feature: feature,
        message: message,
        level: 'ERROR',
        error: error,
        stackTrace: stackTrace,
        data: data,
      ),
    );
  }

  void _print(AppLogEvent event) {
    if (kDebugMode) {
      debugPrint(event.toString());
    }
  }
}
