// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library r_logger;

import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import 'dart:io';

RLogger logger;

class RLogger {
  final String filePath;
  final String tag;
  final bool isWriteFile;

  RLogger._(this.filePath, this.tag, this.isWriteFile);

  ///[tag] is the name of the source of the log message
  ///[isWriteFile] is the log message write file ?
  ///[filePath] is the log message write file path.
  factory RLogger.initLogger(
          {String tag: 'RLogger', bool isWriteFile: false, String filePath}) =>
      logger = RLogger._(filePath, tag, isWriteFile);

  /// log debug
  ///
  /// [message] s the log message
  /// [tag] is the name of the source of the log message
  /// [isWriteFile] is the log message write file ?
  void d(String message, {String tag, bool isWriteFile}) {
    developer.log(
      message,
      name: tag ?? this.tag,
      time: DateTime.now(),
    );
    if (isWriteFile == true)
      _RFileWriter.writeLog(filePath, '\nMessage:$message\n');
  }

  /// log debug
  ///
  /// [message] s the log message
  /// [tag] is the name of the source of the log message
  /// [isWriteFile] is the log message write file ?
  void j(String json, {String tag, bool isWriteFile}) {
    developer.log(
      RJson.jsonFormat(json),
      name: tag ?? this.tag,
      time: DateTime.now(),
    );
    if (isWriteFile == true)
      _RFileWriter.writeLog(filePath, '\nMessage:${RJson.jsonFormat(json)}\n');
  }

  /// log error
  ///
  /// [message] is the log message
  /// [error] an error object associated with this log event
  /// [tag] is the name of the source of the log message
  /// [isWriteFile] is the log message write file ?
  void e(String message, Object error, StackTrace stackTrace,
      {String tag, bool isWriteFile}) {
    developer.log(
      message,
      name: tag ?? this.tag,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );

    if (isWriteFile == true)
      _RFileWriter.writeLog(filePath,
          '\nMessage:$message\nError:$error\n,StackTrace:${stackTrace.toString()}\n');
  }
}

/// log message file writer
class _RFileWriter {
  /// write file
  static File file;

  /// file log write.
  ///
  /// android platform: your need to require write storage permission.
  ///
  /// [path] is the file path to write log message.
  /// [message] is the log message.
  static Future<void> writeLog(String path, String message) async {
    if (file == null) {
      Directory rootPath = Directory(path);
      String fileName =
          '${DateFormat('yyyy_MM_dd').format(DateTime.now())}.log';
      file = File('${rootPath.path}$fileName');
    }
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(message, mode: FileMode.append);
    return null;
  }
}

class RJson {
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
