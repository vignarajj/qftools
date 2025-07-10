import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';

class DocsCommand {
  final Logger logger;

  DocsCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final validate = results['validate'] as bool;

    if (validate) {
      await _validateDocumentation();
    } else {
      await _generateDocumentation();
    }
  }

  Future<void> _generateDocumentation() async {
    logger.step('Generating API documentation...');

    final result = await ProcessUtils.runDartCommand(['doc'], logger: logger);

    if (result.exitCode == 0) {
      logger.success('API documentation generated successfully');
      logger.info('Documentation available in doc/api/ directory');
    } else {
      logger.error(
          'Documentation generation failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }

  Future<void> _validateDocumentation() async {
    logger.step('Validating documentation coverage...');

    // Run dart doc with validation
    final result = await ProcessUtils.runDartCommand(
        ['doc', '--validate-links'],
        logger: logger);

    if (result.exitCode == 0) {
      logger.success('Documentation validation completed');
      await _checkDocumentationCoverage();
    } else {
      logger.warning('Documentation validation found issues');
      exit(result.exitCode);
    }
  }

  Future<void> _checkDocumentationCoverage() async {
    logger.info('Checking documentation coverage...');

    // This is a simplified check - in a real implementation, you might parse
    // the dart doc output to get actual coverage statistics
    final result = await ProcessUtils.runDartCommand(['doc', '--dry-run'],
        logger: logger, showOutput: false);

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      final warningCount = RegExp(r'warning:').allMatches(output).length;

      if (warningCount == 0) {
        logger.success('Documentation coverage is complete');
      } else {
        logger.warning('Found $warningCount documentation warnings');
        logger.info('Review the warnings and add missing documentation');
      }
    }
  }
}
