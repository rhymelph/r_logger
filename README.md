# r_logger

A Flutter logger plugin.

## Usage
```yaml
dependencies:
  r_logger: 
```
the first use this plugin , your need to init.

```dart
import 'packages:r_logger/r_logger.dart';

// [isWriteFile] can null,if you want to write log set to true,default false.
// [tag] can null.default RLogger.
// [filePath] not null your file path.
// [fileName] can null. default yyyy_MM_dd.
RLogger.initLogger(tag:'your tag',isWriteFile:true,filePath:'your file path',fileName:'your file name');
```
print debug you can use.
```dart
RLogger.instance.d('Message');
```
print info you can use.
```dart
RLogger.instance.i('Message');
```
print json you can use.
```dart
RLogger.instance.j('{"msg":"ok"}');
```
print error you can use.
```dart
RLogger.instance.e('message', error,stackTrace);
```
add listener
```dart
RLogger.instance.listen((data){
// logger data
});
```