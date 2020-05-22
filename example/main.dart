import 'package:r_logger/r_logger.dart';

void main() {
  RLogger.initLogger();

  RLogger.instance.d('Hello World!');

  RLogger.instance.j('{"msg":"ok"}');

  RLogger.instance.e('your have a error', 'error object', StackTrace.current);
}
