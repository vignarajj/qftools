import 'package:args/args.dart';
import '../utils/logger.dart';
import '../utils/file_utils.dart';

class InitCommand {
  final Logger logger;

  InitCommand(this.logger);

  Future<void> execute(ArgResults results) async {
    final force = results['force'] as bool;

    await _initializeProject(force: force);
  }

  Future<void> _initializeProject({bool force = false}) async {
    logger.step('Initializing project configurations...');

    await _createAnalysisOptions(force: force);
    await _createGitignore(force: force);
    await _createQfToolsConfig(force: force);

    logger.success('Project initialization completed');
  }

  Future<void> _createAnalysisOptions({bool force = false}) async {
    const filePath = 'analysis_options.yaml';

    if (!force && FileUtils.fileExists(filePath)) {
      logger.info('analysis_options.yaml already exists, skipping...');
      return;
    }

    const content = '''
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - "**/generated_plugin_registrant.dart"
    - "lib/l10n/*.dart"
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    # Error rules
    avoid_dynamic_calls: true
    avoid_empty_else: true
    avoid_print: true
    avoid_relative_lib_imports: true
    avoid_slow_async_io: true
    avoid_types_as_parameter_names: true
    cancel_subscriptions: true
    close_sinks: true
    comment_references: true
    control_flow_in_finally: true
    empty_statements: true
    hash_and_equals: true
    invariant_booleans: true
    iterable_contains_unrelated_type: true
    list_remove_unrelated_type: true
    literal_only_boolean_expressions: true
    no_adjacent_strings_in_list: true
    no_duplicate_case_values: true
    prefer_void_to_null: true
    test_types_in_equals: true
    throw_in_finally: true
    unnecessary_statements: true
    unrelated_type_equality_checks: true
    use_key_in_widget_constructors: true
    valid_regexps: true
    
    # Style rules
    always_declare_return_types: true
    avoid_catches_without_on_clauses: true
    avoid_catching_errors: true
    avoid_double_and_int_checks: true
    avoid_field_initializers_in_const_classes: true
    avoid_implementing_value_types: true
    avoid_js_rounded_ints: true
    avoid_positional_boolean_parameters: true
    avoid_private_typedef_functions: true
    avoid_redundant_argument_values: true
    avoid_returning_null_for_future: true
    avoid_setters_without_getters: true
    avoid_single_cascade_in_expression_statements: true
    avoid_unnecessary_containers: true
    avoid_unused_constructor_parameters: true
    avoid_void_async: true
    await_only_futures: true
    camel_case_extensions: true
    camel_case_types: true
    cast_nullable_to_non_nullable: true
    constant_identifier_names: true
    curly_braces_in_flow_control_structures: true
    depend_on_referenced_packages: true
    directives_ordering: true
    empty_catches: true
    empty_constructor_bodies: true
    file_names: true
    flutter_style_todos: true
    implementation_imports: true
    library_private_types_in_public_api: true
    non_constant_identifier_names: true
    null_check_on_nullable_type_parameter: true
    omit_local_variable_types: true
    one_member_abstracts: true
    only_throw_errors: true
    overridden_fields: true
    package_api_docs: true
    package_prefixed_library_names: true
    parameter_assignments: true
    prefer_adjacent_string_concatenation: true
    prefer_collection_literals: true
    prefer_conditional_assignment: true
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    prefer_constructors_over_static_methods: true
    prefer_contains: true
    prefer_equal_for_default_values: true
    prefer_expression_function_bodies: true
    prefer_final_fields: true
    prefer_final_in_for_each: true
    prefer_final_locals: true
    prefer_for_elements_to_map_fromIterable: true
    prefer_function_declarations_over_variables: true
    prefer_generic_function_type_aliases: true
    prefer_if_elements_to_conditional_expressions: true
    prefer_if_null_operators: true
    prefer_initializing_formals: true
    prefer_inlined_adds: true
    prefer_int_literals: true
    prefer_interpolation_to_compose_strings: true
    prefer_is_empty: true
    prefer_is_not_empty: true
    prefer_is_not_operator: true
    prefer_iterable_whereType: true
    prefer_null_aware_operators: true
    prefer_single_quotes: true
    prefer_spread_collections: true
    prefer_typing_uninitialized_variables: true
    provide_deprecation_message: true
    recursive_getters: true
    sized_box_for_whitespace: true
    slash_for_doc_comments: true
    sort_child_properties_last: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
    tighten_type_of_initializing_formals: true
    type_annotate_public_apis: true
    unawaited_futures: true
    unnecessary_brace_in_string_interps: true
    unnecessary_const: true
    unnecessary_getters_setters: true
    unnecessary_lambdas: true
    unnecessary_new: true
    unnecessary_null_aware_assignments: true
    unnecessary_null_checks: true
    unnecessary_null_in_if_null_operators: true
    unnecessary_nullable_for_final_variable_declarations: true
    unnecessary_overrides: true
    unnecessary_parenthesis: true
    unnecessary_raw_strings: true
    unnecessary_string_escapes: true
    unnecessary_string_interpolations: true
    unnecessary_this: true
    use_build_context_synchronously: true
    use_colored_box: true
    use_decorated_box: true
    use_full_hex_values_for_flutter_colors: true
    use_function_type_syntax_for_parameters: true
    use_if_null_to_convert_nulls_to_bools: true
    use_is_even_rather_than_modulo: true
    use_named_constants: true
    use_raw_strings: true
    use_rethrow_when_possible: true
    use_setters_to_change_properties: true
    use_string_buffers: true
    use_test_throws_matchers: true
    use_to_and_as_if_applicable: true
''';

    FileUtils.writeFile(filePath, content);
    logger.success('Created analysis_options.yaml');
  }

