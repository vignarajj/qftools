import 'dart:io';
import 'package:args/args.dart';
import 'commands/assets_command.dart';
import 'commands/assets_cleaner_command.dart';
import 'commands/clean_command.dart';
import 'commands/format_command.dart';
import 'commands/build_command.dart';
import 'commands/l10n_command.dart';
import 'commands/test_command.dart';
import 'commands/init_command.dart';
import 'commands/packages_command.dart';
import 'commands/packages_cleaner_command.dart';
import 'commands/docs_command.dart';
import 'commands/barrel_command.dart';
import 'commands/organize_imports_command.dart';
import 'utils/logger.dart';

class QfTools {
  final bool verbose;
  late final Logger logger;
  late final AssetsCommand assetsCommand;
  late final AssetsCleanerCommand assetsCleanerCommand;
  late final CleanCommand cleanCommand;
  late final FormatCommand formatCommand;
  late final BuildCommand buildCommand;
  late final L10nCommand l10nCommand;
  late final TestCommand testCommand;
  late final InitCommand initCommand;
  late final PackagesCommand packagesCommand;
  late final PackagesCleanerCommand packagesCleanerCommand;
  late final DocsCommand docsCommand;
  late final BarrelCommand barrelCommand;
  late final OrganizeImportsCommand organizeImportsCommand;

  QfTools({this.verbose = false}) {
    logger = Logger(verbose: verbose);
    assetsCommand = AssetsCommand(logger);
    assetsCleanerCommand = AssetsCleanerCommand(logger);
    cleanCommand = CleanCommand(logger);
    formatCommand = FormatCommand(logger);
    buildCommand = BuildCommand(logger);
    l10nCommand = L10nCommand(logger);
    testCommand = TestCommand(logger);
    initCommand = InitCommand(logger);
    packagesCommand = PackagesCommand(logger);
    packagesCleanerCommand = PackagesCleanerCommand(logger);
    docsCommand = DocsCommand(logger);
    barrelCommand = BarrelCommand(logger);
    organizeImportsCommand = OrganizeImportsCommand(logger);
  }

  /// Verify we're in a Flutter project directory
  bool _isFlutterProject() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) return false;

    final content = pubspecFile.readAsStringSync();
    return content.contains('flutter:') || content.contains('flutter_test:');
  }

  /// Verify command can run in current directory
  void _verifyFlutterProject() {
    if (!_isFlutterProject()) {
      logger.error('Not a Flutter project directory. Please run this command from a Flutter project root.');
      exit(1);
    }
  }

  Future<void> generateAssets(ArgResults results) async {
    _verifyFlutterProject();
    await assetsCommand.execute(results);
  }

  /// Execute assets cleaner command
  Future<void> runAssetsCleaner(ArgResults results) async {
    _verifyFlutterProject();
    await assetsCleanerCommand.execute(results);
  }

  Future<void> runGet(ArgResults results) async {
    _verifyFlutterProject();
    await cleanCommand.executeGet(results);
  }

  Future<void> runClean(ArgResults results) async {
    _verifyFlutterProject();
    await cleanCommand.execute(results);
  }

  Future<void> runFormat(ArgResults results) async {
    _verifyFlutterProject();
    await formatCommand.execute(results);
  }

  Future<void> runBuild(ArgResults results) async {
    _verifyFlutterProject();
    await buildCommand.execute(results);
  }

  Future<void> runL10n(ArgResults results) async {
    _verifyFlutterProject();
    await l10nCommand.execute(results);
  }

  Future<void> runTest(ArgResults results) async {
    _verifyFlutterProject();
    await testCommand.execute(results);
  }

  Future<void> runInit(ArgResults results) async {
    await initCommand.execute(results);
  }

  Future<void> runPackages(ArgResults results) async {
    _verifyFlutterProject();
    await packagesCommand.execute(results);
  }

  /// Execute packages cleaner command
  Future<void> runPackagesCleaner(ArgResults results) async {
    _verifyFlutterProject();
    await packagesCleanerCommand.execute(results);
  }

  Future<void> runDocs(ArgResults results) async {
    _verifyFlutterProject();
    await docsCommand.execute(results);
  }

  /// Execute barrel command
  Future<void> runBarrel(ArgResults results) async {
    _verifyFlutterProject();
    await barrelCommand.execute(results);
  }

  /// Execute organize imports command
  Future<void> runOrganizeImports(ArgResults results) async {
    _verifyFlutterProject();
    await organizeImportsCommand.execute(results);
  }
}
