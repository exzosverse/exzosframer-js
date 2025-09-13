# Code Quality Rules - Igniter.js Framework

## 🎯 ESLint Configuration Principles

### Core Quality Principles
- **Type-safe enforcement** - TypeScript-first with strict checking
- **Standard compliance** - JavaScript Standard Style as foundation
- **Prettier integration** - Consistent formatting across projects
- **Framework-specific** - Tailored configs for React, Next.js, Node.js
- **Accessibility-aware** - JSX accessibility rules included

## 📦 Configuration Setup

### Installation and Usage
```bash
# ✅ CORRECT: Install ESLint with Igniter config
npm install -D eslint @igniter-js/eslint

# For React projects
npm install -D eslint @igniter-js/eslint

# For Node.js projects
npm install -D eslint @igniter-js/eslint
```

### Configuration Files
```json
// .eslintrc.json for Next.js
{
  "extends": [
    "@igniter-js/eslint/next",
    "next/core-web-vitals"
  ],
  "rules": {
    // Custom overrides
  }
}

// .eslintrc.json for React (without Next.js)
{
  "extends": "@igniter-js/eslint/react"
}

// .eslintrc.json for Node.js
{
  "extends": "@igniter-js/eslint/node"
}
```

## ⚛️ React Configuration Rules

### React-Specific Rules
```javascript
/**
 * @config react.js
 * @description React and JSX/TSX linting rules
 */
module.exports = {
  env: {
    browser: true,
    es2021: true,
    jest: true,
  },

  extends: [
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'standard',
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
  ],

  rules: {
    // ✅ CORRECT: Self-closing components
    "react/self-closing-comp": "error",
    // <Component /> instead of <Component></Component>

    // React 17+ with new JSX transform
    'react/react-in-jsx-scope': 'off',

    // TypeScript handles prop types
    'react/prop-types': 'off',

    // Prevent unknown DOM properties
    'react/no-unknown-property': 'error',
  },
};
```

### React Hooks Rules
```typescript
/**
 * @description Enforced React Hooks patterns
 */

// ✅ CORRECT: Hooks at top level
function Component() {
  const [state, setState] = useState(0);
  const memoized = useMemo(() => compute(state), [state]);

  if (condition) {
    return early;
  }

  useEffect(() => {
    // Effect logic
  }, [dependency]);
}

// ❌ WRONG: Conditional hooks
function BadComponent() {
  if (condition) {
    const [state, setState] = useState(0); // Error!
  }
}

// ❌ WRONG: Hooks in loops
function BadLoop() {
  for (let i = 0; i < items.length; i++) {
    useEffect(() => {}); // Error!
  }
}
```

## 🌐 Node.js Configuration Rules

### Node.js-Specific Settings
```javascript
/**
 * @config node.js
 * @description Server-side JavaScript/TypeScript rules
 */
module.exports = {
  env: {
    es2021: true,
    node: true,
  },

  extends: [
    'standard',
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended'
  ],

  rules: {
    // Allow require() for Node.js compatibility
    '@typescript-eslint/no-require-imports': 'off',
  },
};
```

## 🎨 Prettier Integration

### Prettier Configuration
```javascript
/**
 * @description Consistent code formatting
 */
module.exports = {
  printWidth: 80,        // Line length limit
  tabWidth: 2,          // 2 spaces indentation
  singleQuote: true,    // Single quotes for strings
  trailingComma: 'all', // Trailing commas everywhere
  arrowParens: 'always', // Parentheses for arrow functions
  semi: false,          // No semicolons
  endOfLine: 'auto',    // Cross-platform line endings
};

// ✅ CORRECT: Formatted code
const myFunction = (param) => {
  const result = computeValue(param)
  return {
    value: result,
    timestamp: Date.now(),
  }
}

// ❌ WRONG: Inconsistent formatting
const myFunction=(param)=>{
  const result=computeValue(param);
  return {value:result,timestamp:Date.now()}}
```

## ♿ Accessibility Rules

### JSX Accessibility
```typescript
/**
 * @description Enforced accessibility patterns
 */

// ✅ CORRECT: Images with alt text
<img src="photo.jpg" alt="Description of photo" />
<Image src={photo} alt="Product image" />

// ❌ WRONG: Missing alt text
<img src="photo.jpg" /> // Warning!

// ✅ CORRECT: ARIA props
<button
  aria-label="Close dialog"
  aria-pressed={isPressed}
  onClick={handleClose}
>
  ×
</button>

// ✅ CORRECT: Semantic HTML
<nav aria-label="Main navigation">
  <ul>
    <li><a href="/home">Home</a></li>
  </ul>
</nav>

// ❌ WRONG: Non-semantic with click handlers
<div onClick={handleClick}>Click me</div> // Use button!
```

## 📝 TypeScript Rules

### TypeScript Best Practices
```typescript
/**
 * @description TypeScript-specific linting rules
 */

// ✅ CORRECT: Explicit types where helpful
interface User {
  id: string;
  name: string;
  email: string;
}

function processUser(user: User): void {
  console.log(user.name);
}

// ❌ WRONG: Using any
function processData(data: any) { // Warning!
  return data.value; // No type safety
}

// ✅ CORRECT: Unknown for truly unknown types
function processUnknown(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return data.value;
  }
}

// ✅ CORRECT: Consistent type imports
import type { User } from './types';
import { processUser } from './utils';

// ❌ WRONG: Mixed imports
import { User, processUser } from './module'; // Use type imports!
```

