import 'dart:io';

class Logger {
  final bool verbose;

  Logger({this.verbose = false});

  void info(String message) {
    print('ℹ️  $message');
  }

  void success(String message) {
    print('✅ $message');
  }

  void warning(String message) {
    print('⚠️  $message');
  }

  void error(String message) {
    stderr.writeln('❌ $message');
  }

  void debug(String message) {
    if (verbose) {
      print('🐛 [DEBUG] $message');
    }
  }

  void step(String message) {
    print('⏳ $message');
  }

  void progress(String message) {
    stdout.write('$message...');
  }

  void progressDone() {
    print(' Done!');
  }
}
