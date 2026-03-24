// @ts-check
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import angularEslint from 'angular-eslint';

export default tseslint.config(
  // ── Global ignores ───────────────────────────────────────────────────────────
  {
    ignores: ['node_modules/', 'dist/', '.angular/']
  },

  // ── TypeScript files ─────────────────────────────────────────────────────────
  {
    files: ['**/*.ts'],
    extends: [
      eslint.configs.recommended,
      ...tseslint.configs.recommended,
      ...tseslint.configs.stylistic,
      ...angularEslint.configs.tsRecommended
    ],
    processor: angularEslint.processInlineTemplates,
    rules: {
      '@angular-eslint/directive-selector': ['error', {type: 'attribute', prefix: 'app', style: 'camelCase'}],
      '@angular-eslint/component-selector': ['error', {type: 'element', prefix: 'app', style: 'kebab-case'}],
      '@angular-eslint/prefer-standalone': 'error',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': ['error', {argsIgnorePattern: '^_', varsIgnorePattern: '^_'}]
    }
  },

  // ── Angular HTML templates ───────────────────────────────────────────────────
  {
    files: ['**/*.html'],
    extends: [...angularEslint.configs.templateRecommended, ...angularEslint.configs.templateAccessibility],
    rules: {}
  }
);
