# .java-config/

Shared Java tooling configuration files. Consumed by all Java submodules in this repository.

## Files

| File | Purpose |
|------|---------|
| `Common-Standards-Eclipse-Code-Profile.xml` | Eclipse formatter profile — imported into Eclipse and used by `formatter-maven-plugin` for build-time enforcement |
| `Common-Standards-Eclipse-Clean-Up-Rules.xml` | Eclipse clean-up profile — imported into Eclipse for on-save clean-up rules (no Maven equivalent) |

## Copying to a new project

Copy this entire folder to your project root:

```bash
cp -r .java-config/ my-new-project/.java-config/
```

Then point your tooling at the files:

**`pom.xml`** (`formatter-maven-plugin`):
```xml
<configFile>${project.basedir}/../.java-config/Common-Standards-Eclipse-Code-Profile.xml</configFile>
```
(Use `${project.basedir}/.java-config/...` if `pom.xml` is at the repo root.)

**IntelliJ** (Eclipse Code Formatter plugin → Settings):
```
$PROJECT_DIR$/.java-config/Common-Standards-Eclipse-Code-Profile.xml
```

**VS Code** (`.vscode/settings.json`):
```json
"java.format.settings.url": "/workspaces/<your-project>/.java-config/Common-Standards-Eclipse-Code-Profile.xml"
```

**Eclipse** — import via Window → Preferences → Java → Code Style → Formatter → Import.

## Clean-up rules and IntelliJ inspection mapping

`Common-Standards-Eclipse-Clean-Up-Rules.xml` is Eclipse IDE-only — there is no Maven equivalent.
In IntelliJ the same rules are approximated by `.idea/inspectionProfiles/Project_Default.xml`.
Rules handled by IntelliJ's built-in Actions on Save (organize imports, format on save) live in `.idea/saveActions.xml` instead.

| Eclipse clean-up rule | IntelliJ inspection |
|-----------------------|---------------------|
| `use_lambda` | `AnonymousCanBeLambda` |
| `convert_to_enhanced_for_loop` | `ForLoopReplaceableByForEach` |
| `primitive_rather_than_wrapper` | `UnnecessaryBoxing` + `UnnecessaryUnboxing` |
| `stringbuilder_for_local_vars` | `StringConcatenationInLoop` |
| `boolean_value_rather_than_comparison` | `SimplifiableConditionalExpression` + `PointlessBooleanExpression` |
| `add_missing_override_annotations` | `MissingOverride` |
| `add_missing_deprecated_annotations` | `MissingDeprecatedAnnotation` |
| `remove_unused_private_fields/methods/types` | `UnusedDeclaration` |
| `remove_private_constructors` | `RedundantNoArgConstructor` |
| `always_use_blocks` | `ControlFlowStatementWithoutBraces` |
| `remove_redundant_semicolons` | `UnnecessarySemicolon` |
| `remove_unnecessary_casts` | `RedundantCast` |
| `remove_redundant_type_arguments` | `RedundantTypeArguments` |
| `make_private_fields_final` | `FieldMayBeFinal` |
| `add_serial_version_id` | `SerializableHasSerialVersionUIDField` |
| `use_this_for_non_static_*_only_if_necessary` | `UnnecessaryThis` |

The following Eclipse rules have no direct IntelliJ inspection equivalent and are not enforced in IntelliJ:

| Eclipse clean-up rule | Reason |
|-----------------------|--------|
| `make_variable_declarations_final` / `make_parameters_final` / `make_local_variable_final` | IntelliJ has no warning for missing `final` on locals/parameters |
| `organize_imports` / `remove_unused_imports` | Handled by built-in Actions on Save in `.idea/saveActions.xml` |
| `remove_trailing_whitespaces` / `correct_indentation` / `format_source_code` | Handled by built-in Actions on Save in `.idea/saveActions.xml` |
