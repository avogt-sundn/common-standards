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
