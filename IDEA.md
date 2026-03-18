# IntelliJ IDEA Configuration

This project enforces Java formatting via the Maven `formatter-maven-plugin` using
`Common-Standards-Eclipse-Code-Profile.xml` as the source of truth. The settings below
have been transferred into IntelliJ IDEA's project code style (`.idea/codeStyles/Project.xml`)
so that the IDE's editor matches the formatter as closely as possible.

Run `./mvnw formatter:format` at any time to apply the canonical format.

---

## What is configured automatically

Opening the project in IntelliJ IDEA activates the project-level code style
(`.idea/codeStyles/Project.xml`) without any manual steps. The `.editorconfig` file
at the repository root provides the same baseline settings to other EditorConfig-aware
editors (VS Code, Vim, etc.).

---

## Settings transferred from the Eclipse profile

### Indentation

| Eclipse setting | Value | IntelliJ setting |
|---|---|---|
| `tabulation.char` | `space` | use spaces (not tabs) |
| `tabulation.size` | `2` | `INDENT_SIZE = 2` |
| `indentation.size` | `2` | `INDENT_SIZE = 2` |
| `continuation_indentation` | `2` | `CONTINUATION_INDENT_SIZE = 2` |

### Line length

| Eclipse setting | Value | IntelliJ setting |
|---|---|---|
| `lineSplit` | `120` | `RIGHT_MARGIN = 120` |
| `comment.line_length` | `120` | `RIGHT_MARGIN = 120` |

### Brace placement (Allman style)

All braces open on a new line. IntelliJ value `2` = "Next line".

| Eclipse setting | IntelliJ setting |
|---|---|
| `brace_position_for_block = next_line` | `BRACE_STYLE = 2` |
| `brace_position_for_type_declaration = next_line` | `CLASS_BRACE_STYLE = 2` |
| `brace_position_for_method_declaration = next_line` | `METHOD_BRACE_STYLE = 2` |
| `brace_position_for_constructor_declaration = next_line` | `METHOD_BRACE_STYLE = 2` |
| `brace_position_for_enum_declaration = next_line` | `CLASS_BRACE_STYLE = 2` |
| `brace_position_for_annotation_type_declaration = next_line` | `CLASS_BRACE_STYLE = 2` |
| `brace_position_for_record_declaration = next_line` | `CLASS_BRACE_STYLE = 2` |
| `brace_position_for_record_constructor = next_line` | `METHOD_BRACE_STYLE = 2` |
| `brace_position_for_anonymous_type_declaration = next_line` | `BRACE_STYLE = 2` |
| `brace_position_for_switch = next_line` | `BRACE_STYLE = 2` |

Exception — lambda bodies use end-of-line (K&R), configured separately:

| Eclipse setting | IntelliJ setting |
|---|---|
| `brace_position_for_lambda_body = end_of_line` | `LAMBDA_BRACE_STYLE = 0` |

Exception — array initializers use end-of-line and are not configurable separately in IntelliJ:
- `brace_position_for_array_initializer = end_of_line`

### Newlines before keywords

| Eclipse setting | IntelliJ setting |
|---|---|
| `insert_new_line_before_else_in_if_statement = insert` | `ELSE_ON_NEW_LINE = true` |
| `insert_new_line_before_catch_in_try_statement = insert` | `CATCH_ON_NEW_LINE = true` |
| `insert_new_line_before_finally_in_try_statement = insert` | `FINALLY_ON_NEW_LINE = true` |
| `insert_new_line_before_while_in_do_statement = insert` | `WHILE_ON_NEW_LINE = true` |

### Switch indentation

| Eclipse setting | Value | IntelliJ setting |
|---|---|---|
| `indent_switchstatements_compare_to_switch` | `true` | `INDENT_CASE_FROM_SWITCH = true` |
| `indent_switchstatements_compare_to_cases` | `true` | default (true) |
| `indent_breaks_compare_to_cases` | `true` | default (true) |

### Blank lines

| Eclipse setting | Value | IntelliJ setting |
|---|---|---|
| `number_of_empty_lines_to_preserve` | `1` | `KEEP_BLANK_LINES_IN_CODE = 1` |
| `number_of_blank_lines_at_end_of_code_block` | `0` | `KEEP_BLANK_LINES_BEFORE_RBRACE = 0` |
| `blank_lines_before_method` | `1` | default (1) |
| `blank_lines_after_package` | `1` | default (1) |
| `blank_lines_after_imports` | `1` | default (1) |

### Spacing

| Eclipse setting | IntelliJ setting |
|---|---|
| `insert_space_after_opening_brace_in_array_initializer = insert` | `SPACE_WITHIN_ARRAY_INITIALIZER_BRACES = true` |
| `insert_space_before_closing_brace_in_array_initializer = insert` | `SPACE_WITHIN_ARRAY_INITIALIZER_BRACES = true` |

### Wrapping

IntelliJ value `1` = "Wrap if long" (Eclipse alignment flag `16` = wrap where necessary).

| Eclipse setting | IntelliJ setting |
|---|---|
| `alignment_for_parameters_in_method_declaration = 16` | `METHOD_PARAMETERS_WRAP = 1` |
| `alignment_for_arguments_in_method_invocation = 16` | `CALL_PARAMETERS_WRAP = 1` |
| `alignment_for_superinterfaces_in_type_declaration = 16` | `EXTENDS_LIST_WRAP = 1` |
| `alignment_for_throws_clause_in_method_declaration = 16` | `THROWS_LIST_WRAP = 1` |
| `alignment_for_resources_in_try = 80` | `RESOURCE_LIST_WRAP = 1` |

### Field alignment

| Eclipse setting | Value | IntelliJ setting |
|---|---|---|
| `align_type_members_on_columns` | `true` | `ALIGN_GROUP_FIELD_DECLARATIONS = true` |

---

## Settings NOT transferable to IntelliJ code style XML

These rules are defined in the Eclipse profile but have no direct equivalent in
IntelliJ's code style XML format. They are enforced exclusively by `./mvnw formatter:format`.

| Category | Examples |
|---|---|
| Fine-grained spacing | 200+ `insert_space_before/after_*` rules |
| Other wrapping strategies | `alignment_for_enum_constants`, `alignment_for_selector_in_method_invocation`, etc. |
| Import ordering | `blank_lines_between_import_groups` and import group layout |
| Formatter tags | `@formatter:off` / `@formatter:on` (IntelliJ has its own mechanism via **Code Style → Formatter Control**) |

For these, always run `./mvnw formatter:format` before committing.

> **Tip — 100% parity with `mvn formatter:format`:** Install the
> [Eclipse Code Formatter](https://plugins.jetbrains.com/plugin/6546-eclipse-code-formatter)
> plugin, then configure it to use `Common-Standards-Eclipse-Code-Profile.xml`.
> It uses the actual Eclipse JDT engine so output is identical.

---

## Verifying the setup

1. Open the project in IntelliJ IDEA.
2. Check **File → Project Structure** — the bottom status bar should show **2 spaces** for Java files.
3. Create or edit a `.java` file — indentation should default to 2 spaces with Allman-style braces.
4. Run `./mvnw formatter:format` — already-formatted files should not be modified.
