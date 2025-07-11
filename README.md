# QfTools - Flutter Project Management CLI

A comprehensive command-line interface tool for streamlining Flutter project management and development workflows.

## Features

QfTools provides the following features through context menus and commands:

## Installation

### From pub.dev

```bash
dart pub global activate qftools
```

### From source

```bash
git clone https://github.com/vignarajj/qftools.git
cd qftools
dart pub global activate --source path .
```

## Usage

### Basic Commands

```bash
# Generate asset constants
qftools assets

# Watch for asset changes
qftools assets --watch

# Check for unused assets
qftools assets-cleaner --check

# Clean unused assets
qftools assets-cleaner --clean

# Run flutter pub get
qftools get

# Clean project (flutter clean + pub get)
qftools clean

# Full clean with build_runner
qftools clean --full

# Format code
qftools format

# Check formatting without applying changes
qftools format --check

# Build APK in debug mode
qftools build

# Build APK in release mode
qftools build --release

# Build APK with flavor
qftools build --release --flavor production

# Generate localization files
qftools l10n

# Generate l10n with custom template
qftools l10n --template lib/l10n/app_en.arb

# Run tests
qftools test

# Run tests with coverage
qftools test --coverage

# Run specific test group
qftools test --group widgets

# Initialize project configurations
qftools init

# Force overwrite existing files
qftools init --force

# Check for outdated packages
qftools packages --outdated

# Add new packages
qftools packages --add "provider,dio,flutter_bloc"

# Check for unused packages
qftools packages-cleaner --check

# Clean unused packages
qftools packages-cleaner --clean

# Generate API documentation
qftools docs

# Validate documentation coverage
qftools docs --validate

# Organize the imports in Dart files
qftools organize-imports



```

### Global Options

```bash
# Enable verbose logging
qftools <command> --verbose

# Show help
qftools --help
qftools <command> --help
```

## Commands Reference

### `assets`
Generate asset constants in `lib/assets/app_assets.dart`

**Options:**
- `--watch`: Watch for asset changes and regenerate automatically

**Example:**
```bash
qftools assets --watch
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
qftools assets-cleaner --check

# Remove unused assets (with confirmation)
qftools assets-cleaner --clean
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

### Asset Management
- **Generate Assets**: Create asset declarations for pubspec.yaml
- **Clean Unused Assets**: Remove unused asset files from project

### Code Organization  
- **Organize Imports**: Categorize and sort Dart imports
  - Works in any directory containing Dart files (not just Flutter projects)
  - Interactive file selection mode with numbered list
  - Support for barrel file optimization
  - Run from any folder with `qftools organize-imports`
  - Specify target directory with `qftools organize-imports some/directory`
  - Direct file mode with `qftools organize-imports path/to/file.dart`
- **Create Barrel Files**: Generate index files for directory exports
- **Format Code**: Apply Dart formatting standards

### Package Management
- **Get Packages**: Run `flutter pub get` with dependency analysis
- **Clean Packages**: Remove pub cache and reinstall dependencies
- **Update Packages**: Check and update package dependencies

### Project Operations
- **Clean Project**: Remove build artifacts and temporary files
- **Build Project**: Execute Flutter build commands
- **Run Tests**: Execute test suites with coverage
- **Generate Documentation**: Create API documentation
- **Generate Localizations**: Process l10n files
- **Initialize Project**: Set up new Flutter project structure

## License

MIT License - see LICENSE file for details.

## Contributing

See CONTRIBUTING.md for development guidelines and contribution process.
