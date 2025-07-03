# QfTools - Flutter Project Management CLI

A comprehensive command-line interface tool for streamlining Flutter project management and development workflows.

## Features

- **Asset Management**: Generate asset constants and watch for changes
- **Asset Cleaning**: Check and clean unused assets from your project
- **Project Cleaning**: Standard and full project cleaning with build_runner support
- **Code Formatting**: Format Dart code with validation options
- **Build Management**: Build APKs with release mode and flavor support
- **Localization**: Generate localization files using flutter gen-l10n
- **Testing**: Run tests with coverage reporting and group filtering
- **Project Initialization**: Set up project configurations and linting rules
- **Package Management**: Manage dependencies and check for outdated packages
- **Package Cleaning**: Check and clean unused packages from your project
- **Documentation**: Generate API documentation with validation

## Installation

### From pub.dev

```bash
dart pub global activate qf_tools
```

### From source

```bash
git clone https://github.com/vignarajj/qftools.git
cd qf_tools
dart pub global activate --source path .
```

## Usage

### Basic Commands

```bash
# Generate asset constants
qf_tools assets

# Watch for asset changes
qf_tools assets --watch

# Check for unused assets
qf_tools assets-cleaner --check

# Clean unused assets
qf_tools assets-cleaner --clean

# Run flutter pub get
qf_tools get

# Clean project (flutter clean + pub get)
qf_tools clean

# Full clean with build_runner
qf_tools clean --full

# Format code
qf_tools format

# Check formatting without applying changes
qf_tools format --check

# Build APK in debug mode
qf_tools build

# Build APK in release mode
qf_tools build --release

# Build APK with flavor
qf_tools build --release --flavor production

# Generate localization files
qf_tools l10n

# Generate l10n with custom template
qf_tools l10n --template lib/l10n/app_en.arb

# Run tests
qf_tools test

# Run tests with coverage
qf_tools test --coverage

# Run specific test group
qf_tools test --group widgets

# Initialize project configurations
qf_tools init

# Force overwrite existing files
qf_tools init --force

# Check for outdated packages
qf_tools packages --outdated

# Add new packages
qf_tools packages --add "provider,dio,flutter_bloc"

# Check for unused packages
qf_tools packages-cleaner --check

# Clean unused packages
qf_tools packages-cleaner --clean

# Generate API documentation
qf_tools docs

# Validate documentation coverage
qf_tools docs --validate
```

### Global Options

```bash
# Enable verbose logging
qf_tools <command> --verbose

# Show help
qf_tools --help
qf_tools <command> --help
```

## Commands Reference

### `assets`
Generate asset constants in `lib/assets/app_assets.dart`

**Options:**
- `--watch`: Watch for asset changes and regenerate automatically

**Example:**
```bash
qf_tools assets --watch
```

### `assets-cleaner`
Check and clean unused assets from your Flutter project

**Options:**
- `--check`: Check for unused assets without removing them
- `--clean`: Remove unused assets from the project

**Features:**
- Scans common asset directories (assets, lib/assets, images, fonts)
- Checks for asset references in Dart code and pubspec.yaml
- Shows file size savings before deletion
- Interactive confirmation before removing files
- Supports various asset reference patterns

**Example:**
```bash
# Check for unused assets
qf_tools assets-cleaner --check

# Remove unused assets (with confirmation)
qf_tools assets-cleaner --clean
```

### `get`
Run `flutter pub get` to install dependencies

### `clean`
Clean the project and reinstall dependencies

**Options:**
- `--full`: Perform full clean including build_runner operations

**Modes:**
- Standard: `flutter clean` + `flutter pub get`
- Full: `build_runner clean` + `build_runner build --delete-conflicting-outputs` + `flutter clean` + `flutter pub get`

### `format`
Format Dart code using `dart format`

**Options:**
- `--check`: Check formatting without applying changes

### `build`
Build APK files

**Options:**
- `--release`: Build in release mode (default: debug)
- `--flavor <flavor>`: Specify build flavor

