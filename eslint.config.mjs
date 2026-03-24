// @ts-check
// Reference ESLint flat config for Angular/TypeScript projects.
// Copy this file to your project root and adjust the component selector prefix.
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import angularEslint from 'angular-eslint';

export default tseslint.config(
  // ── Global ignores ───────────────────────────────────────────────────────────
  {
    ignores: ['node_modules/', 'dist/', 'target/', 'coverage/', '.angular/', '**/*.java', '**/*.xml']
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
      // Angular component/directive selectors — adjust prefix for your project
      '@angular-eslint/directive-selector': ['error', {type: 'attribute', prefix: 'app', style: 'camelCase'}],
      '@angular-eslint/component-selector': ['error', {type: 'element', prefix: 'app', style: 'kebab-case'}],

      // Enforce Angular 17+ standalone components
      '@angular-eslint/prefer-standalone': 'error',

      // Nudge toward Angular signals pattern
      '@angular-eslint/prefer-on-push-change-detection': 'warn',

      // TypeScript
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
