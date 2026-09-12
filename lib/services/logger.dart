import 'package:logger/logger.dart';

/// Shared app-wide logger instance.
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 8,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
