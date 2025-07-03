import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';

class TestCommand {
  final Logger logger;

  TestCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final coverage = results['coverage'] as bool;
    final group = results['group'] as String?;

    await _runTests(coverage: coverage, group: group);
  }

  Future<void> _runTests({bool coverage = false, String? group}) async {
    final coverageText = coverage ? ' with coverage' : '';
    final groupText = group != null ? ' (group: $group)' : '';

    logger.step('Running tests$coverageText$groupText...');

    final args = ['test'];

    if (coverage) {
      args.add('--coverage');
    }

    if (group != null) {
      args.addAll(['--name', group]);
    }

    final result = await ProcessUtils.runFlutterCommand(args, logger: logger);

    if (result.exitCode == 0) {
      logger.success('Tests completed successfully');

      if (coverage) {
        await _processCoverageReport();
      }
    } else {
      logger.error('Tests failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }

  Future<void> _processCoverageReport() async {
    final coverageDir = Directory('coverage');
    if (!coverageDir.existsSync()) {
      logger.warning('Coverage directory not found');
      return;
    }

    final lcovFile = File('coverage/lcov.info');
    if (lcovFile.existsSync()) {
      logger.info('Coverage report generated: coverage/lcov.info');

      // Try to generate HTML report if genhtml is available
      final genHtmlAvailable = await ProcessUtils.isCommandAvailable('genhtml');
      if (genHtmlAvailable) {
        logger.info('Generating HTML coverage report...');
        final result = await ProcessUtils.runCommand(
          'genhtml',
          ['coverage/lcov.info', '-o', 'coverage/html'],
          logger: logger,
        );

        if (result.exitCode == 0) {
          logger.success('HTML coverage report generated: coverage/html/index.html');
        }
      } else {
        logger.info('Install lcov for HTML coverage reports: brew install lcov (macOS) or apt-get install lcov (Ubuntu)');
      }
    }
  }
}
