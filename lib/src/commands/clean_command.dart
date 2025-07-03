import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';

class CleanCommand {
  final Logger logger;

  CleanCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final full = results['full'] as bool;

    if (full) {
      await _fullClean();
    } else {
      await _standardClean();
    }
  }

  Future<void> executeGet(ArgResults results) async {
    logger.step('Running flutter pub get...');

    final result = await ProcessUtils.runFlutterCommand(['pub', 'get'], logger: logger);

    if (result.exitCode == 0) {
      logger.success('Flutter pub get completed successfully');
    } else {
      logger.error('Flutter pub get failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }

  Future<void> _standardClean() async {
    logger.step('Performing standard clean...');

    // Run flutter clean
    logger.info('Running flutter clean...');
    final cleanResult = await ProcessUtils.runFlutterCommand(['clean'], logger: logger);

    if (cleanResult.exitCode != 0) {
      logger.error('Flutter clean failed with exit code ${cleanResult.exitCode}');
      exit(cleanResult.exitCode);
    }

    // Run flutter pub get
    logger.info('Running flutter pub get...');
    final getResult = await ProcessUtils.runFlutterCommand(['pub', 'get'], logger: logger);

    if (getResult.exitCode != 0) {
      logger.error('Flutter pub get failed with exit code ${getResult.exitCode}');
      exit(getResult.exitCode);
    }

    logger.success('Standard clean completed successfully');
  }

  Future<void> _fullClean() async {
    logger.step('Performing full clean...');

    // Check if build_runner is available
    final hasBuildRunner = await _hasBuildRunner();

    if (hasBuildRunner) {
      // Run build_runner clean
      logger.info('Running build_runner clean...');
      final cleanResult = await ProcessUtils.runFlutterCommand(
        ['packages', 'pub', 'run', 'build_runner', 'clean'],
        logger: logger,
      );

      if (cleanResult.exitCode != 0) {
        logger.warning('Build runner clean failed, continuing...');
      }

      // Run build_runner build
      logger.info('Running build_runner build...');
      final buildResult = await ProcessUtils.runFlutterCommand(
        ['packages', 'pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        logger: logger,
      );

      if (buildResult.exitCode != 0) {
        logger.warning('Build runner build failed, continuing...');
      }
    } else {
      logger.debug('build_runner not found in dependencies, skipping...');
    }

    // Run flutter clean
    logger.info('Running flutter clean...');
    final cleanResult = await ProcessUtils.runFlutterCommand(['clean'], logger: logger);

    if (cleanResult.exitCode != 0) {
      logger.error('Flutter clean failed with exit code ${cleanResult.exitCode}');
      exit(cleanResult.exitCode);
    }

    // Run flutter pub get
    logger.info('Running flutter pub get...');
    final getResult = await ProcessUtils.runFlutterCommand(['pub', 'get'], logger: logger);

    if (getResult.exitCode != 0) {
      logger.error('Flutter pub get failed with exit code ${getResult.exitCode}');
      exit(getResult.exitCode);
    }

    logger.success('Full clean completed successfully');
  }

  Future<bool> _hasBuildRunner() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) return false;

      final content = pubspecFile.readAsStringSync();
      return content.contains('build_runner:');
    } catch (e) {
      return false;
    }
  }
}
