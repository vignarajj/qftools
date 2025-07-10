import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';

/// Command to manage and clean unused packages in Flutter projects
class PackagesCleanerCommand {
  final Logger logger;

  PackagesCleanerCommand(this.logger);

  /// Execute the packages cleaner command
  Future<void> execute(ArgResults results) async {
    final check = results['check'] as bool;
    final clean = results['clean'] as bool;

    if (check) {
      await _checkUnusedPackages();
    } else if (clean) {
      await _cleanUnusedPackages();
    } else {
      logger.info(
          'Use --check to find unused packages or --clean to remove them');
      logger.info('Example: qf_tools packages-cleaner --check');
    }
  }

  /// Check for unused packages in the project
  Future<void> _checkUnusedPackages() async {
    logger.step('Checking for unused packages...');

    final unusedPackages = await _findUnusedPackages();

    if (unusedPackages.isEmpty) {
      logger.success('No unused packages found! Your project is clean.');
      return;
    }

    logger.warning('Found ${unusedPackages.length} unused packages:');
    for (final package in unusedPackages) {
      logger.info('  - $package');
    }

    logger.info(
        'Run "qf_tools packages-cleaner --clean" to remove unused packages');
  }

  /// Clean unused packages from the project
  Future<void> _cleanUnusedPackages() async {
    logger.step('Finding unused packages...');

    final unusedPackages = await _findUnusedPackages();

    if (unusedPackages.isEmpty) {
      logger
          .success('No unused packages found! Your project is already clean.');
      return;
    }

    logger.warning('Found ${unusedPackages.length} unused packages');
    for (final package in unusedPackages) {
      logger.info('  - $package');
    }

    // Ask for confirmation
    stdout.write('Do you want to remove these unused packages? (y/N): ');
    final input = stdin.readLineSync()?.toLowerCase();

    if (input != 'y' && input != 'yes') {
      logger.info('Operation cancelled');
      return;
    }

    // Remove unused packages
    int removedCount = 0;
    for (final package in unusedPackages) {
      try {
        logger.step('Removing package: $package');
        final result = await ProcessUtils.runFlutterCommand(
            ['pub', 'remove', package],
            logger: logger);

        if (result.exitCode == 0) {
          removedCount++;
          logger.success('Removed: $package');
        } else {
          logger.error('Failed to remove: $package');
        }
      } catch (e) {
        logger.error('Error removing $package: $e');
      }
    }

    logger.success('Successfully removed $removedCount unused packages');

    // Run flutter pub get to update dependencies
    if (removedCount > 0) {
      logger.step('Running flutter pub get...');
      await ProcessUtils.runFlutterCommand(['pub', 'get'], logger: logger);
    }
  }

  /// Find unused packages in the project
  Future<List<String>> _findUnusedPackages() async {
    final List<String> unusedPackages = [];

    // Get all dependencies from pubspec.yaml
    final dependencies = await _getDependencies();
    if (dependencies.isEmpty) {
      return unusedPackages;
    }

    // Get all Dart files in the project
    final dartFiles = await _getDartFiles();
    final dartContent = await _readAllDartFiles(dartFiles);

    // Check each dependency for usage
    for (final dependency in dependencies) {
      if (_isSystemPackage(dependency)) {
        continue; // Skip system packages
      }

      bool isUsed = false;

      // Check various ways a package might be imported
      final searchPatterns = [
        "import 'package:$dependency",
        'import "package:$dependency',
        "export 'package:$dependency",
        'export "package:$dependency',
        dependency.replaceAll('_', ''), // Check without underscores
      ];

      for (final pattern in searchPatterns) {
        if (dartContent.contains(pattern)) {
          isUsed = true;
          break;
        }
      }

      // Also check if package is referenced in pubspec.yaml assets or other sections
      if (!isUsed) {
        isUsed = await _isPackageReferencedInPubspec(dependency);
      }

      if (!isUsed) {
        unusedPackages.add(dependency);
      }
    }

    return unusedPackages;
  }

  /// Get all dependencies from pubspec.yaml
  Future<List<String>> _getDependencies() async {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) return [];

    try {
      final content = await pubspecFile.readAsString();
      final lines = content.split('\n');
      final List<String> dependencies = [];

      bool inDependencies = false;
      bool inDevDependencies = false;

      for (final line in lines) {
        final trimmed = line.trim();

        if (trimmed == 'dependencies:') {
          inDependencies = true;
          inDevDependencies = false;
          continue;
        } else if (trimmed == 'dev_dependencies:') {
          inDependencies = false;
          inDevDependencies = true;
          continue;
        } else if (trimmed.startsWith('flutter:') ||
            trimmed.startsWith('dependency_overrides:') ||
            trimmed.startsWith('assets:') ||
            trimmed.startsWith('fonts:') ||
            !trimmed.startsWith(' ')) {
          inDependencies = false;
          inDevDependencies = false;
          continue;
        }

        if ((inDependencies || inDevDependencies) && trimmed.isNotEmpty) {
          if (trimmed.contains(':')) {
            final parts = trimmed.split(':');
            if (parts.isNotEmpty) {
              final packageName = parts[0].trim();
              if (packageName.isNotEmpty && !packageName.startsWith('#')) {
                dependencies.add(packageName);
              }
            }
          }
        }
      }

      return dependencies;
    } catch (e) {
      logger.error('Error reading pubspec.yaml: $e');
      return [];
    }
  }

  /// Check if package is a system/framework package that shouldn't be removed
  bool _isSystemPackage(String packageName) {
    final systemPackages = {
      'flutter',
      'flutter_test',
      'flutter_driver',
      'flutter_localizations',
      'cupertino_icons',
      'meta',
      'collection',
      'typed_data',
      'vector_math',
      'sky_engine',
      'flutter_web_plugins',
      'js',
    };

    return systemPackages.contains(packageName);
  }

  /// Get all Dart files in the project
  Future<List<String>> _getDartFiles() async {
    final List<String> dartFiles = [];
    final libDir = Directory('lib');
    final testDir = Directory('test');

    // Check lib directory
    if (libDir.existsSync()) {
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          dartFiles.add(entity.path);
        }
      }
    }

    // Check test directory
    if (testDir.existsSync()) {
      await for (final entity in testDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          dartFiles.add(entity.path);
        }
      }
    }

    return dartFiles;
  }

  /// Read all Dart files content
  Future<String> _readAllDartFiles(List<String> dartFiles) async {
    final buffer = StringBuffer();

    for (final filePath in dartFiles) {
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          final content = await file.readAsString();
          buffer.writeln(content);
        }
      } catch (e) {
        // Skip files that can't be read
        logger.warning('Could not read file: $filePath');
      }
    }

    return buffer.toString();
  }

  /// Check if package is referenced in pubspec.yaml (e.g., in assets, fonts sections)
  Future<bool> _isPackageReferencedInPubspec(String packageName) async {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) return false;

    try {
      final content = await pubspecFile.readAsString();

      // Check if package is referenced in assets or fonts sections
      return content.contains('packages/$packageName') ||
          content.contains('package:$packageName');
    } catch (e) {
      return false;
    }
  }
}
