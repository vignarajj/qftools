import 'dart:io';
import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/process_utils.dart';

class BuildCommand {
  final Logger logger;

  BuildCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final release = results['release'] as bool;
    final flavor = results['flavor'] as String?;

    await _buildApk(release: release, flavor: flavor);
  }

  Future<void> _buildApk({bool release = false, String? flavor}) async {
    final mode = release ? 'release' : 'debug';
    final flavorText = flavor != null ? ' (flavor: $flavor)' : '';

    logger.step('Building APK in $mode mode$flavorText...');

    final args = ['build', 'apk'];

    if (release) {
      args.add('--release');
    } else {
      args.add('--debug');
    }

    if (flavor != null) {
      args.addAll(['--flavor', flavor]);
    }

    final result = await ProcessUtils.runFlutterCommand(args, logger: logger);

    if (result.exitCode == 0) {
      logger.success('APK build completed successfully');
      _showBuildOutputLocation(release: release, flavor: flavor);
    } else {
      logger.error('APK build failed with exit code ${result.exitCode}');
      exit(result.exitCode);
    }
  }

  void _showBuildOutputLocation({bool release = false, String? flavor}) {
    final mode = release ? 'release' : 'debug';
    final flavorPath = flavor != null ? '$flavor-' : '';
    final apkPath = 'build/app/outputs/flutter-apk/app-$flavorPath$mode.apk';

    if (File(apkPath).existsSync()) {
      logger.info('APK location: $apkPath');
    } else {
      logger.info(
          'APK built successfully, check build/app/outputs/flutter-apk/ directory');
    }
  }
}