### `l10n`
Generate localization files using `flutter gen-l10n`

**Options:**
- `--template <path>`: Specify ARB template file path

**Requirements:**
- `flutter_localizations` dependency in pubspec.yaml
- `generate: true` in pubspec.yaml

### `test`
Run unit and widget tests

**Options:**
- `--coverage`: Generate coverage reports
- `--group <group>`: Run specific test groups

### `init`
Initialize project configurations

**Options:**
- `--force`: Overwrite existing files

**Creates:**
- `analysis_options.yaml`: Comprehensive linting rules
- `.gitignore`: Flutter-specific ignore patterns
- `.qftools.yaml`: QfTools configuration file

### `packages`
Manage project dependencies

**Options:**
- `--outdated`: Check for outdated packages
- `--add <packages>`: Add new packages (comma-separated)

### `packages-cleaner`
Check and clean unused packages from your Flutter project

**Options:**
- `--check`: Check for unused packages without removing them
- `--clean`: Remove unused packages from the project

**Features:**
- Analyzes dependencies and dev_dependencies from pubspec.yaml
- Scans Dart code for import/export statements
- Protects system packages (flutter, flutter_test, etc.)
- Checks for package references in assets and fonts sections
- Interactive confirmation before removing packages
- Automatically runs `flutter pub get` after cleanup

**Example:**
```bash
# Check for unused packages
qf_tools packages-cleaner --check

# Remove unused packages (with confirmation)
qf_tools packages-cleaner --clean
```

### `docs`
Generate API documentation

**Options:**
- `--validate`: Validate documentation coverage

## Configuration

QfTools supports a `.qftools.yaml` configuration file for customizing default behavior:

```yaml
# Asset generation settings
assets:
  directories:
    - assets
    - lib/assets
    - images
    - fonts
  output: lib/assets/app_assets.dart
  watch: false

# Cleaner settings
cleaners:
  assets:
    # Additional asset directories to scan
    directories:
      - custom_assets
    # File extensions to include
    extensions:
      - .png
      - .jpg
      - .jpeg
      - .gif
      - .svg
      - .webp
      - .ttf
      - .otf
  packages:
    # Additional system packages to protect
    protected_packages:
      - custom_framework
      - internal_package

# Build settings
build:
  default_mode: debug
  default_flavor: development

# Test settings
test:
  coverage: true
  coverage_exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

# Documentation settings
docs:
  output: doc/api
  validate: true
```

## Best Practices

### Asset Management
- Use the `assets-cleaner` regularly to keep your project lean
- Organize assets in standard directories (assets/, images/, fonts/)
- Use consistent naming conventions for assets
- Run `qf_tools assets --watch` during development for automatic constant generation

### Package Management
- Run `packages-cleaner --check` before releases to identify unused dependencies
- Use `packages --outdated` to keep dependencies up-to-date
- Review package removals carefully before confirming cleanup

### Project Maintenance
- Use `qf_tools clean --full` when build issues occur
- Run `qf_tools format` before committing code
- Use `qf_tools test --coverage` to maintain code quality
- Initialize projects with `qf_tools init` for consistent configuration

## Troubleshooting

### Common Issues

**Asset constants not generated:**
- Ensure assets are in supported directories
- Check file permissions
- Verify pubspec.yaml asset declarations

**Unused assets not detected:**
- Some dynamic asset loading patterns may not be detected
- Check for string interpolation in asset paths
- Verify asset references in platform-specific code

**Package cleanup removes needed packages:**
- Check if packages are used via platform channels
- Verify packages used in build scripts or CI/CD
- Review packages used in code generation

### Getting Help

```bash
# Show general help
qf_tools --help

# Show command-specific help
qf_tools <command> --help

# Enable verbose logging for debugging
qf_tools <command> --verbose
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Platform Support

QfTools is a Dart CLI tool and works on all major platforms:

- **macOS**
- **Linux**
- **Windows**

You only need the Dart SDK (>=3.0.0 <4.0.0) installed. For Flutter-specific features, ensure Flutter is installed and available in your PATH.