  Future<void> _createGitignore({bool force = false}) async {
    const filePath = '.gitignore';

    if (!force && FileUtils.fileExists(filePath)) {
      logger.info('.gitignore already exists, skipping...');
      return;
    }

    const content = '''
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# iOS related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/.last_build_id
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# macOS
**/macos/Flutter/GeneratedPluginRegistrant.swift

# Coverage
coverage/

# Generated files
**/*.g.dart
**/*.freezed.dart
**/*.mocks.dart
**/generated_plugin_registrant.dart

# Localization
lib/l10n/*.dart

# QfTools generated files
lib/assets/app_assets.dart

# Config files
.qftools.yaml
''';

    FileUtils.writeFile(filePath, content);
    logger.success('Created .gitignore');
  }

  Future<void> _createQfToolsConfig({bool force = false}) async {
    const filePath = '.qftools.yaml';

    if (!force && FileUtils.fileExists(filePath)) {
      logger.info('.qftools.yaml already exists, skipping...');
      return;
    }

    const content = '''
# QfTools Configuration
# This file contains settings for QfTools CLI

# Asset generation settings
assets:
  # Directories to scan for assets
  directories:
    - assets
    - lib/assets
    - images
    - fonts
  # Output file for generated asset constants
  output: lib/assets/app_assets.dart
  # Watch for changes in asset directories
  watch: false

# Build settings
build:
  # Default build mode (debug/release)
  mode: debug
  # Default flavor (if any)
  flavor: null
  # Additional build arguments
  args: []

# Test settings
test:
  # Generate coverage by default
  coverage: false
  # Default test group
  group: null
  # Additional test arguments
  args: []

# Format settings
format:
  # Check format by default
  check: false
  # Line length
  line_length: 80

# Clean settings
clean:
  # Use full clean by default
  full: false

# Localization settings
l10n:
  # Template ARB file path
  template: lib/l10n/app_en.arb
  # Output directory
  output: lib/l10n

# Documentation settings
docs:
  # Validate documentation coverage
  validate: false
  # Include private API in documentation
  include_private: false
''';

    FileUtils.writeFile(filePath, content);
    logger.success('Created .qftools.yaml configuration file');
  }
}
