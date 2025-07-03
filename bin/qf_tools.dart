#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:qftools/qftools.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show this help message')
    ..addFlag('verbose', abbr: 'v', help: 'Enable verbose logging')
    ..addCommand('assets')
    ..addCommand('assets-cleaner')
    ..addCommand('get')
    ..addCommand('clean')
    ..addCommand('format')
    ..addCommand('build')
    ..addCommand('l10n')
    ..addCommand('test')
    ..addCommand('init')
    ..addCommand('packages')
    ..addCommand('packages-cleaner')
    ..addCommand('docs');

  // Configure subcommands
  _configureAssetsCommand(parser.commands['assets']!);
  _configureAssetsCleanerCommand(parser.commands['assets-cleaner']!);
  _configureCleanCommand(parser.commands['clean']!);
  _configureFormatCommand(parser.commands['format']!);
  _configureBuildCommand(parser.commands['build']!);
  _configureL10nCommand(parser.commands['l10n']!);
  _configureTestCommand(parser.commands['test']!);
  _configureInitCommand(parser.commands['init']!);
  _configurePackagesCommand(parser.commands['packages']!);
  _configurePackagesCleanerCommand(parser.commands['packages-cleaner']!);
  _configureDocsCommand(parser.commands['docs']!);

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool || results.command == null) {
      print('QfTools - Flutter Project Management CLI\n');
      print('Usage: qf_tools <command> [options]\n');
      print('Commands:');
      print('  assets            Generate asset constants');
      print('  assets-cleaner    Check and clean unused assets');
      print('  get               Run flutter pub get');
      print('  clean             Clean project (flutter clean)');
      print('  format            Format Dart code');
      print('  build             Build APKs');
      print('  l10n              Generate localization files');
      print('  test              Run tests');
      print('  init              Initialize project configurations');
      print('  packages          Manage dependencies');
      print('  packages-cleaner  Check and clean unused packages');
      print('  docs              Generate API documentation');
      print('\nGlobal options:');
      print('  -v, --verbose    Enable verbose logging');
      print('  -h, --help       Show this help message');
      print('\nUse "qf_tools <command> --help" for more information about a command.');
      return;
    }

    // Handle subcommand help
    if (results.command != null && results.command!['help'] as bool) {
      print('QfTools - ${results.command!.name} command\n');
      print('Usage: qf_tools ${results.command!.name} [options]\n');
      print('Options:');
      print(parser.commands[results.command!.name]!.usage);
      return;
    }

    final verbose = results['verbose'] as bool;
    final qfTools = QfTools(verbose: verbose);

    switch (results.command?.name) {
      case 'assets':
        await qfTools.generateAssets(results.command!);
        break;
      case 'assets-cleaner':
        await qfTools.runAssetsCleaner(results.command!);
        break;
      case 'get':
        await qfTools.runGet(results.command!);
        break;
      case 'clean':
        await qfTools.runClean(results.command!);
        break;
      case 'format':
        await qfTools.runFormat(results.command!);
        break;
      case 'build':
        await qfTools.runBuild(results.command!);
        break;
      case 'l10n':
        await qfTools.runL10n(results.command!);
        break;
      case 'test':
        await qfTools.runTest(results.command!);
        break;
      case 'init':
        await qfTools.runInit(results.command!);
        break;
      case 'packages':
        await qfTools.runPackages(results.command!);
        break;
      case 'packages-cleaner':
        await qfTools.runPackagesCleaner(results.command!);
        break;
      case 'docs':
        await qfTools.runDocs(results.command!);
        break;
      default:
        print('Unknown command: ${results.command?.name}');
        exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _configureAssetsCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('watch', help: 'Watch for asset changes and regenerate automatically');
}

void _configureAssetsCleanerCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('check', help: 'Check for unused assets without removing them');
  parser.addFlag('clean', help: 'Remove unused assets from the project');
}

void _configureCleanCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('full', help: 'Full clean including build_runner operations');
}

void _configureFormatCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('check', help: 'Check formatting without applying changes');
}

void _configureBuildCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('release', help: 'Build in release mode (default: debug)');
  parser.addOption('flavor', help: 'Specify build flavor');
}

void _configureL10nCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addOption('template', help: 'Specify ARB template file path');
}

void _configureTestCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('coverage', help: 'Generate coverage reports');
  parser.addOption('group', help: 'Run specific test groups');
}

void _configureInitCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('force', help: 'Overwrite existing files');
}

void _configurePackagesCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('outdated', help: 'Check for outdated packages');
  parser.addOption('add', help: 'Add new packages (comma-separated)');
}

void _configurePackagesCleanerCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('check', help: 'Check for unused packages without removing them');
  parser.addFlag('clean', help: 'Remove unused packages from the project');
}

void _configureDocsCommand(ArgParser parser) {
  parser.addFlag('help', abbr: 'h', help: 'Show help for this command');
  parser.addFlag('validate', help: 'Check documentation coverage');
}
