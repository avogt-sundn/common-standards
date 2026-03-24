#!/usr/bin/env bash
# sync-standards.sh — Transfer common-standards formatting/linting config into another git repo.
#
# Usage: bin/sync-standards.sh TARGET_DIR [--dry-run]
#
# Assumptions:
#   - common-standards and the target repo are cloned side-by-side on the local machine
#   - The target repo is already populated with code and config files
#   - The script creates a new branch in the target repo for review before committing

set -euo pipefail

# ── Constants ──────────────────────────────────────────────────────────────────

STANDARDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRANCH_NAME="sync-standards-$(date +%Y-%m-%d)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Summary tracking
CREATED=()
UPDATED=()
SKIPPED=()
INJECTED=()

# ── Argument parsing ───────────────────────────────────────────────────────────

TARGET_DIR=""
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --*) echo "Unknown flag: $arg" >&2; exit 1 ;;
    *) TARGET_DIR="$arg" ;;
  esac
done

if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: $(basename "$0") TARGET_DIR [--dry-run]" >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# ── Validation ─────────────────────────────────────────────────────────────────

if [[ ! -d "$TARGET_DIR" ]]; then
  echo -e "${RED}Error:${RESET} Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

if ! git -C "$TARGET_DIR" rev-parse --git-dir &>/dev/null; then
  echo -e "${RED}Error:${RESET} Target directory is not a git repository: $TARGET_DIR" >&2
  exit 1
fi

# ── Git branch in target ───────────────────────────────────────────────────────

setup_branch() {
  if $DRY_RUN; then
    echo -e "${CYAN}[dry-run]${RESET} Would create branch '$BRANCH_NAME' in target repo"
    return
  fi

  local current_branch
  current_branch=$(git -C "$TARGET_DIR" branch --show-current 2>/dev/null || echo "")

  if [[ "$current_branch" == "$BRANCH_NAME" ]]; then
    echo -e "${CYAN}Already on branch '$BRANCH_NAME'${RESET}"
    return
  fi

  if git -C "$TARGET_DIR" show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo -e "${CYAN}Switching to existing branch '$BRANCH_NAME'${RESET}"
    git -C "$TARGET_DIR" checkout "$BRANCH_NAME"
  else
    echo -e "${GREEN}Creating branch '$BRANCH_NAME' in target repo${RESET}"
    git -C "$TARGET_DIR" checkout -b "$BRANCH_NAME"
  fi
}

# ── Core sync primitive ────────────────────────────────────────────────────────

# sync_file REL_PATH [SOURCE_OVERRIDE]
# Syncs STANDARDS_DIR/REL_PATH → TARGET_DIR/REL_PATH
# Optional SOURCE_OVERRIDE: use this file as source instead (e.g. for transformed files)
sync_file() {
  local rel="$1"
  local src="${2:-$STANDARDS_DIR/$rel}"
  local dst="$TARGET_DIR/$rel"

  if [[ ! -f "$src" ]]; then
    echo -e "${YELLOW}Warning:${RESET} Source not found, skipping: $rel"
    SKIPPED+=("$rel (source missing)")
    return
  fi

  if [[ ! -f "$dst" ]]; then
    # File doesn't exist in target — copy it
    if $DRY_RUN; then
      echo -e "${GREEN}[dry-run] would create:${RESET} $rel"
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo -e "${GREEN}created:${RESET} $rel"
    fi
    CREATED+=("$rel")
    return
  fi

  if diff -q "$src" "$dst" &>/dev/null; then
    # Identical — nothing to do
    SKIPPED+=("$rel (identical)")
    return
  fi

  # File differs — show diff and prompt
  echo ""
  echo -e "${YELLOW}── $rel differs ──────────────────────────────────────────────────${RESET}"
  diff --color=auto "$dst" "$src" || true
  echo ""

  if $DRY_RUN; then
    echo -e "${YELLOW}[dry-run] would prompt to overwrite:${RESET} $rel"
    UPDATED+=("$rel")
    return
  fi

  local choice
  while true; do
    read -r -p "  [o]verwrite / [s]kip / [b]ackup+overwrite? " choice || true
    case "$choice" in
      o|O)
        cp "$src" "$dst"
        echo -e "${GREEN}updated:${RESET} $rel"
        UPDATED+=("$rel")
        return
        ;;
      s|S)
        echo -e "${CYAN}skipped:${RESET} $rel"
        SKIPPED+=("$rel (user skipped)")
        return
        ;;
      b|B)
        local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$dst" "$backup"
        cp "$src" "$dst"
        echo -e "${GREEN}updated:${RESET} $rel  (backup: $(basename "$backup"))"
        UPDATED+=("$rel")
        return
        ;;
      *) echo "  Enter o, s, or b." ;;
    esac
  done
}

