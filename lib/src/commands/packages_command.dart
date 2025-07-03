import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';

class PackagesCommand {
  final Logger logger;

  PackagesCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final outdated = results['outdated'] as bool;
    final add = results['add'] as String?;

    if (outdated) {
      await _checkOutdatedPackages();
    } else if (add != null) {
      await _addPackages(add);
    } else {
      logger.info('Use --outdated to check for outdated packages or --add to add new packages');
    }
  }

  Future<void> _checkOutdatedPackages() async {
    logger.step('Checking for outdated packages...');

    final result = await ProcessUtils.runFlutterCommand(['pub', 'outdated'], logger: logger);

    if (result.exitCode == 0) {
      logger.success('Package check completed');
    } else {
      logger.error('Package check failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }

  Future<void> _addPackages(String packages) async {
    final packageList = packages.split(',').map((p) => p.trim()).toList();

    logger.step('Adding packages: ${packageList.join(', ')}');

    final args = ['pub', 'add', ...packageList];
    final result = await ProcessUtils.runFlutterCommand(args, logger: logger);

    if (result.exitCode == 0) {
      logger.success('Packages added successfully');
    } else {
      logger.error('Failed to add packages with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }
}
