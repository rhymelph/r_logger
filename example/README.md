# r_logger_example

```dart
import 'package:r_logger/r_logger.dart';

void main(){
  RLogger.initLogger();

  RLogger.instance.d('Debug Hello World!');

  RLogger.instance.i('Info Hello World!');
  
  RLogger.instance.j('{"msg":"ok"}');
  
  RLogger.instance.e('your have a error', 'error object', StackTrace.current);

  RLogger.instance.listen((data){
// logger data
  });
}
```