# ── Config sets ────────────────────────────────────────────────────────────────

sync_universal() {
  echo -e "\n${BOLD}── Universal ─────────────────────────────────────────────────────${RESET}"
  sync_file ".editorconfig"
  sync_file ".gitattributes"
}

sync_java() {
  echo -e "\n${BOLD}── Java ──────────────────────────────────────────────────────────${RESET}"
  sync_file ".java-config/Common-Standards-Eclipse-Code-Profile.xml"
  sync_file ".java-config/Common-Standards-Eclipse-Clean-Up-Rules.xml"
  sync_file ".java-config/README.md"
  inject_maven_plugins
}

sync_frontend() {
  echo -e "\n${BOLD}── Frontend ──────────────────────────────────────────────────────${RESET}"
  sync_file ".prettierrc"
  sync_file ".prettierignore"
  sync_eslint_config
  print_npm_instructions
}

sync_intellij() {
  echo -e "\n${BOLD}── IntelliJ (.idea/) ─────────────────────────────────────────────${RESET}"
  sync_file ".idea/.gitignore"
  sync_file ".idea/eclipseCodeFormatter.xml"
  sync_file ".idea/saveActions.xml"
  sync_file ".idea/externalDependencies.xml"
  sync_file ".idea/prettier.xml"
  sync_file ".idea/codeStyles/Project.xml"
  sync_file ".idea/codeStyles/codeStyleConfig.xml"
  sync_file ".idea/inspectionProfiles/Project_Default.xml"
  sync_file ".idea/inspectionProfiles/profiles_settings.xml"
}

sync_vscode() {
  echo -e "\n${BOLD}── VS Code (.vscode/) ────────────────────────────────────────────${RESET}"
  sync_file ".vscode/settings.json"
  sync_file ".vscode/extensions.json"
}

sync_neovim() {
  echo -e "\n${BOLD}── Neovim ────────────────────────────────────────────────────────${RESET}"
  sync_file ".nvim.lua"
}

sync_devcontainer() {
  echo -e "\n${BOLD}── Devcontainer ──────────────────────────────────────────────────${RESET}"
  sync_file ".devcontainer/devcontainer.json"
  sync_file ".devcontainer/Dockerfile"
  sync_file ".devcontainer/scripts/postCreateCommand.sh"
  sync_file ".devcontainer/scripts/postCreate-Maven.sh"
  sync_file ".devcontainer/scripts/postCreate-Quarkus.sh"
  sync_file ".devcontainer/scripts/postCreate-Claude.sh"
  sync_file ".devcontainer/scripts/start-claude.sh"
  sync_file ".devcontainer/scripts/dps"
}

# ── Maven plugin injection ─────────────────────────────────────────────────────

