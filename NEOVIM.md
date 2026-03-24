# Neovim Configuration

This project enforces Java formatting via the Maven `formatter-maven-plugin` using
`.java-config/Common-Standards-Eclipse-Code-Profile.xml` as the source of truth.
The project-local `.nvim.lua` configures formatting on save to match.

Run `cd backend && ./mvnw formatter:format` at any time to apply the canonical Java format.
Run `cd frontend && npm run format:fix` at any time to apply the canonical frontend format.

---

## What is configured automatically

`.nvim.lua` at the repository root is loaded automatically by Neovim when `exrc` is enabled.

**One-time global setup** — add to your `init.lua`:

```lua
vim.o.exrc = true   -- load .nvim.lua from the project directory
```

`.editorconfig` at the repository root is picked up automatically by Neovim 0.9+ — no plugin needed.
For older versions, install [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim).

### Plugins required

| Plugin | Purpose |
|---|---|
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | Format-on-save dispatcher |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) or [mfussenegger/nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) | Java LSP (jdtls) for Java formatting and diagnostics |
| [pmizio/typescript-tools.nvim](https://github.com/pmizio/typescript-tools.nvim) or [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) (`ts_ls`) | TypeScript LSP for Angular diagnostics |

---

## Java formatting

`.nvim.lua` configures Java to use the LSP formatter as a fallback via conform.nvim:

```lua
java = { lsp_format = 'fallback' },
```

The jdtls Java language server must be pointed at the Eclipse formatter profile.
`.nvim.lua` contains two ready-to-use commented examples — one for `nvim-lspconfig`,
one for `nvim-jdtls`:

```lua
-- nvim-lspconfig approach:
settings = {
  java = {
    format = {
      enabled = true,
      settings = {
        url     = vim.fn.fnamemodify('.java-config/Common-Standards-Eclipse-Code-Profile.xml', ':p'),
        profile = 'Common Standards Eclipse Code Profile for Java',
      },
    },
  },
},
```

This gives close parity with `cd backend && ./mvnw formatter:format`. Settings coverage:

### Indentation

| Eclipse setting | Value | jdtls effect |
|---|---|---|
| `tabulation.char` | `space` | spaces (EditorConfig also enforces this) |
| `tabulation.size` | `2` | 2-space indent |
| `continuation_indentation` | `2` | continuation indent = 2 |

### Line length

| Eclipse setting | Value | jdtls effect |
|---|---|---|
| `lineSplit` | `120` | respected by the Eclipse JDT formatter engine |

### Brace placement, newlines, spacing, wrapping

All rules are read directly from the Eclipse profile XML by jdtls — no manual Neovim
setting is needed. The formatter engine is the same as the Maven plugin.

### Import ordering

jdtls can be configured to organise imports on save. The order must match
the `impsort-maven-plugin`: `static` → `java` → `javax` → `org` → `com` → other.

Configure in your jdtls settings:

```lua
java = {
  sources = {
    organizeImports = {
      starThreshold = 99,
      staticStarThreshold = 99,
    },
  },
},
```

Use an LSP on-attach autocmd to trigger `vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } } })`
on save, or rely on `conform.nvim` with `lsp_format = 'fallback'`.

---

## Frontend formatting (Prettier)

`.nvim.lua` configures Prettier via conform.nvim for all frontend filetypes:

```lua
typescript = { 'prettier' },
html       = { 'prettier' },
css        = { 'prettier' },
scss       = { 'prettier' },
json       = { 'prettier' },
jsonc      = { 'prettier' },
```

Prettier reads `.prettierrc` from the repository root automatically. Key rules:

| Rule | Value |
|---|---|
| Print width | 140 |
| Indent | 2 spaces |
| Quotes | Single |
| Semicolons | Always |
| Trailing commas | None |
| `*.component.html` | Angular parser |
| `*.html` | HTML parser |

Prettier must be installed in `frontend/`:

```bash
cd frontend && npm install   # installs prettier along with other devDependencies
```

conform.nvim will find the `prettier` binary from `frontend/node_modules/.bin/prettier`
when formatting files inside `frontend/`, or from a global install otherwise.

### ESLint

For Angular ESLint diagnostics, configure `ts_ls` or a dedicated ESLint LSP
(e.g. [eslint-lsp](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#eslint))
pointing at `frontend/eslint.config.js`.

---

## Clean-up rules

`Common-Standards-Eclipse-Clean-Up-Rules.xml` has no Neovim equivalent — it is Eclipse IDE-only.

### What jdtls + LSP actions can approximate

| Eclipse clean-up rule | Neovim / jdtls equivalent |
|---|---|
| `organize_imports` / `remove_unused_imports` | `source.organizeImports` code action on save |
| `format_source_code` / `correct_indentation` | conform.nvim format on save |
| `add_missing_override_annotations` | jdtls quickfix / code action |
| `remove_unnecessary_casts` | jdtls diagnostic + quickfix |
| `remove_redundant_type_arguments` | jdtls diagnostic + quickfix |
| `convert_to_enhanced_for_loop` | jdtls code action |
| `use_lambda` | jdtls code action |

Apply available code actions with `vim.lsp.buf.code_action()` (default: `<leader>ca`).

### Rules with no Neovim equivalent

| Eclipse clean-up rule | Notes |
|---|---|
| `make_variable_declarations_final` | Adds `final` to local variables — no Neovim equivalent |
| `make_parameters_final` | Adds `final` to method parameters — no Neovim equivalent |
| `make_private_fields_final` | Adds `final` to private fields — no Neovim equivalent |
| `primitive_rather_than_wrapper` | Replaces `Integer` with `int` etc. — no Neovim equivalent |
| `do_while_rather_than_while` | Eclipse-only |
| `stringbuilder_for_local_vars` | String concatenation in loops — no Neovim equivalent |
| `always_use_blocks` | Adds `{}` to braceless control flow — no Neovim equivalent |

For these, always run `cd backend && ./mvnw formatter:format` before committing,
or apply them manually / via IntelliJ.

---

## Verifying the setup

1. Add `vim.o.exrc = true` to your `init.lua` (once).
2. Open the repository root in Neovim — `.nvim.lua` loads automatically.
3. Open a `.java` file — indentation should default to 2 spaces (via `.editorconfig`).
4. Save a `.java` file — jdtls should format it on save via conform.nvim.
5. Run `cd backend && ./mvnw formatter:format` — already-formatted files should not be modified.
6. Open a `.ts` file and save — Prettier should format it on save.
7. Run `cd frontend && npm run format:check` — should pass with no issues.
