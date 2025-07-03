import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Create directory if it doesn't exist
  static void ensureDirectoryExists(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Get all files in directory recursively
  static List<File> getAllFiles(String directoryPath, {List<String>? extensions}) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) return [];

    final files = <File>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File) {
        if (extensions == null || extensions.contains(path.extension(entity.path))) {
          files.add(entity);
        }
      }
    }
    return files;
  }

  /// Get all asset files from common asset directories
  static List<File> getAssetFileObjects() {
    final assetDirs = ['assets', 'lib/assets', 'images', 'fonts'];
    final assetFiles = <File>[];

    for (final dirPath in assetDirs) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        assetFiles.addAll(getAllFiles(dirPath));
      }
    }

    return assetFiles;
  }

  /// Write content to file, creating directories if needed
  static void writeFile(String filePath, String content) {
    final file = File(filePath);
    ensureDirectoryExists(path.dirname(filePath));
    file.writeAsStringSync(content);
  }

  /// Check if file exists
  static bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Copy file
  static void copyFile(String sourcePath, String destinationPath) {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);
    ensureDirectoryExists(path.dirname(destinationPath));
    sourceFile.copySync(destinationFile.path);
  }

  /// Generate relative path from project root
  static String getRelativePath(String filePath) {
    final currentDir = Directory.current.path;
    return path.relative(filePath, from: currentDir);
  }

  /// Convert file path to Dart asset path
  static String filePathToAssetPath(String filePath) {
    return getRelativePath(filePath).replaceAll(r'\', '/');
  }

  /// Convert file path to Dart constant name
  static String filePathToConstantName(String filePath) {
    final relativePath = getRelativePath(filePath);
    final withoutExtension = path.withoutExtension(relativePath);

    // Convert to camelCase constant name
    return withoutExtension
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part == part.toLowerCase() ? part : part.toLowerCase())
        .join('_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Get all asset files from common asset directories (returns file paths as strings)
  static List<String> getAssetFiles() {
    final assetDirs = ['assets', 'lib/assets', 'images', 'fonts'];
    final assetFiles = <String>[];

    for (final dirPath in assetDirs) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        final files = getAllFiles(dirPath);
        assetFiles.addAll(files.map((file) => file.path));
      }
    }

    return assetFiles;
  }
}