inject_maven_plugins() {
  # Find pom.xml files in target (max depth 2, skip target/ and node_modules/)
  local pom_files
  mapfile -t pom_files < <(find "$TARGET_DIR" -maxdepth 2 -name "pom.xml" \
    ! -path "*/target/*" ! -path "*/node_modules/*" | sort)

  if [[ ${#pom_files[@]} -eq 0 ]]; then
    echo -e "${CYAN}No pom.xml found in target — skipping Maven plugin injection${RESET}"
    return
  fi

  local pom_path
  if [[ ${#pom_files[@]} -eq 1 ]]; then
    pom_path="${pom_files[0]}"
    echo "Found pom.xml: ${pom_path#"$TARGET_DIR/"}"
  else
    echo "Multiple pom.xml files found:"
    for i in "${!pom_files[@]}"; do
      echo "  [$((i+1))] ${pom_files[$i]#"$TARGET_DIR/"}"
    done
    local choice
    while true; do
      read -r -p "  Which pom.xml to update? [1-${#pom_files[@]}]: " choice || true
      if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#pom_files[@]} )); then
        pom_path="${pom_files[$((choice-1))]}"
        break
      fi
      echo "  Enter a number between 1 and ${#pom_files[@]}."
    done
  fi

  # Compute relative path from pom.xml dir to .java-config/
  local pom_dir
  pom_dir="$(dirname "$pom_path")"
  local config_rel_path
  config_rel_path="$(python3 -c "
import os, sys
pom_dir = sys.argv[1]
java_config = os.path.join(sys.argv[2], '.java-config')
rel = os.path.relpath(java_config, pom_dir)
print(rel)
" "$pom_dir" "$TARGET_DIR" 2>/dev/null)" || {
    # Fallback without python3
    config_rel_path="\${project.basedir}/../.java-config"
    echo -e "${YELLOW}Warning:${RESET} Could not compute relative path. Using default: $config_rel_path"
  }
  local config_file="\${project.basedir}/${config_rel_path}/Common-Standards-Eclipse-Code-Profile.xml"

  # Check if plugins already exist
  local has_formatter has_impsort
  has_formatter=$(grep -c "formatter-maven-plugin" "$pom_path" 2>/dev/null || echo "0")
  has_impsort=$(grep -c "impsort-maven-plugin" "$pom_path" 2>/dev/null || echo "0")

  if [[ "$has_formatter" -gt 0 ]] || [[ "$has_impsort" -gt 0 ]]; then
    echo -e "${YELLOW}Maven plugins already present in ${pom_path#"$TARGET_DIR/"} — showing diff${RESET}"
    echo -e "  formatter-maven-plugin: $( [[ "$has_formatter" -gt 0 ]] && echo 'found' || echo 'missing')"
    echo -e "  impsort-maven-plugin:   $( [[ "$has_impsort" -gt 0 ]] && echo 'found' || echo 'missing')"
    echo ""
    if ! $DRY_RUN; then
      local choice
      read -r -p "  Existing plugins detected. [v]iew standard config / [s]kip injection? " choice || true
      case "$choice" in
        v|V) ;;  # fall through to print the standard config below
        *)
          echo -e "${CYAN}skipped:${RESET} Maven plugin injection"
          SKIPPED+=("pom.xml Maven plugins (already present)")
          return
          ;;
      esac
    fi
    # Print the standard config for reference
    echo -e "${CYAN}Standard plugin config (for manual reference):${RESET}"
    build_plugin_xml "$config_file"
    SKIPPED+=("pom.xml Maven plugins (shown for reference)")
    return
  fi

  # Check that <plugins> section exists
  if ! grep -q "</plugins>" "$pom_path"; then
    echo -e "${YELLOW}Warning:${RESET} No </plugins> tag found in ${pom_path#"$TARGET_DIR/"}."
    echo "  Please add the plugins section manually. Standard config:"
    build_plugin_xml "$config_file"
    SKIPPED+=("pom.xml Maven plugins (no <plugins> section)")
    return
  fi

  if $DRY_RUN; then
    echo -e "${GREEN}[dry-run] would inject formatter-maven-plugin + impsort-maven-plugin into:${RESET} ${pom_path#"$TARGET_DIR/"}"
    INJECTED+=("pom.xml Maven plugins")
    return
  fi

  # Inject plugins before </plugins>
  local plugin_xml
  plugin_xml="$(build_plugin_xml "$config_file")"

  # Use sed to insert before the last </plugins> tag
  # macOS sed needs '' after -i; GNU sed works with -i '' too
  sed -i.bak "s|</plugins>|${plugin_xml//$'\n'/\\n}\n        </plugins>|" "$pom_path" 2>/dev/null || {
    # Fallback: python3-based insertion (handles multiline better)
    python3 - "$pom_path" "$config_file" <<'PYEOF'
import sys, re

pom_path = sys.argv[1]
config_file = sys.argv[2]

with open(pom_path, 'r') as f:
    content = f.read()

plugin_xml = f"""            <plugin>
                <groupId>net.revelc.code.formatter</groupId>
                <artifactId>formatter-maven-plugin</artifactId>
                <version>2.29.0</version>
                <configuration>
                    <configFile>{config_file}</configFile>
                    <encoding>UTF-8</encoding>
                    <directories>
                        <directory>${{project.build.sourceDirectory}}</directory>
                        <directory>${{project.build.directory}}/generated-sources</directory>
                    </directories>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>format</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>net.revelc.code</groupId>
                <artifactId>impsort-maven-plugin</artifactId>
                <version>1.9.0</version>
                <configuration>
                    <groups>java,javax,org,com,</groups>
                    <staticGroups>*</staticGroups>
                    <staticAfter>false</staticAfter>
                    <removeUnused>true</removeUnused>
                    <compliance>17</compliance>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>sort</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>"""

# Insert before last </plugins>
last_plugins = content.rfind('</plugins>')
if last_plugins == -1:
    print("ERROR: </plugins> not found", file=sys.stderr)
    sys.exit(1)

new_content = content[:last_plugins] + plugin_xml + '\n        ' + content[last_plugins:]
with open(pom_path, 'w') as f:
    f.write(new_content)
PYEOF
  }

  echo -e "${GREEN}injected:${RESET} formatter-maven-plugin + impsort-maven-plugin into ${pom_path#"$TARGET_DIR/"}"
  INJECTED+=("pom.xml Maven plugins → ${pom_path#"$TARGET_DIR/"}")
}

# Prints the standard plugin XML block to stdout
build_plugin_xml() {
  local config_file="$1"
  cat <<EOF
            <plugin>
                <groupId>net.revelc.code.formatter</groupId>
                <artifactId>formatter-maven-plugin</artifactId>
                <version>2.29.0</version>
                <configuration>
                    <configFile>${config_file}</configFile>
                    <encoding>UTF-8</encoding>
                    <directories>
                        <directory>\${project.build.sourceDirectory}</directory>
                        <directory>\${project.build.directory}/generated-sources</directory>
                    </directories>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>format</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>net.revelc.code</groupId>
                <artifactId>impsort-maven-plugin</artifactId>
                <version>1.9.0</version>
                <configuration>
                    <groups>java,javax,org,com,</groups>
                    <staticGroups>*</staticGroups>
                    <staticAfter>false</staticAfter>
                    <removeUnused>true</removeUnused>
                    <compliance>17</compliance>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>sort</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
EOF
}

# ── ESLint config with prefix substitution ─────────────────────────────────────

sync_eslint_config() {
  # Auto-detect frontend dir
  local frontend_dir=""
  local angular_json
  mapfile -t angular_json < <(find "$TARGET_DIR" -maxdepth 2 -name "angular.json" \
    ! -path "*/node_modules/*" | sort)

  if [[ ${#angular_json[@]} -eq 1 ]]; then
    frontend_dir="$(dirname "${angular_json[0]}")"
    local rel="${frontend_dir#"$TARGET_DIR/"}"
    read -r -p "  Frontend dir detected: ${rel:-.} — confirm? [Enter to accept / type path]: " user_input || true
    if [[ -n "$user_input" ]]; then
      frontend_dir="$TARGET_DIR/$user_input"
    fi
  elif [[ ${#angular_json[@]} -gt 1 ]]; then
    echo "  Multiple angular.json found:"
    for i in "${!angular_json[@]}"; do
      echo "    [$((i+1))] ${angular_json[$i]#"$TARGET_DIR/"}"
    done
    local choice
    read -r -p "  Which frontend dir? [1-${#angular_json[@]}]: " choice || true
    frontend_dir="$(dirname "${angular_json[$((choice-1))]}")"
  else
    echo -e "  ${YELLOW}No angular.json found.${RESET}"
    read -r -p "  Enter frontend directory path relative to target root (or leave empty to skip): " user_input || true
    if [[ -z "$user_input" ]]; then
      SKIPPED+=("eslint.config.mjs (no frontend dir)")
      return
    fi
    frontend_dir="$TARGET_DIR/$user_input"
  fi

  # Prompt for Angular prefix
  local prefix
  read -r -p "  Angular component prefix [default: app]: " prefix || true
  prefix="${prefix:-app}"

  # Create transformed copy in a temp file
  local src="$STANDARDS_DIR/frontend/eslint.config.mjs"
  local tmp
  tmp="$(mktemp)"
  sed "s/prefix: 'app'/prefix: '${prefix}'/g" "$src" > "$tmp"

  local rel_dst="${frontend_dir#"$TARGET_DIR/"}/eslint.config.mjs"
  sync_file "$rel_dst" "$tmp"
  rm -f "$tmp"
}

# ── npm instructions (printed only) ───────────────────────────────────────────

print_npm_instructions() {
  echo ""
  echo -e "${BOLD}── Frontend: manual steps required ──────────────────────────────${RESET}"
  echo -e "  Add to ${CYAN}package.json${RESET} scripts:"
  echo '    "lint": "eslint",'
  echo '    "format:check": "prettier --check \"src/**/*.{ts,html,css,scss}\"",'
  echo '    "format:fix": "prettier --write \"src/**/*.{ts,html,css,scss}\""'
  echo ""
  echo -e "  Install devDependencies:"
  echo '    npm install --save-dev prettier eslint @eslint/js angular-eslint typescript-eslint'
  echo ""
}

# ── Interactive menu ───────────────────────────────────────────────────────────

show_menu() {
  echo ""
  echo -e "${BOLD}Select config sets to transfer:${RESET}"
  echo "  [1] Universal    — .editorconfig, .gitattributes"
  echo "  [2] Java         — .java-config/, Maven plugin injection"
  echo "  [3] Frontend     — .prettierrc, .prettierignore, eslint.config.mjs"
  echo "  [4] IntelliJ     — .idea/ files"
  echo "  [5] VS Code      — .vscode/ files"
  echo "  [6] Neovim       — .nvim.lua"
  echo "  [7] Devcontainer — .devcontainer/"
  echo "  [A] All of the above"
  echo ""
  read -r -p "Enter choices (e.g. 1 3 4 or A): " raw_choices || true

  # Normalize to uppercase, split on spaces/commas
  local choices
  read -ra choices <<< "${raw_choices^^}"

  local do_universal=false do_java=false do_frontend=false
  local do_intellij=false do_vscode=false do_neovim=false do_devcontainer=false

  for c in "${choices[@]}"; do
    case "$c" in
      A) do_universal=true; do_java=true; do_frontend=true
         do_intellij=true; do_vscode=true; do_neovim=true; do_devcontainer=true ;;
      1) do_universal=true ;;
      2) do_java=true ;;
      3) do_frontend=true ;;
      4) do_intellij=true ;;
      5) do_vscode=true ;;
      6) do_neovim=true ;;
      7) do_devcontainer=true ;;
      *) echo -e "${YELLOW}Unknown choice: $c (ignored)${RESET}" ;;
    esac
  done

  $do_universal && sync_universal
  $do_java      && sync_java
  $do_frontend  && sync_frontend
  $do_intellij  && sync_intellij
  $do_vscode         && sync_vscode
  $do_neovim         && sync_neovim
  $do_devcontainer   && sync_devcontainer
}

# ── Summary ────────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${BOLD}── Summary ───────────────────────────────────────────────────────${RESET}"

  if [[ ${#CREATED[@]} -gt 0 ]]; then
    echo -e "${GREEN}Created (${#CREATED[@]}):${RESET}"
    for f in "${CREATED[@]}"; do echo "  + $f"; done
  fi

  if [[ ${#UPDATED[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Updated (${#UPDATED[@]}):${RESET}"
    for f in "${UPDATED[@]}"; do echo "  ~ $f"; done
  fi

  if [[ ${#INJECTED[@]} -gt 0 ]]; then
    echo -e "${GREEN}Injected (${#INJECTED[@]}):${RESET}"
    for f in "${INJECTED[@]}"; do echo "  + $f"; done
  fi

  if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo -e "${CYAN}Skipped (${#SKIPPED[@]}):${RESET}"
    for f in "${SKIPPED[@]}"; do echo "  - $f"; done
  fi

  local total=$(( ${#CREATED[@]} + ${#UPDATED[@]} + ${#INJECTED[@]} ))
  echo ""
  if $DRY_RUN; then
    echo -e "${CYAN}Dry run complete — no files were modified.${RESET}"
  elif [[ $total -gt 0 ]]; then
    echo -e "${GREEN}Done. $total change(s) applied on branch '${BRANCH_NAME}'.${RESET}"
    echo -e "  Review with: ${CYAN}git -C \"$TARGET_DIR\" diff${RESET}"
    echo -e "  Commit with: ${CYAN}git -C \"$TARGET_DIR\" add -p && git -C \"$TARGET_DIR\" commit${RESET}"
  else
    echo -e "${CYAN}Nothing to do — all files were already up to date.${RESET}"
  fi
}

# ── Main ───────────────────────────────────────────────────────────────────────

echo -e "${BOLD}common-standards sync${RESET}"
echo -e "  Source: $STANDARDS_DIR"
echo -e "  Target: $TARGET_DIR"
$DRY_RUN && echo -e "  ${YELLOW}Dry-run mode — no files will be modified${RESET}"

setup_branch
show_menu
print_summary
