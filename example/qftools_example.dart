import 'package:qf_tools/qftools.dart';

void main() {
  // Example usage of QfTools library
  print('QfTools - Flutter Project Management CLI');
  print('This is an example of how to use the QfTools library.');

  // Create a QfTools instance with verbose logging
  final qfTools = QfTools(verbose: true);

  // Example of using QfTools programmatically
  print('QfTools instance created with verbose logging: ${qfTools.verbose}');

  // Example of using the logger
  final logger = Logger(verbose: true);
  logger.info('QfTools initialized successfully');
  logger.success('Ready to streamline your Flutter development!');

  // Example of file utilities
  print('\nFile Utilities Example:');
  print('Asset path: ${FileUtils.filePathToAssetPath('assets/images/logo.png')}');
  print('Constant name: ${FileUtils.filePathToConstantName('assets/images/app_logo.png')}');

  // Example of checking Flutter project
  print('\nChecking if current directory is a Flutter project...');
  if (FileUtils.fileExists('pubspec.yaml')) {
    logger.success('Found pubspec.yaml - this appears to be a Dart/Flutter project');
  } else {
    logger.warning('No pubspec.yaml found - not a Dart/Flutter project');
  }

  // Example of new cleaner commands
  print('\nNew Cleaner Commands:');
  print('• Assets Cleaner: Use "qf_tools assets-cleaner --check" to find unused assets');
  print('• Assets Cleaner: Use "qf_tools assets-cleaner --clean" to remove unused assets');
  print('• Package Cleaner: Use "qf_tools packages-cleaner --check" to find unused packages');
  print('• Package Cleaner: Use "qf_tools packages-cleaner --clean" to remove unused packages');

  print('\nThese commands help maintain a clean and optimized Flutter project by:');
  print('- Identifying unused assets that can be safely removed');
  print('- Finding unused packages that add unnecessary weight to your project');
  print('- Providing interactive confirmation before removing files');
  print('- Showing storage space savings after cleanup');
}
