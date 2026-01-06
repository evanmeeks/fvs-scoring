import js from "@eslint/js";
import ts from "typescript-eslint";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import jsxA11y from "eslint-plugin-jsx-a11y";
import globals from "globals";

export default ts.config(
  // 1. Global Ignores
  {
    ignores: [
      "**/*.md",
      "dist",
      "node_modules",
      "src/routeTree.gen.ts",
      "fvs-snapshot-*.tar.zst",
      "coverage",
      "netlify/functions/**/*.ts",
      "netlify/edge-functions/**/*.tsx",
      "netlify/edge-functions/**/*.ts",
      "**/.netlify/**",
      "proposed-ui/**",
      "docs/**/*.tsx",
      "docs/**/*.ts",
    ],
  },

  // 2. Base Config
  js.configs.recommended,
  ...ts.configs.recommended,

  // 3. React + JSX + A11y Config
  {
    files: ["**/*.{js,jsx,ts,tsx}"],
    plugins: {
      react,
      "react-hooks": reactHooks,
      "jsx-a11y": jsxA11y,
    },
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
        ...globals.es2021,
      },
    },
    settings: {
      react: {
        version: "detect",
      },
    },
    rules: {
      ...react.configs.recommended.rules,
      ...react.configs["jsx-runtime"].rules,
      ...reactHooks.configs.recommended.rules,
      ...jsxA11y.flatConfigs.recommended.rules,

      // Custom Rules
      "jsx-a11y/click-events-have-key-events": "warn",
      "react/prop-types": "off", // Disable prop-types
      "no-unused-vars": "off", // Turn off base rule, use TS one below
      "@typescript-eslint/no-unused-vars": ["warn", {
        "argsIgnorePattern": "^_",
        "varsIgnorePattern": "^_",
        "caughtErrorsIgnorePattern": "^_"
      }],
      "react/no-unescaped-entities": "off",
      "@typescript-eslint/no-explicit-any": "warn",
    },
  },

  // 4. Node Scripts Config
  {
    files: [
      "scripts/**/*.js",
      "*.cjs",
      "*.config.js",
      "eslint.config.js"
    ],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
    rules: {
      "no-console": "off",
      "no-undef": "off",
      "@typescript-eslint/no-var-requires": "off",
    },
  },
);
