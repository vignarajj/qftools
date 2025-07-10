# QfTools Plugin

A comprehensive Flutter development toolkit available as plugins for VSCode and Android Studio/IntelliJ IDEA.

## Project Structure

```
qftool_plugin/
├── android-studio-plugin/     # IntelliJ Platform plugin for Android Studio/IntelliJ
├── vscode-extension/          # VSCode extension
├── shared/
│   └── qftools-core/         # Shared Dart package with core functionality
├── docs/                     # Documentation and guides
├── assets/                   # Shared assets (icons, images)
└── README.md                # This file
```

## Features

QfTools provides the following features through context menus and commands:

### Asset Management
- **Generate Assets**: Create asset declarations for pubspec.yaml
- **Clean Unused Assets**: Remove unused asset files from project

### Code Organization  
- **Organize Imports**: Categorize and sort Dart imports
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

## Plugins

### VSCode Extension
Located in `vscode-extension/`. Provides:
- Context menu integration
- Command palette commands
- Progress indicators
- Configuration options

### Android Studio Plugin
Located in `android-studio-plugin/`. Provides:
- Tool window integration
- Context menu actions
- Background task support
- IntelliJ Platform integration

## Development

### Prerequisites
- Dart SDK 3.0+
- Node.js 18+ (for VSCode extension)
- Java 17+ (for Android Studio plugin)
- Gradle 8+ (for Android Studio plugin)

### Setup
1. Clone this repository
2. Set up each plugin environment:
   - VSCode: `cd vscode-extension && npm install`
   - Android Studio: `cd android-studio-plugin && ./gradlew build`
   - Core: `cd shared/qftools-core && dart pub get`

### Building
- VSCode: `npm run package`
- Android Studio: `./gradlew buildPlugin`

### Testing
- VSCode: `npm test`
- Android Studio: `./gradlew test`
- Core: `dart test`

## Installation

### VSCode
1. Download from VSCode Marketplace
2. Or install VSIX file: `code --install-extension qftools.vsix`

### Android Studio
1. Download from JetBrains Marketplace
2. Or install manually: Settings → Plugins → Install from disk

## License

MIT License - see LICENSE file for details.

## Contributing

See CONTRIBUTING.md for development guidelines and contribution process.
