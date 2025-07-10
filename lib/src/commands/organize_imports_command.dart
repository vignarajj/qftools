import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';

/// Command to organize imports in Dart files
class OrganizeImportsCommand {
  final Logger logger;

  OrganizeImportsCommand(this.logger);

  /// Execute the organize imports command
  Future<void> execute(ArgResults results) async {
    final useBarrelFiles = results['barrel'] as bool;
    String? targetFile;

    // Check if file argument is provided
    if (results.rest.isNotEmpty) {
      targetFile = results.rest.first;
    } else {
      // Interactive mode: list all .dart files in lib/ directory
      targetFile = await _selectFileInteractively();
      if (targetFile == null) {
        return;
      }

      // Ask for barrel option if not already specified
      final useBarrel = await _promptForBarrelOption();
      if (useBarrel) {
        await _organizeImports(targetFile, useBarrelFiles: true);
        return;
      }
    }

    if (targetFile == null || targetFile.isEmpty) {
      logger.error('Please specify a Dart file to organize imports');
      logger
          .info('Usage: qftools organize-imports <path/file.dart> [--barrel]');
      return;
    }

    await _organizeImports(targetFile, useBarrelFiles: useBarrelFiles);
  }

  /// Interactive file selection from lib/ directory
  Future<String?> _selectFileInteractively() async {
    logger.info('Searching for .dart files in lib/ directory...');

    final libDir = Directory('lib');
    if (!libDir.existsSync()) {
      logger.error(
          'lib/ directory not found. Make sure you\'re in a Flutter project root.');
      return null;
    }

    // Find all .dart files in lib/ directory and subdirectories
    final dartFiles = <String>[];
    await for (final entity
        in libDir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        dartFiles.add(entity.path);
      }
    }

    if (dartFiles.isEmpty) {
      logger.error('No .dart files found in lib/ directory.');
      return null;
    }

    // Sort files for consistent ordering
    dartFiles.sort();

    print('\nSelect a file to organize imports:');
    for (int i = 0; i < dartFiles.length; i++) {
      print('${i + 1}. ${dartFiles[i]}');
    }

