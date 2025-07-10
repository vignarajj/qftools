import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import '../utils/file_utils.dart';
import '../utils/logger.dart';

/// Command to manage and clean unused assets in Flutter projects
class AssetsCleanerCommand {
  final Logger logger;

  AssetsCleanerCommand(this.logger);

  /// Execute the assets cleaner command
  Future<void> execute(ArgResults results) async {
    final check = results['check'] as bool;
    final clean = results['clean'] as bool;

    if (check) {
      await _checkUnusedAssets();
    } else if (clean) {
      await _cleanUnusedAssets();
    } else {
      logger
          .info('Use --check to find unused assets or --clean to remove them');
      logger.info('Example: qf_tools assets-cleaner --check');
    }
  }

  /// Check for unused assets in the project
  Future<void> _checkUnusedAssets() async {
    logger.step('Checking for unused assets...');

    final unusedAssets = await _findUnusedAssets();

    if (unusedAssets.isEmpty) {
      logger.success('No unused assets found! Your project is clean.');
      return;
    }

    logger.warning('Found ${unusedAssets.length} unused assets:');
    for (final asset in unusedAssets) {
      logger.info('  - $asset');
    }

    final totalSize = await _calculateTotalSize(unusedAssets);
    logger.info('Total size of unused assets: ${_formatBytes(totalSize)}');
    logger
        .info('Run "qf_tools assets-cleaner --clean" to remove unused assets');
  }

  /// Clean unused assets from the project
  Future<void> _cleanUnusedAssets() async {
    logger.step('Finding unused assets...');

    final unusedAssets = await _findUnusedAssets();

    if (unusedAssets.isEmpty) {
      logger.success('No unused assets found! Your project is already clean.');
      return;
    }

    logger.warning('Found ${unusedAssets.length} unused assets');
    final totalSize = await _calculateTotalSize(unusedAssets);
    logger.info('Total size to be removed: ${_formatBytes(totalSize)}');

    // Ask for confirmation
    stdout.write('Do you want to delete these unused assets? (y/N): ');
    final input = stdin.readLineSync()?.toLowerCase();

    if (input != 'y' && input != 'yes') {
      logger.info('Operation cancelled');
      return;
    }

    // Delete unused assets
    int deletedCount = 0;
    for (final assetPath in unusedAssets) {
      try {
        final file = File(assetPath);
        if (file.existsSync()) {
          await file.delete();
          deletedCount++;
          logger.info('Deleted: $assetPath');
        }
      } catch (e) {
        logger.error('Failed to delete $assetPath: $e');
      }
    }

    logger.success('Successfully deleted $deletedCount unused assets');
    logger.info('Freed up ${_formatBytes(totalSize)} of storage space');
  }

  /// Find unused assets in the project
  Future<List<String>> _findUnusedAssets() async {
    final List<String> unusedAssets = [];

    // Get all asset files
    final assetFiles = FileUtils.getAssetFiles();
    if (assetFiles.isEmpty) {
      return unusedAssets;
    }

    // Get all Dart files in the project
    final dartFiles = await _getDartFiles();
    final dartContent = await _readAllDartFiles(dartFiles);

    // Check each asset file for usage
    for (final assetFile in assetFiles) {
      final assetPath = FileUtils.filePathToAssetPath(assetFile);
      final fileName = path.basename(assetFile);
      final fileNameWithoutExt = path.basenameWithoutExtension(assetFile);

      // Check if asset is referenced in Dart code
      bool isUsed = false;

      // Check various ways an asset might be referenced
      final searchPatterns = [
        assetPath, // Full asset path
        fileName, // File name with extension
        fileNameWithoutExt, // File name without extension
        "'$assetPath'", // Quoted asset path
        '"$assetPath"', // Double quoted asset path
        "'$fileName'", // Quoted file name
        '"$fileName"', // Double quoted file name
      ];

      for (final pattern in searchPatterns) {
        if (dartContent.contains(pattern)) {
          isUsed = true;
          break;
        }
      }

      // Also check if referenced in pubspec.yaml
      if (!isUsed) {
        isUsed = await _isAssetReferencedInPubspec(assetPath);
      }

      if (!isUsed) {
        unusedAssets.add(assetFile);
      }
    }

    return unusedAssets;
  }

  /// Get all Dart files in the project
  Future<List<String>> _getDartFiles() async {
    final List<String> dartFiles = [];
    final libDir = Directory('lib');

    if (libDir.existsSync()) {
      await for (final entity in libDir.list(recursive: true)) {
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

  /// Check if asset is referenced in pubspec.yaml
  Future<bool> _isAssetReferencedInPubspec(String assetPath) async {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) return false;

    try {
      final content = await pubspecFile.readAsString();
      return content.contains(assetPath);
    } catch (e) {
      return false;
    }
  }

  /// Calculate total size of files
  Future<int> _calculateTotalSize(List<String> filePaths) async {
    int totalSize = 0;

    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      } catch (e) {
        // Skip files that can't be accessed
      }
    }

    return totalSize;
  }

  /// Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
