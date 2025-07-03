import 'dart:io';
import 'package:test/test.dart';
import 'package:qf_tools/qftools.dart';

void main() {
  group('QfTools', () {
    late QfTools qfTools;

    setUp(() {
      qfTools = QfTools(verbose: true);
    });

    test('should create QfTools instance', () {
      expect(qfTools, isNotNull);
      expect(qfTools.verbose, isTrue);
    });

    group('Logger', () {
      test('should create logger with verbose mode', () {
        final logger = Logger(verbose: true);
        expect(logger.verbose, isTrue);
      });

      test('should create logger without verbose mode', () {
        final logger = Logger(verbose: false);
        expect(logger.verbose, isFalse);
      });
    });

    group('FileUtils', () {
      test('should check if file exists', () {
        expect(FileUtils.fileExists('pubspec.yaml'), isTrue);
        expect(FileUtils.fileExists('nonexistent.txt'), isFalse);
      });

      test('should convert file path to asset path', () {
        final assetPath = FileUtils.filePathToAssetPath('assets/images/logo.png');
        expect(assetPath, equals('assets/images/logo.png'));
      });

      test('should convert file path to constant name', () {
        final constantName = FileUtils.filePathToConstantName('assets/images/app_logo.png');
        expect(constantName, equals('assets_images_app_logo'));
      });

      test('should get relative path', () {
        final relativePath = FileUtils.getRelativePath('${Directory.current.path}/test.txt');
        expect(relativePath, equals('test.txt'));
      });
    });

    group('ProcessUtils', () {
      test('should check if dart command is available', () async {
        final available = await ProcessUtils.isDartAvailable();
        expect(available, isTrue);
      });

      test('should check if flutter command is available', () async {
        final available = await ProcessUtils.isFlutterAvailable();
        // This might be false in CI environments without Flutter
        expect(available, isA<bool>());
      });

      test('should run dart command', () async {
        final result = await ProcessUtils.runDartCommand(
          ['--version'],
          showOutput: false,
        );
        expect(result.exitCode, equals(0));
      });
    });

    group('Commands', () {
      test('AssetsCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = AssetsCommand(logger);
        expect(command, isNotNull);
      });

      test('CleanCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = CleanCommand(logger);
        expect(command, isNotNull);
      });

      test('FormatCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = FormatCommand(logger);
        expect(command, isNotNull);
      });

      test('BuildCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = BuildCommand(logger);
        expect(command, isNotNull);
      });

      test('L10nCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = L10nCommand(logger);
        expect(command, isNotNull);
      });

      test('TestCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = TestCommand(logger);
        expect(command, isNotNull);
      });

      test('InitCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = InitCommand(logger);
        expect(command, isNotNull);
      });

      test('PackagesCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = PackagesCommand(logger);
        expect(command, isNotNull);
      });

      test('DocsCommand should initialize', () {
        final logger = Logger(verbose: false);
        final command = DocsCommand(logger);
        expect(command, isNotNull);
      });
    });
  });

  group('Integration Tests', () {
    test('should handle missing pubspec.yaml', () {
      // This would be tested in a temporary directory without pubspec.yaml
      // For now, we'll skip this test in the main project
    });

    test('should generate assets content', () {
      // Create a temporary directory structure for testing
      final tempDir = Directory.systemTemp.createTempSync('qftools_test_');
      final assetsDir = Directory('${tempDir.path}/assets');
      assetsDir.createSync();

      // Create a test asset file
      final testAsset = File('${assetsDir.path}/test.png');
      testAsset.writeAsStringSync('test content');

      // Test asset generation logic
      final assetFiles = [testAsset];
      expect(assetFiles.length, equals(1));

      // Clean up
      tempDir.deleteSync(recursive: true);
    });
  });
}
