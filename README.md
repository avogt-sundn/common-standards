# Common Standards — Java Code Formatting

This repository defines and verifies the common Java formatting rules used across projects.
It ships two Eclipse configuration files, a reference implementation, and automated tests
that prove the rules are correct and consistently enforced by Maven.

---

## Repository layout

```
Common-Standards-Eclipse-Code-Profile.xml   ← formatter rules (Eclipse + Maven)
Common-Standards-Eclipse-Clean-Up-Rules.xml ← clean-up rules (Eclipse IDE only)

src/main/java/com/example/formatter/
  FormatterShowcase.java             ← reference: correctly formatted code
  FormatterShowcaseUnformatted.java  ← violation showcase: same code, wrong formatting

src/test/java/com/example/formatter/
  FormatterShowcaseUnformattedTest.java  ← unit test: Eclipse JDT formatter API
  FormatterMavenIntegrationTest.java     ← integration test: real ./mvnw invocation

src/test/resources/
  verify-formatter.sh                ← shell script driven by the integration test
```

---

## Configuration files

### `Common-Standards-Eclipse-Code-Profile.xml`

The formatter profile. Key rules:

| Rule | Setting |
|------|---------|
| Indentation | 2 spaces (no tabs) |
| Line length | 120 characters |
| Brace style | Allman — opening `{` always on its own next line |
| `else` / `catch` / `finally` / `while` | Each starts on a new line |
| `else if` | Compact — `if` stays on the same line as `else` |
| Binary operators | Spaces on both sides (`a + b`, `a == b`, `a \|\| b`) |
| Control-flow keywords | Space before `(` — `if (`, `for (`, `while (`, `switch (` |
| Lambda body brace | End-of-line (`event -> {`) |
| Field alignment | Type members column-aligned |
| Array initialisers | Spaces inside braces — `{ 1, 2, 3 }` |
| `@formatter:off` / `@formatter:on` | Respected |
| Import order | `static` → `java.*` → `javax.*` → `org.*` → `com.*` → other, one blank line between groups |

Import this file in Eclipse via **Window → Preferences → Java → Code Style → Formatter → Import**.

### `Common-Standards-Eclipse-Clean-Up-Rules.xml`

The clean-up profile, applied on save or via **Source → Clean Up** in Eclipse.
Notable rules enabled: remove unused imports, remove trailing whitespace,
use lambdas over anonymous classes, qualify static member accesses with their
declaring class, add missing `serialVersionUID`.

Import via **Window → Preferences → Java → Code Style → Clean Up → Import**.

### VS Code

VS Code cannot import this XML file directly — it is Eclipse IDE-specific. To approximate the enabled rules:

**1. Add to `.vscode/settings.json`:**

```json
{
  "editor.formatOnSave": true,
  "files.trimTrailingWhitespace": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "always",
    "source.fixAll.java": "always"
  },
  "java.completion.importOrder": ["#", "java", "javax", "org", "com", ""]
}
```

Using `"always"` matches the Eclipse on-save behavior — imports are organized and quick-fixes applied automatically on every save. This covers `remove_unused_imports`, `organize_imports`, `format_source_code`, `remove_trailing_whitespaces`, and quick-fixable rules such as `remove_unnecessary_casts`, `add_missing_override_annotations`, `remove_redundant_type_arguments`, `boolean_value_rather_than_comparison`, `convert_to_enhanced_for_loop`, and `use_lambda` (via the [Language Support for Java](https://marketplace.visualstudio.com/items?itemName=redhat.java) extension).

**2. Rules with no VS Code equivalent** — these must be applied manually or via Eclipse/IntelliJ:

| Rule | What it does |
|------|-------------|
| `make_variable_declarations_final` | Adds `final` to local variables |
| `make_parameters_final` | Adds `final` to method parameters |
| `make_private_fields_final` | Adds `final` to private fields |
| `primitive_rather_than_wrapper` | Replaces `Integer` with `int` etc. |
| `do_while_rather_than_while` | Converts eligible `while` loops to `do-while` |
| `stringbuilder_for_local_vars` | Replaces string concatenation in loops with `StringBuilder` |
| `always_use_blocks` | Adds `{}` to single-line `if`/`for`/`while` bodies |

There is no Maven plugin equivalent for clean-up rules — only formatting is enforced by `./mvnw formatter:format`.

---

## Maven formatter

The `formatter-maven-plugin` is bound to the `process-sources` phase, so
`./mvnw package` (or any lifecycle goal that includes `process-sources`) will
automatically format all Java sources under `src/main/java`.

```bash
# Format in-place
./mvnw formatter:format

# Check without modifying (fails the build if any file is unformatted)
./mvnw formatter:validate

# Sort imports in-place
./mvnw impsort:sort

# Check import order without modifying (fails the build if any file needs sorting)
./mvnw impsort:check
```

`FormatterShowcaseUnformatted.java` is **excluded** from the Maven formatter by design —
it is an intentional violation showcase kept permanently unformatted.

---

## Showcase files

### `FormatterShowcase.java`

The reference file. Every formatting rule in the profile is exercised here:
enums, records, interfaces, constructors, `if/else if/else`, switch expressions,
try-with-resources, multi-catch, lambdas, do-while, long method signatures,
array initialisers, and a `@formatter:off` region.

### `FormatterShowcaseUnformatted.java`

An exact logical copy of `FormatterShowcase.java` with deliberate violations:

| Violation | Rule broken |
|-----------|-------------|
| `{` on same line (K&R style) | `brace_position_for_*=next_line` |
| `else` / `catch` / `while` cuddled on `}` | `insert_new_line_before_else/catch/finally/while=insert` |
| Missing space before `(` — `if(`, `for(` | `insert_space_before_opening_paren_in_if/for/while/…=insert` |
| Missing spaces around operators — `a+b`, `a==b` | `insert_space_after/before_*_operator=insert` |
| Fields not column-aligned | `align_type_members_on_columns=true` |
| Lambda `{` on its own line | `brace_position_for_lambda_body=end_of_line` |
| No spaces inside array initialisers — `{1,2,3}` | `insert_space_after/before_…_brace_in_array_initializer=insert` |

---

## Tests

### `FormatterShowcaseUnformattedTest` — Eclipse JDT API

Uses the Eclipse JDT formatter engine (same engine as the Maven plugin) directly,
without spawning a process:

- **`unformattedSource_whenFormattedWithEclipseProfile_isActuallyChanged`**
  Formats the source programmatically and asserts the output differs from the
  original — proving the violations were real.

- **`unformattedSource_whenFormattedWithEclipseProfile_isIdempotent`**
  Formats twice and asserts both passes produce identical output — proving
  the result conforms stably to the profile.

### `FormatterMavenIntegrationTest` — real `./mvnw` invocation

Delegates to `verify-formatter.sh`, which:

1. Copies `FormatterShowcaseUnformatted.java` into a throw-away temp Maven project.
2. Runs `./mvnw formatter:format` (pass 1) — asserts the file **changed**.
3. Runs `./mvnw formatter:format` (pass 2) — asserts **no further change** (idempotent).
4. Confirms the original source file was not modified.

The original `FormatterShowcaseUnformatted.java` is **never touched** by the test.

```bash
# Run all tests
./mvnw test
```
