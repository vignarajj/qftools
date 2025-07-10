#!/bin/bash

# Enhanced script to help organize imports in a Flutter project with barrel file support
# Usage: ./organize_imports.sh [path/to/dart/file.dart] [--barrel]
# If no arguments are provided, it will list all .dart files in the lib/ directory (and subdirectories) for selection.

function organize_imports() {
  local file=$1
  local use_barrel_files=$2

  # Check if file exists
  if [ ! -f "$file" ]; then
    echo "File not found: $file"
    return 1
  fi

  # Temporary file
  local temp_file="${file}.tmp"

  # Extract imports
  local dart_imports=$(grep -E "^import 'dart:.*';" "$file" | sort)
  local flutter_imports=$(grep -E "^import 'package:flutter/.*';" "$file" | sort)
  local flutter_packages=$(grep -E "^import 'package:flutter_.*';" "$file" | sort)
  local third_party_imports=$(grep -E "^import 'package:.*';" "$file" | grep -v "^import 'package:flutter" | sort)
  local project_imports=$(grep -E "^import '\.\./.*';" "$file" | sort)

  # Remove all import lines from original file
  grep -v -E "^import .*;" "$file" > "$temp_file"

  # Directory of the file
  local dir_of_file=$(dirname "$file")

  # Add organized imports at the beginning of the file
  {
    if [ -n "$dart_imports" ]; then
      echo "// Dart imports"
      echo "$dart_imports"
      echo ""
    fi

    if [ -n "$flutter_imports" ]; then
      echo "// Flutter core imports"
      echo "$flutter_imports"
      echo ""
    fi

    if [ -n "$flutter_packages" ]; then
      echo "// Flutter packages"
      echo "$flutter_packages"
      echo ""
    fi

    if [ -n "$third_party_imports" ]; then
      echo "// Third party packages"
      echo "$third_party_imports"
      echo ""
    fi

    if [ "$use_barrel_files" = true ]; then
      # Extract unique directories from project imports (assuming format '../dir/...')
      local unique_dirs=$(echo "$project_imports" | grep -E "^import '\.\./[^/]+/" | sed -E "s/^import '\.\.\/([^/]+)\/.*';/\1/" | sort -u)

      # Handle imports dynamically based on directory and barrel file existence
      for dir in $unique_dirs; do
        local barrel_path="${dir_of_file}/../${dir}/${dir}.dart"
        local dir_imports=$(echo "$project_imports" | grep "^import '\.\./${dir}/" | sort)

        local first_char=$(echo "${dir:0:1}" | tr 'a-z' 'A-Z')
        local rest_chars=$(echo "${dir:1}" | tr 'A-Z' 'a-z')
        local capitalized_dir="${first_char}${rest_chars}"

        if [ -f "$barrel_path" ] && [ -n "$dir_imports" ]; then
          echo "// ${capitalized_dir}"
          echo "import '../${dir}/${dir}.dart';"
          echo ""
        else
          if [ -n "$dir_imports" ]; then
            echo "// ${capitalized_dir}"
            echo "$dir_imports"
            echo ""
          fi
        fi
      done

      # Handle other project imports (those without a sub-directory, like '../file.dart')
      local other_project_imports=$(echo "$project_imports" | grep -E "^import '\.\./[^/]+\.dart';" | sort)
      if [ -n "$other_project_imports" ]; then
        echo "// Other project imports"
        echo "$other_project_imports"
        echo ""
      fi
    else
      # When not using barrel files, add all project imports together
      if [ -n "$project_imports" ]; then
        echo "// Project imports"
        echo "$project_imports"
        echo ""
      fi
    fi

    cat "$temp_file"
  } > "$file"

  # Clean up
  rm "$temp_file"

  echo "Organized imports in $file"
}

# Main execution
file=""
use_barrel_files=false

if [ $# -ge 1 ]; then
  file=$1
  if [ $# -ge 2 ] && [ "$2" = "--barrel" ]; then
    use_barrel_files=true
  fi
else
  # Interactive mode: list all .dart files in lib/ and subdirectories
  echo "Searching for .dart files in lib/ directory..."
  dart_files=()
  while IFS= read -r line; do
    dart_files+=("$line")
  done < <(find lib -type f -name "*.dart" 2>/dev/null)

  if [ ${#dart_files[@]} -eq 0 ]; then
    echo "No .dart files found in lib/ directory."
    exit 1
  fi

  echo "Select a file to organize imports:"
  select file in "${dart_files[@]}"; do
    if [ -n "$file" ]; then
      break
    else
      echo "Invalid selection. Please try again."
    fi
  done

  # Ask for barrel option
  read -p "Use barrel files? (y/n): " use_barrel_option
  if [[ "$use_barrel_option" =~ ^[Yy]$ ]]; then
    use_barrel_files=true
  fi
fi

if [ -z "$file" ]; then
  echo "No file selected. Usage: $0 [path/to/dart/file.dart] [--barrel]"
  echo "Options:"
  echo "  --barrel    Use barrel files (like core/core.dart, models/models.dart, etc.) where they exist in the app structure."
  exit 1
fi

organize_imports "$file" "$use_barrel_files"