    // Get user selection
    while (true) {
      stdout.write('\nEnter file number (1-${dartFiles.length}): ');
      final input = stdin.readLineSync();

      if (input == null || input.trim().isEmpty) {
        logger.warning('No input provided. Exiting...');
        return null;
      }

      final selection = int.tryParse(input.trim());
      if (selection != null &&
          selection >= 1 &&
          selection <= dartFiles.length) {
        return dartFiles[selection - 1];
      } else {
        print(
            'Invalid selection. Please enter a number between 1 and ${dartFiles.length}.');
      }
    }
  }

  /// Prompt user for barrel file option
  Future<bool> _promptForBarrelOption() async {
    while (true) {
      stdout.write('Use barrel files? (y/n): ');
      final input = stdin.readLineSync();

      if (input == null || input.trim().isEmpty) {
        continue;
      }

      final answer = input.trim().toLowerCase();
      if (answer == 'y' || answer == 'yes') {
        return true;
      } else if (answer == 'n' || answer == 'no') {
        return false;
      } else {
        print('Please enter y/yes or n/no.');
      }
    }
  }

  /// Organize imports in the specified Dart file
  Future<void> _organizeImports(String filePath,
      {bool useBarrelFiles = false}) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      logger.error('File not found: $filePath');
      return;
    }

    if (!filePath.endsWith('.dart')) {
      logger.error('File must be a Dart file (.dart extension)');
      return;
    }

    logger.step('Organizing imports in: $filePath');

    try {
      final content = await file.readAsString();
      final lines = content.split('\n');

      final imports = _extractImports(lines);
      final nonImportLines = _removeImportLines(lines);

      final organizedImports = _organizeImportsByCategory(imports, filePath,
          useBarrelFiles: useBarrelFiles);

      // Combine organized imports with the rest of the file
      final organizedContent =
          _buildOrganizedContent(organizedImports, nonImportLines);

      // Write back to file
      await file.writeAsString(organizedContent);

      logger.success('Successfully organized imports in $filePath');
      if (useBarrelFiles) {
        logger.info('Used barrel file optimization where available');
      }
    } catch (e) {
      logger.error('Error organizing imports: $e');
    }
  }

  /// Extract all import lines from the file
  List<String> _extractImports(List<String> lines) {
    final imports = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith("import '") || trimmed.startsWith('import "')) {
        imports.add(trimmed);
      }
    }

    return imports;
  }

  /// Remove import lines from the file, keeping everything else
  List<String> _removeImportLines(List<String> lines) {
    final nonImportLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (!(trimmed.startsWith("import '") || trimmed.startsWith('import "'))) {
        nonImportLines.add(line);
      }
    }

    return nonImportLines;
  }

  /// Organize imports by category with proper grouping
  List<String> _organizeImportsByCategory(List<String> imports, String filePath,
      {bool useBarrelFiles = false}) {
    final organized = <String>[];

    // Categorize imports
    final dartImports = <String>[];
    final flutterCoreImports = <String>[];
    final flutterPackageImports = <String>[];
    final thirdPartyImports = <String>[];
    final projectImports = <String>[];

    for (final import in imports) {
      if (import.contains("import 'dart:")) {
        dartImports.add(import);
      } else if (import.contains("import 'package:flutter/")) {
        flutterCoreImports.add(import);
      } else if (import.contains("import 'package:flutter_")) {
        flutterPackageImports.add(import);
      } else if (import.contains("import 'package:")) {
        thirdPartyImports.add(import);
      } else if (import.contains("import '../") ||
          import.contains("import './")) {
        projectImports.add(import);
      }
    }

    // Sort each category
    dartImports.sort();
    flutterCoreImports.sort();
    flutterPackageImports.sort();
    thirdPartyImports.sort();
    projectImports.sort();

    // Add categories with headers
    if (dartImports.isNotEmpty) {
      organized.add('// Dart imports');
      organized.addAll(dartImports);
      organized.add('');
    }

    if (flutterCoreImports.isNotEmpty) {
      organized.add('// Flutter core imports');
      organized.addAll(flutterCoreImports);
      organized.add('');
    }

    if (flutterPackageImports.isNotEmpty) {
      organized.add('// Flutter packages');
      organized.addAll(flutterPackageImports);
      organized.add('');
    }

    if (thirdPartyImports.isNotEmpty) {
      organized.add('// Third party packages');
      organized.addAll(thirdPartyImports);
      organized.add('');
    }

    // Handle project imports with barrel file optimization
    if (projectImports.isNotEmpty) {
      organized.addAll(_organizeProjectImports(projectImports, filePath,
          useBarrelFiles: useBarrelFiles));
    }

    return organized;
  }

  /// Organize project imports with optional barrel file optimization
  List<String> _organizeProjectImports(
      List<String> projectImports, String filePath,
      {bool useBarrelFiles = false}) {
    final organized = <String>[];

    if (!useBarrelFiles) {
      // Simple case: just add all project imports together
      organized.add('// Project imports');
      organized.addAll(projectImports);
      organized.add('');
      return organized;
    }

    // Barrel file optimization
    final fileDir = Directory(filePath).parent.path;
    final importsByDirectory = <String, List<String>>{};
    final otherImports = <String>[];

    // Group imports by directory
    for (final import in projectImports) {
      // Handle both '../dir/...' and './dir/...' patterns
      var match = RegExp(r"import '\.\.\/([^/]+)\/.*';").firstMatch(import);
      match ??= RegExp(r"import '\.\/([^/]+)\/.*';").firstMatch(import);

      if (match != null) {
        final dirName = match.group(1)!;
        importsByDirectory.putIfAbsent(dirName, () => []).add(import);
      } else {
        otherImports.add(import);
      }
    }

    // Process each directory
    for (final entry in importsByDirectory.entries) {
      final dirName = entry.key;
      final dirImports = entry.value;

      // Check if barrel file exists
      // Try both relative path patterns
      var barrelPath = '$fileDir/../$dirName/$dirName.dart';
      var barrelFile = File(barrelPath);
      var importPrefix = '../';

      if (!barrelFile.existsSync()) {
        // Try current directory pattern
        barrelPath = '$fileDir/$dirName/$dirName.dart';
        barrelFile = File(barrelPath);
        importPrefix = './';
      }

      final capitalizedDir = dirName[0].toUpperCase() + dirName.substring(1);

      if (barrelFile.existsSync()) {
        // Use barrel file
        organized.add('// $capitalizedDir');
        organized.add("import '$importPrefix$dirName/$dirName.dart';");
        organized.add('');
      } else {
        // Use individual imports
        organized.add('// $capitalizedDir');
        organized.addAll(dirImports);
        organized.add('');
      }
    }

    // Add other project imports
    if (otherImports.isNotEmpty) {
      organized.add('// Other project imports');
      organized.addAll(otherImports);
      organized.add('');
    }

    return organized;
  }

  /// Build the final organized content
  String _buildOrganizedContent(
      List<String> organizedImports, List<String> nonImportLines) {
    final result = <String>[];

    // Add organized imports
    result.addAll(organizedImports);

    // Find the first non-empty, non-comment line to add proper spacing
    var foundFirstCode = false;
    for (var i = 0; i < nonImportLines.length; i++) {
      final line = nonImportLines[i];
      final trimmed = line.trim();

      if (!foundFirstCode && trimmed.isNotEmpty && !trimmed.startsWith('//')) {
        foundFirstCode = true;
        if (organizedImports.isNotEmpty && result.last.isNotEmpty) {
          result.add(''); // Add spacing before first code line
        }
      }

      result.add(line);
    }

    return result.join('\n');
  }
}
