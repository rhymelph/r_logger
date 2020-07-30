// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library r_logger;

import 'dart:async';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import 'dart:io';


class RLogger {
  final String tag;
  final bool isWriteFile;
  final StreamController<RLoggerData> _dataController =
      StreamController.broadcast();

  static RLogger instance;

  RLogger._(String filePath, String fileName, this.tag, this.isWriteFile) {
    _writer = _RFileWriter(filePath, fileName);
    _dataController.stream.listen(_handlePrintMessage);
    _dataController.stream.listen(_handleWriteFile);
  }

  _RFileWriter _writer;

  ///[tag] is the name of the source of the log message
  ///[isWriteFile] is the log message write file ?
  ///[filePath] is the log message write file path.
  ///[fileName] is the log message write file name.
  static RLogger initLogger(
      {String tag: 'RLogger',
      bool isWriteFile: false,
      String filePath,
      String fileName}) {
    assert(filePath != null);
    return instance = RLogger._(filePath, fileName, tag, isWriteFile);
  }

  /// log debug
  ///
  /// [message] s the log message
  /// [tag] is the name of the source of the log message
  /// [isWriteFile] is the log message write file ?
  void d(String message, {String tag, bool isWriteFile}) {
    _dataController.add(RLoggerData(
        tag ?? this.tag, RLoggerLevel.debug, message,
        dateTime: DateTime.now(), isWriteFile: isWriteFile ?? this.isWriteFile));
  }

  void i(String message, {String tag, bool isWriteFile}) {
    _dataController.add(RLoggerData(tag ?? this.tag, RLoggerLevel.info, message,
        dateTime: DateTime.now(), isWriteFile: isWriteFile ?? this.isWriteFile));
  }

  /// log json
  ///
  /// [message] s the log message
  /// [tag] is the name of the source of the log message
  /// [isWriteFile] is the log message write file ?
  void j(String json, {String tag, bool isWriteFile}) {
    _dataController.add(RLoggerData(
      tag ?? this.tag,
      RLoggerLevel.debug,
      _RJson.jsonFormat(json),
      dateTime: DateTime.now(),
      isWriteFile: isWriteFile ?? this.isWriteFile,
    ));
  }

  /// log error
  ///
  /// [message] is the log message
  /// [error] an error object associated with this log event
  /// [tag] is the name of the source of the log message
  /// [isWriteFile] is the log message write file ?
  void e(String message, Object error, StackTrace stackTrace,
      {String tag, bool isWriteFile}) {
    _dataController.add(RLoggerData(
        tag ?? this.tag, RLoggerLevel.error, message,
        error: error,
        stackTrace: stackTrace,
        dateTime: DateTime.now(),
        isWriteFile: isWriteFile ?? this.isWriteFile));
  }

  StreamSubscription<RLoggerData> listen(void onData(RLoggerData event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _dataController.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void dispose() {
    _dataController.close();
  }

  void _handlePrintMessage(RLoggerData event) {
    switch (event.level) {
      case RLoggerLevel.debug:
        developer.log(
          event.message,
          name: event.tag,
          time: event.dateTime,
        );
        break;
      case RLoggerLevel.info:
        print('(${event.tag}):${event.message}');
        break;
      case RLoggerLevel.error:
        developer.log(
          event.message,
          name: event.tag,
          time: event.dateTime,
          error: event.error,
          stackTrace: event.stackTrace,
        );
        break;
    }
  }

  void _handleWriteFile(RLoggerData event) {
    if (event.isWriteFile != true) return;
    switch (event.level) {
      case RLoggerLevel.debug:
        _writer.writeLog('\n (${event.tag})${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.dateTime)}:${event.message}\n');
        break;
      case RLoggerLevel.info:
        _writer.writeLog('\n(${event.tag})${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.dateTime)}:${event.message}\n');
        break;
      case RLoggerLevel.error:
        _writer.writeLog(
            '\n(${event.tag})${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.dateTime)}:${event.message}\n--->Error:${event.error}\n--->StackTrace:${event.stackTrace.toString()}\n');
        break;
    }
  }
}

/// log message file writer
class _RFileWriter {
  /// write file
  File file;

  _RFileWriter(String filePath, String fileName) {
    Directory rootPath = Directory(filePath);
    file = File(
        '${rootPath.path}${fileName ?? '${DateFormat('yyyy_MM_dd').format(DateTime.now())}.log'}');
  }

  /// file log write.
  ///
  /// android platform: your need to require write storage permission.
  ///
  /// [path] is the file path to write log message.
  /// [message] is the log message.
  Future<void> writeLog(String message) async {
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(message, mode: FileMode.append);
    return null;
  }
}

class _RJson {
  /// json level ping
  ///
  /// [level] your level
  static String _getLevelStr(int level) {
    StringBuffer levelStr = new StringBuffer();
    for (int levelI = 0; levelI < level; levelI++) {
      List<int> codeUnits = "\t".codeUnits;
      codeUnits.forEach((i) {
        levelStr.writeCharCode(i);
      });
    }
    return levelStr.toString();
  }

  /// json format
  ///
  /// [s] your json
  static String jsonFormat(String s) {
    int level = 0;
    StringBuffer jsonForMatStr = StringBuffer();
    for (int index = 0; index < s.length; index++) {
      int c = s.codeUnitAt(index);
      if (level > 0 &&
          '\n'.codeUnitAt(0) ==
              jsonForMatStr.toString().codeUnitAt(jsonForMatStr.length - 1)) {
        jsonForMatStr.write(_getLevelStr(level));
      }
      if ('{'.codeUnitAt(0) == c || '['.codeUnitAt(0) == c) {
        jsonForMatStr.write(String.fromCharCode(c) + "\n");
        level++;
      } else if (','.codeUnitAt(0) == c) {
        jsonForMatStr.write(String.fromCharCode(c) + "\n");
      } else if ('}'.codeUnitAt(0) == c || ']'.codeUnitAt(0) == c) {
        jsonForMatStr.write("\n");
        level--;
        jsonForMatStr.write(_getLevelStr(level));
        jsonForMatStr.writeCharCode(c);
      } else {
        jsonForMatStr.writeCharCode(c);
      }
    }
    return jsonForMatStr.toString();
  }
}

enum RLoggerLevel {
  debug,
  info,
  error,
}

class RLoggerData {
  final String tag;
  final RLoggerLevel level;
  final String message;
  final Object error;
  final StackTrace stackTrace;
  final DateTime dateTime;
  final bool isWriteFile;

  RLoggerData(this.tag, this.level, this.message,
      {this.error, this.stackTrace, this.dateTime, this.isWriteFile});
}
