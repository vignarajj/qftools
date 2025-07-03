import 'dart:io';
import 'dart:convert';
import 'logger.dart';

class ProcessUtils {
  static Future<ProcessResult> runCommand(
    String command,
    List<String> arguments, {
    Logger? logger,
    String? workingDirectory,
    bool showOutput = true,
  }) async {
    logger?.debug('Running: $command ${arguments.join(' ')}');

    final process = await Process.start(
      command,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: Platform.isWindows,
    );

    final outputBuffer = StringBuffer();
    final errorBuffer = StringBuffer();

    process.stdout.transform(utf8.decoder).listen((data) {
      outputBuffer.write(data);
      if (showOutput) {
        stdout.write(data);
      }
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      errorBuffer.write(data);
      if (showOutput) {
        stderr.write(data);
      }
    });

    final exitCode = await process.exitCode;

    return ProcessResult(
      process.pid,
      exitCode,
      outputBuffer.toString(),
      errorBuffer.toString(),
    );
  }

  static Future<ProcessResult> runFlutterCommand(
    List<String> arguments, {
    Logger? logger,
    String? workingDirectory,
    bool showOutput = true,
  }) async {
    return runCommand(
      'flutter',
      arguments,
      logger: logger,
      workingDirectory: workingDirectory,
      showOutput: showOutput,
    );
  }

  static Future<ProcessResult> runDartCommand(
    List<String> arguments, {
    Logger? logger,
    String? workingDirectory,
    bool showOutput = true,
  }) async {
    return runCommand(
      'dart',
      arguments,
      logger: logger,
      workingDirectory: workingDirectory,
      showOutput: showOutput,
    );
  }

  static Future<bool> isCommandAvailable(String command) async {
    try {
      final result = await runCommand(
        Platform.isWindows ? 'where' : 'which',
        [command],
        showOutput: false,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isFlutterAvailable() async {
    return isCommandAvailable('flutter');
  }

  static Future<bool> isDartAvailable() async {
    return isCommandAvailable('dart');
  }

  static Future<String?> getFlutterVersion() async {
    try {
      final result = await runFlutterCommand(['--version'], showOutput: false);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        return lines.isNotEmpty ? lines.first : null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
