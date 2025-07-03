# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-03

### Added
- Initial release of QfTools CLI
- **Asset Management**: Generate asset constants with `assets` command
  - Auto-generate `lib/assets/app_assets.dart` with constants for all assets
  - Watch mode for automatic regeneration on asset changes
  - Support for multiple asset directories (assets, lib/assets, images, fonts)
- **Project Cleaning**: Clean project with `clean` command
  - Standard mode: `flutter clean` + `flutter pub get`
  - Full mode: build_runner operations + standard clean
- **Code Formatting**: Format Dart code with `format` command
  - Format all Dart files in the project
  - Check mode for validation without applying changes
- **Build Management**: Build APKs with `build` command
  - Debug and release build modes
  - Build flavor support for multi-flavor projects
- **Localization**: Generate l10n files with `l10n` command
  - Integration with `flutter gen-l10n`
  - Template ARB file creation
- **Testing**: Run tests with `test` command
  - Unit and widget test execution
  - Coverage report generation
  - Test group filtering
- **Project Initialization**: Set up project configs with `init` command
  - Comprehensive `analysis_options.yaml` with strict linting rules
  - Flutter-specific `.gitignore` patterns
  - QfTools configuration file `.qftools.yaml`
- **Package Management**: Manage dependencies with `packages` command
  - Check for outdated packages
  - Add new packages with comma-separated syntax
- **Documentation**: Generate API docs with `docs` command
  - `dart doc` integration
  - Documentation coverage validation
- **Dependency Management**: Simple `get` command for `flutter pub get`
- **Global Options**: 
  - Verbose logging with `--verbose` flag
  - Comprehensive help system
- **Cross-platform Support**: Windows, macOS, and Linux compatibility
- **Modular Architecture**: Extensible command structure for future additions

### Dependencies
- `args: ^2.4.2` - Command-line argument parsing
- `path: ^1.8.3` - Cross-platform path handling
- `io: ^1.0.4` - I/O utilities
- `yaml: ^3.1.2` - YAML configuration support

### Development Dependencies
- `test: ^1.24.9` - Testing framework
- `flutter_lints: ^4.0.0` - Dart linting rules
- `flutter_test` - Flutter testing utilities

### Documentation
- Comprehensive README with usage examples
- Command reference documentation
- Configuration file documentation
- Development and contribution guidelines

### Testing
- Unit tests for all utility classes
- Integration tests for command functionality
- Cross-platform compatibility testing

## [Unreleased]

### Planned Features
- Configuration file loading from `.qftools.yaml`
- GitHub Actions CI/CD integration
- Additional build targets (iOS, Web, Desktop)
- Plugin system for custom commands
- Interactive mode for guided workflows
- Performance profiling integration
- Custom template support for asset generation
- Integration with popular Flutter packages
- Workspace management for multi-project setups
