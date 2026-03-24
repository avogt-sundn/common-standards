# sync-standards.sh — what gets synced

`bin/sync-standards.sh TARGET_DIR [--dry-run]`

Creates a `sync-standards-YYYY-MM-DD` branch in the target repo, then presents
an interactive menu to choose which config sets to transfer.  For each file that
already exists in the target the script shows a diff and prompts:
**[o]verwrite / [s]kip / [b]ackup+overwrite**.

---

## Config sets

### [1] Universal
| File | Purpose |
|------|---------|
| `.editorconfig` | Indentation, line endings, charset for all editors |
| `.gitattributes` | LF line endings enforced in git |
| `DEVELOPING.md` | Developer setup guide (prerequisites, IDE setup, verify steps) |

### [2] Java
| File | Purpose |
|------|---------|
| `.java-config/Common-Standards-Eclipse-Code-Profile.xml` | Eclipse formatter profile (canonical Java style) |
| `.java-config/Common-Standards-Eclipse-Clean-Up-Rules.xml` | Eclipse clean-up rules (`final`, lambdas, primitives, …) |
| `.java-config/README.md` | How to import the profiles in Eclipse / IntelliJ |

In addition, the script **injects two Maven plugins** into the target `pom.xml`
(searched up to depth 2, `target/` excluded):

| Plugin | Version | What it does |
|--------|---------|--------------|
| `net.revelc.code.formatter:formatter-maven-plugin` | 2.29.0 | Formats Java source at `compile` phase using the Eclipse profile |
| `net.revelc.code:impsort-maven-plugin` | 1.9.0 | Sorts imports (`java`, `javax`, `org`, `com`, other); removes unused |

If the plugins are already present the script offers to show the standard config
for manual comparison instead of injecting.

### [3] Frontend
| File | Purpose |
|------|---------|
| `.prettierrc` | Prettier config (2-space indent, 140-char line, single quotes, LF) |
| `.prettierignore` | Paths excluded from Prettier |
| `<frontend-dir>/eslint.config.js` | ESLint flat config for Angular/TypeScript |

The script auto-detects the frontend directory by locating `angular.json`.
For `eslint.config.js` it substitutes the Angular component prefix
(`app` by default) before copying.

Printed after sync — add to `package.json` manually:
```json
"lint": "eslint",
"format:check": "prettier --check \"src/**/*.{ts,html,css,scss}\"",
"format:fix":   "prettier --write \"src/**/*.{ts,html,css,scss}\""
```
And install: `npm install --save-dev prettier eslint @eslint/js angular-eslint typescript-eslint`

### [4] IntelliJ
| File | Purpose |
|------|---------|
| `IDEA.md` | IntelliJ settings reference (transferred rules, plugins, verification) |
| `.idea/.gitignore` | IDE files to keep out of version control |
| `.idea/eclipseCodeFormatter.xml` | Points IntelliJ's Eclipse Formatter plugin at the XML profile |
| `.idea/saveActions.xml` | Built-in Actions on Save: reformat code and optimize imports |
| `.idea/externalDependencies.xml` | Required plugins (Eclipse Code Formatter) |
| `.idea/prettier.xml` | Prettier integration settings |
| `.idea/codeStyles/Project.xml` | IntelliJ native code style (approximates Eclipse rules) |
| `.idea/codeStyles/codeStyleConfig.xml` | Tells IntelliJ to use project code style |
| `.idea/inspectionProfiles/Project_Default.xml` | Inspection severity overrides |
| `.idea/inspectionProfiles/profiles_settings.xml` | Active inspection profile pointer |

### [5] VS Code
| File | Purpose |
|------|---------|
| `CODE.md` | VS Code settings reference (extensions, Java formatting, Prettier, ESLint) |
| `.vscode/settings.json` | Format-on-save, Prettier as default formatter, Java config paths |
| `.vscode/extensions.json` | Recommended extensions (Prettier, Java Pack, ESLint, …) |

### [6] Neovim
| File | Purpose |
|------|---------|
| `NEOVIM.md` | Neovim setup reference (plugins, LSP config, key maps) |
| `.nvim.lua` | Project-local Neovim config (formatters, LSP, key maps) |

### [7] Devcontainer
| File | Purpose |
|------|---------|
| `.devcontainer/devcontainer.json` | Container definition: Java 25, Maven, Gradle, features, ports, mounts |
| `.devcontainer/Dockerfile` | Base image customisation |
| `.devcontainer/scripts/postCreateCommand.sh` | Entry-point that runs all post-create scripts |
| `.devcontainer/scripts/postCreate-Maven.sh` | Maven-specific post-create setup |
| `.devcontainer/scripts/postCreate-Quarkus.sh` | Quarkus-specific post-create setup |
| `.devcontainer/scripts/postCreate-Claude.sh` | Claude Code installation and config |
| `.devcontainer/scripts/start-claude.sh` | Helper to launch Claude Code inside the container |
| `.devcontainer/scripts/dps` | Convenience alias for `docker ps` with useful column format |

---

## Copied files

Files transferred verbatim from this repo to the target:

```
.editorconfig
.gitattributes
DEVELOPING.md
.java-config/Common-Standards-Eclipse-Code-Profile.xml
.java-config/Common-Standards-Eclipse-Clean-Up-Rules.xml
.java-config/README.md
.prettierrc
.prettierignore
IDEA.md
.idea/.gitignore
.idea/eclipseCodeFormatter.xml
.idea/saveActions.xml
.idea/externalDependencies.xml
.idea/prettier.xml
.idea/codeStyles/Project.xml
.idea/codeStyles/codeStyleConfig.xml
.idea/inspectionProfiles/Project_Default.xml
.idea/inspectionProfiles/profiles_settings.xml
CODE.md
.vscode/settings.json
.vscode/extensions.json
NEOVIM.md
.nvim.lua
.devcontainer/devcontainer.json
.devcontainer/Dockerfile
.devcontainer/scripts/postCreateCommand.sh
.devcontainer/scripts/postCreate-Maven.sh
.devcontainer/scripts/postCreate-Quarkus.sh
.devcontainer/scripts/postCreate-Claude.sh
.devcontainer/scripts/start-claude.sh
.devcontainer/scripts/dps
```

## Patched files

Files that are transformed before being written to the target:

| Target file | Transformation |
|-------------|---------------|
| `<frontend-dir>/eslint.config.js` | `prefix: 'app'` replaced with the user-supplied Angular component prefix |
| `pom.xml` | `formatter-maven-plugin` and `impsort-maven-plugin` blocks inserted before the last `</plugins>` tag |

---

## Flags

| Flag | Effect |
|------|--------|
| `--dry-run` | Show what would change without writing any files or creating a branch |

## Testing

```bash
bin/test-sync-standards.sh        # syntax check + dry-run + devcontainer live test
bin/test-sync-standards.sh 1      # bash syntax check only
bin/test-sync-standards.sh 2      # dry-run against empty repo (All)
bin/test-sync-standards.sh 4      # Maven plugin injection
bin/test-sync-standards.sh 5      # devcontainer live sync
```