## 🚀 Import/Export Rules

### Import Organization
```typescript
/**
 * @description Enforced import patterns
 */

// ✅ CORRECT: Organized imports
// 1. Node built-ins
import fs from 'fs';
import path from 'path';

// 2. External packages
import React from 'react';
import { z } from 'zod';

// 3. Internal aliases
import { Button } from '@/components';
import { useAuth } from '@/hooks';

// 4. Relative imports
import { helper } from './utils';
import styles from './styles.module.css';

// ❌ WRONG: Unorganized imports
import styles from './styles.module.css';
import fs from 'fs';
import { Button } from '@/components';
import React from 'react';
```

## 🔧 Custom Rule Extensions

### Project-Specific Overrides
```json
// .eslintrc.json
{
  "extends": "@igniter-js/eslint/react",
  "rules": {
    // Customize for your project
    "@typescript-eslint/explicit-function-return-type": "error",
    "@typescript-eslint/no-unused-vars": [
      "error",
      {
        "argsIgnorePattern": "^_",
        "varsIgnorePattern": "^_"
      }
    ],
    "import/order": [
      "error",
      {
        "groups": [
          "builtin",
          "external",
          "internal",
          "parent",
          "sibling",
          "index"
        ],
        "newlines-between": "always",
        "alphabetize": {
          "order": "asc"
        }
      }
    ]
  }
}
```

### Environment-Specific Rules
```javascript
// .eslintrc.js
module.exports = {
  extends: '@igniter-js/eslint/node',
  rules: {
    // Development vs Production
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'warn',

    // Stricter in production
    '@typescript-eslint/no-explicit-any':
      process.env.NODE_ENV === 'production' ? 'error' : 'warn',
  },
};
```

## 🏃 Scripts and Automation

### Package.json Scripts
```json
{
  "scripts": {
    // Lint all files
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",

    // Auto-fix issues
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",

    // Lint staged files only
    "lint:staged": "eslint --fix",

    // Format with Prettier
    "format": "prettier --write \"**/*.{js,jsx,ts,tsx,json,md}\"",

    // Check formatting
    "format:check": "prettier --check \"**/*.{js,jsx,ts,tsx,json,md}\"",

    // Type checking
    "typecheck": "tsc --noEmit"
  }
}
```

### Git Hooks with Husky
```json
// .husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged

// lint-staged.config.js
module.exports = {
  '*.{js,jsx,ts,tsx}': [
    'eslint --fix',
    'prettier --write'
  ],
  '*.{json,md}': [
    'prettier --write'
  ]
};
```

## 🚨 Common Linting Anti-Patterns

### ❌ Disabling Rules Globally
```javascript
// WRONG: Disabling important rules
/* eslint-disable @typescript-eslint/no-explicit-any */
function processData(data: any) { // Bad practice!
  return data;
}

// CORRECT: Fix the issue
function processData<T>(data: T): T {
  return data;
}
```

### ❌ Ignoring TypeScript Errors
```typescript
// WRONG: Using @ts-ignore
// @ts-ignore
const result = someFunction(wrongParams);

// CORRECT: Fix the type issue
const result = someFunction(correctParams as CorrectType);
```

### ❌ Inconsistent Configuration
```json
// WRONG: Different configs per developer
// Developer A: .eslintrc
{
  "extends": "airbnb"
}

// Developer B: .eslintrc
{
  "extends": "standard"
}

// CORRECT: Shared configuration
{
  "extends": "@igniter-js/eslint/react"
}
```

## 📋 Code Quality Checklist

### Setup
- [ ] Install @igniter-js/eslint package
- [ ] Configure .eslintrc.json
- [ ] Set up prettier.config.js
- [ ] Add lint scripts to package.json

### Configuration
- [ ] Choose appropriate preset (react/next/node)
- [ ] Add custom rules as needed
- [ ] Configure import ordering
- [ ] Set up accessibility rules

### Automation
- [ ] Configure pre-commit hooks
- [ ] Set up lint-staged
- [ ] Add CI/CD linting checks
- [ ] Enable editor integration

### Maintenance
- [ ] Regular dependency updates
- [ ] Review and update custom rules
- [ ] Monitor linting performance
- [ ] Track and fix warnings

## 🎯 Quality Metrics

### Code Quality Goals
```typescript
/**
 * @metrics Target quality metrics
 */
interface QualityMetrics {
  // Zero ESLint errors
  eslintErrors: 0;

  // Minimal warnings (< 10)
  eslintWarnings: number;

  // TypeScript strict mode
  strictMode: true;

  // 100% Prettier compliance
  formattingCompliance: 100;

  // Accessibility compliance
  a11yCompliance: 'WCAG 2.1 AA';
}
```

---

**Remember**: Consistent code quality is essential for maintainability. The ESLint configuration enforces best practices while remaining flexible enough to adapt to project-specific needs. Always fix linting issues rather than disabling rules.