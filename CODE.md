# VS Code Configuration

This project enforces Java formatting via the Maven `formatter-maven-plugin` using
`.java-config/Common-Standards-Eclipse-Code-Profile.xml` as the source of truth. The settings below
are checked in to `.vscode/settings.json` so that the IDE's editor matches the formatter
as closely as possible.

Run `cd backend && ./mvnw formatter:format` at any time to apply the canonical Java format.
Run `cd frontend && npm run format:fix` at any time to apply the canonical frontend format.

---

## What is configured automatically

Opening the repository in VS Code activates `.vscode/settings.json` without any manual steps.
Install the recommended extensions when prompted (`.vscode/extensions.json`):

| Extension | Purpose |
|---|---|
| `vscjava.vscode-java-pack` | Java language support, Eclipse formatter integration |
| `redhat.vscode-xml` | XML editing support |
| `redhat.vscode-yaml` | YAML editing support |
| `editorconfig.editorconfig` | EditorConfig baseline for all file types |
| `esbenp.prettier-vscode` | Prettier formatter for TS, HTML, CSS, SCSS, JSON |
| `dbaeumer.vscode-eslint` | ESLint integration with flat config support |
| `angular.ng-template` | Angular template language support |

---

## Java formatting

The [Language Support for Java](https://marketplace.visualstudio.com/items?itemName=redhat.java)
extension (included in `vscode-java-pack`) reads the Eclipse formatter profile directly via:

```json
"java.format.settings.url": "${workspaceFolder}/.java-config/Common-Standards-Eclipse-Code-Profile.xml",
"java.format.settings.profile": "Common Standards Eclipse Code Profile for Java"
```

This gives close parity with `cd backend && ./mvnw formatter:format`. Settings transferred:

### Indentation

| Eclipse setting | Value | VS Code effect |
|---|---|---|
| `tabulation.char` | `space` | `editor.insertSpaces = true` |
| `tabulation.size` | `2` | `editor.tabSize = 2` |
| `indentation.size` | `2` | `editor.tabSize = 2` |

### Line length

| Eclipse setting | Value | VS Code effect |
|---|---|---|
| `lineSplit` | `120` | Respected by the Eclipse formatter engine |

### Brace placement, newlines, spacing, wrapping

These are read directly from the Eclipse profile XML by the Java extension — no manual VS Code
setting is needed. The formatter engine used is the same as the Maven plugin.

### Import ordering

Configured via:

```json
"java.completion.importOrder": ["#", "java", "javax", "org", "com", ""]
```

Matches the `impsort-maven-plugin` order (`static` first, then `java`, `javax`, `org`, `com`, other).
Enforced at build time by `cd backend && ./mvnw impsort:sort`.

---

## Frontend formatting (Prettier)

Prettier runs on save for all frontend files. Configured in `.vscode/settings.json`:

```json
"[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
"[html]":       { "editor.defaultFormatter": "esbenp.prettier-vscode" },
"[css]":        { "editor.defaultFormatter": "esbenp.prettier-vscode" },
"[scss]":       { "editor.defaultFormatter": "esbenp.prettier-vscode" },
"[json]":       { "editor.defaultFormatter": "esbenp.prettier-vscode" }
```

Prettier reads `.prettierrc` from the repository root. Key rules:

| Rule | Value |
|---|---|
| Print width | 140 |
| Indent | 2 spaces |
| Quotes | Single |
| Semicolons | Always |
| Trailing commas | None |
| `*.component.html` | Angular parser |
| `*.html` | HTML parser |

### ESLint

`eslint.useFlatConfig: true` is set so the VS Code ESLint extension uses `eslint.config.mjs`.
ESLint auto-fix runs on explicit save (`source.fixAll.eslint: explicit`), not on every auto-save.

---

## Clean-up rules (code actions on save)

`Common-Standards-Eclipse-Clean-Up-Rules.xml` cannot be imported into VS Code — it is an
Eclipse IDE format. The following code actions approximate the enabled rules:

```json
"editor.codeActionsOnSave": {
  "source.organizeImports": "always",
  "source.fixAll.java":     "always",
  "source.fixAll.eslint":   "explicit"
}
```

### What runs on every Java save

| Eclipse clean-up rule | Code action |
|---|---|
| `organize_imports` / `remove_unused_imports` | `source.organizeImports` |
| `format_source_code` / `correct_indentation` | `editor.formatOnSave` |
| `remove_unnecessary_casts` | `source.fixAll.java` |
| `add_missing_override_annotations` | `source.fixAll.java` |
| `remove_redundant_type_arguments` | `source.fixAll.java` |
| `convert_to_enhanced_for_loop` | `source.fixAll.java` |
| `use_lambda` (anonymous → lambda) | `source.fixAll.java` |
| `boolean_value_rather_than_comparison` | `source.fixAll.java` |

### Inspection warnings (flagged in the editor)

The Java extension highlights many of the same issues as IntelliJ inspections, though without
a named profile. Equivalent coverage:

| Eclipse clean-up rule | VS Code / Java extension |
|---|---|
| `use_lambda` | "Can be replaced with lambda" hint |
| `convert_to_enhanced_for_loop` | "Can use enhanced for loop" hint |
| `add_missing_override_annotations` | Missing `@Override` warning |
| `remove_unused_private_fields/methods` | Unused symbol warning |
| `remove_unnecessary_casts` | Unnecessary cast warning |
| `remove_redundant_type_arguments` | Redundant type argument warning |

### Rules with no VS Code equivalent

| Eclipse clean-up rule | Notes |
|---|---|
| `make_variable_declarations_final` | Adds `final` to local variables — no VS Code equivalent |
| `make_parameters_final` | Adds `final` to method parameters — no VS Code equivalent |
| `make_private_fields_final` | Adds `final` to private fields — no VS Code equivalent |
| `primitive_rather_than_wrapper` | Replaces `Integer` with `int` etc. — no VS Code equivalent |
| `do_while_rather_than_while` | Eclipse-only; no VS Code equivalent |
| `stringbuilder_for_local_vars` | String concatenation in loops — no VS Code equivalent |
| `always_use_blocks` | Adds `{}` to braceless control flow — no VS Code equivalent |

For these, always run `cd backend && ./mvnw formatter:format` before committing,
or apply them manually / via IntelliJ.

---

## Verifying the setup

1. Open the repository root in VS Code.
2. Install recommended extensions when prompted.
3. Open a `.java` file — the status bar should show **Spaces: 2**.
4. Run `cd backend && ./mvnw formatter:format` — already-formatted files should not be modified.
5. Open a `.ts` file — format on save should produce output consistent with `.prettierrc`.
6. Run `cd frontend && npm run format:check` — should pass with no issues.
7. Run `cd frontend && npm run lint` — should pass with no issues.
