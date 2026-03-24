# Project Goals

This repository defines and verifies the **common formatting and linting rules** used across projects — Java (Eclipse/Maven) and Angular/TypeScript (Prettier/ESLint).
Every session, keep these goals in mind as the shared north star:

1. **Single source of truth for formatting** — The Eclipse formatter profile (`Common-Standards-Eclipse-Code-Profile.xml`) is the canonical definition of how Java code looks. For frontend, `.prettierrc` is the canonical definition. All tooling (Maven plugin, IDE, tests) must agree with these.

2. **Proven correctness** — Rules must be backed by automated tests. The test suite proves that violations are detected, that formatting is actually applied, and that applying the formatter is idempotent (a second pass changes nothing).

3. **Consistent enforcement** — Formatting is enforced at build time via `./mvnw formatter:validate`, so no unformatted code can slip through CI.

4. **IDE-agnostic where possible** — Eclipse is the primary target, but IntelliJ and VS Code approximations are documented so every developer can work in their preferred IDE while respecting the same rules.

5. **Clean-up rules complement formatting** — The clean-up profile (`Common-Standards-Eclipse-Clean-Up-Rules.xml`) goes beyond whitespace: it enforces `final`, lambdas over anonymous classes, primitive types over wrappers, and more. These are IDE-applied; there is no Maven equivalent.

6. **Intentional violations stay unformatted** — `FormatterShowcaseUnformatted.java` is permanently unformatted by design and excluded from the Maven formatter. Never format it automatically.

---

## IDE support

**Supported** — first-class, actively maintained configurations:
- VS Code
- IntelliJ IDEA
- Neovim
- Maven (for build pipeline)

**Less supported** — Eclipse is the origin of the formatter profile XML, but IDE setup for day-to-day development is not a priority here:
- Eclipse

---

## Key rules at a glance

### Java

| Rule | Value |
|------|-------|
| Indentation | 2 spaces, no tabs |
| Line length | 120 characters |
| Brace style | Allman (`{` on its own line) |
| `else` / `catch` / `finally` | Each on a new line |
| Binary operators | Spaces on both sides |
| Lambda body brace | End-of-line |
| Import order | `static` → `java.*` → `javax.*` → `org.*` → `com.*` → other |

### Frontend (Angular/TypeScript)

| Rule | Value |
|------|-------|
| Formatter | Prettier |
| Indentation | 2 spaces, no tabs |
| Line length | 140 characters |
| Quotes | Single quotes |
| Semicolons | Always |
| Trailing commas | None |
| Bracket same line | Yes |
| Line endings | LF |
| Component style | Standalone (Angular 17+) |

---

## Common commands

```bash
# Java (run from backend/)
cd backend
./mvnw formatter:format    # format in-place
./mvnw formatter:validate  # check without modifying (CI)
./mvnw impsort:sort        # sort imports in-place
./mvnw impsort:check       # check import order without modifying (CI)
./mvnw test                # run all tests

# Frontend (run from frontend/)
cd frontend
npm run format:check       # check Prettier formatting (CI)
npm run format:fix         # format with Prettier in-place
npm run lint               # check ESLint rules (CI)
npm start                  # ng serve on port 4200
npm run build              # production build
```
