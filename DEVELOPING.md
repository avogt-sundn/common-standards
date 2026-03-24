# Developer Setup

This guide gets you from a fresh clone to a fully configured development environment.
For detailed reference on individual IDE settings, see [IDEA.md](IDEA.md) and [CODE.md](CODE.md).

---

## Prerequisites

| Tool | Purpose |
|---|---|
| Java 17+ | Backend build |
| Node.js 20+ | Frontend build |
| Git | Version control |

---

## 1. Clone and install

```bash
git clone <repo-url>
cd common-standards/frontend && npm install
```

---

## 2. IDE setup

### IntelliJ IDEA

1. Open the repository **root folder** in IntelliJ IDEA.
2. IntelliJ will show a **"Required plugins are not installed"** notification — click **Install** to get:
   - **Save Actions** — runs reformat, optimize imports, add `final`, add `@Override` on every save
   - **Eclipse Code Formatter** — uses the Eclipse JDT engine for exact parity with `./mvnw formatter:format`
3. **Restart IntelliJ.** Both plugins activate automatically from the committed config — no further setup needed.

> **Verify:** open any `.java` file, save it, and confirm the file is reformatted automatically.
> The status bar should show **Spaces: 2** for Java files.

See [IDEA.md](IDEA.md) for the full list of transferred settings and what to do if something looks off.

---

### VS Code

1. Open the repository **root folder** in VS Code.
2. Accept the **"Install recommended extensions"** prompt to get Prettier, ESLint, Java support, and the Angular Language Service.
3. Done — `.vscode/settings.json` is already committed and activates on open.

> **Verify:** open any `.ts` or `.java` file, save it, and confirm it is reformatted automatically.

See [CODE.md](CODE.md) for the full list of settings and coverage notes.

---

### Neovim

A project-local config file `.nvim.lua` is provided at the repo root. It configures
[conform.nvim](https://github.com/stevearc/conform.nvim) for format-on-save and documents
jdtls Java LSP setup pointing at `.java-config/Common-Standards-Eclipse-Code-Profile.xml`.

**One-time global setup** — add to your `init.lua`:
```lua
vim.o.exrc = true   -- enables per-project .nvim.lua files
```

Neovim 0.9+ picks up `.editorconfig` automatically — no plugin needed.

See [NEOVIM.md](NEOVIM.md) for the full plugin list, jdtls formatter setup, and clean-up rule coverage.

---

## 3. Verify the full setup

```bash
# Java: format check and tests (from backend/)
cd backend
./mvnw formatter:validate    # must pass — no unformatted Java files
./mvnw impsort:check         # must pass — correct import order
./mvnw test                  # must pass — 3 tests

# Frontend: format and lint checks (from frontend/)
cd ../frontend
npm run format:check         # must pass — Prettier
npm run lint                 # must pass — Angular ESLint
```

---

## 4. Day-to-day commands

### Backend (Java)

```bash
cd backend
./mvnw formatter:format   # format all Java files in-place
./mvnw impsort:sort       # sort imports in-place
./mvnw test               # run all tests
```

### Frontend (Angular)

```bash
cd frontend
npm start                 # ng serve — dev server on http://localhost:4200
npm run build             # production build
npm run lint              # ESLint check
```

### Formatting

```bash
cd frontend
npm run format:fix        # Prettier — fix all TS/HTML/CSS/SCSS/JSON files
npm run format:check      # Prettier — check only (for CI)
```
