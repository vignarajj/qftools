import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';

class FormatCommand {
  final Logger logger;

  FormatCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final check = results['check'] as bool;

    if (check) {
      await _checkFormat();
    } else {
      await _formatCode();
    }
  }

  Future<void> _formatCode() async {
    logger.step('Formatting Dart code...');

    final result =
        await ProcessUtils.runDartCommand(['format', '.'], logger: logger);

    if (result.exitCode == 0) {
      logger.success('Code formatting completed successfully');
    } else {
      logger.error('Code formatting failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }

  Future<void> _checkFormat() async {
    logger.step('Checking code formatting...');

    final result = await ProcessUtils.runDartCommand(
        ['format', '--output=none', '--set-exit-if-changed', '.'],
        logger: logger);

    if (result.exitCode == 0) {
      logger.success('All files are properly formatted');
    } else if (result.exitCode == 1) {
      logger.warning('Some files are not properly formatted');
      logger.info('Run "qf_tools format" to fix formatting issues');
      exit(1);
    } else {
      logger.error('Format check failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }
}
