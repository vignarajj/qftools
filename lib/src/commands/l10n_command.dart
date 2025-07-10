import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';
import '../utils/file_utils.dart';

class L10nCommand {
  final Logger logger;

  L10nCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final template = results['template'] as String?;

    await _generateL10n(template: template);
  }

  Future<void> _generateL10n({String? template}) async {
    logger.step('Generating localization files...');

    // Check if l10n is configured in pubspec.yaml
    if (!_isL10nConfigured()) {
      logger.warning('Localization not configured in pubspec.yaml');
      logger.info(
          'Add flutter_localizations to dependencies and configure l10n in pubspec.yaml');
      return;
    }

    // Ensure l10n directory exists
    final l10nDir = 'lib/l10n';
    FileUtils.ensureDirectoryExists(l10nDir);

    // Create template ARB file if specified and doesn't exist
    if (template != null) {
      await _createTemplateArb(template);
    }

    // Run flutter gen-l10n
    final result =
        await ProcessUtils.runFlutterCommand(['gen-l10n'], logger: logger);

    if (result.exitCode == 0) {
      logger.success('Localization files generated successfully');
      logger.info('Generated files are in $l10nDir directory');
    } else {
      logger.error(
          'Localization generation failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }

  bool _isL10nConfigured() {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) return false;

      final content = pubspecFile.readAsStringSync();
      return content.contains('flutter_localizations:') &&
          content.contains('generate: true');
    } catch (e) {
      return false;
    }
  }

  Future<void> _createTemplateArb(String templatePath) async {
    final file = File(templatePath);
    if (!file.existsSync()) {
      logger.info('Creating template ARB file: $templatePath');

      final templateContent = '''
{
  "@@locale": "en",
  "appTitle": "My App",
  "@appTitle": {
    "description": "The title of the application"
  },
  "welcome": "Welcome",
  "@welcome": {
    "description": "Welcome message"
  },
  "hello": "Hello {name}!",
  "@hello": {
    "description": "A greeting message",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
''';

      FileUtils.writeFile(templatePath, templateContent);
      logger.success('Template ARB file created: $templatePath');
    }
  }
}
