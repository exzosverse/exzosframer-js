# Tooling and CLI Rules - Igniter.js Framework

## 🛠️ CLI Command Patterns

### Core CLI Principles
- **Interactive first** - Dashboard-driven development experience
- **Type-safe generation** - AST-based code generation
- **Framework agnostic** - Auto-detects and adapts to any framework
- **AI-powered** - Built for LLM-assisted development
- **Monorepo optimized** - Turborepo with caching and parallelization

## 📦 Project Initialization

### Starting New Projects
```bash
# ✅ CORRECT: Interactive initialization
npx @igniter-js/cli init my-app

# Interactive prompts:
# - Framework selection (Next.js, Express, TanStack Start, etc.)
# - Feature selection (Store, Jobs, MCP, Telemetry)
# - Database selection (PostgreSQL, MySQL, SQLite)
# - Authentication setup (optional)

# ❌ WRONG: Manual project setup
mkdir my-app && cd my-app
npm init -y  # Missing Igniter.js structure
```

### Template Selection
```typescript
/**
 * @description Available starter templates
 */
enum StarterTemplates {
  NEXTJS_APP = "starter-nextjs-app-router",
  EXPRESS_REST = "starter-express-rest-api",
  TANSTACK_START = "starter-tanstack-start",
  BUN_REACT = "starter-bun-react-app",
  DENO_REST = "starter-deno-rest-api",
}

// Template features
interface TemplateFeatures {
  store?: boolean;      // Redis caching
  jobs?: boolean;       // BullMQ background jobs
  mcp?: boolean;        // MCP server integration
  telemetry?: boolean;  // OpenTelemetry
  logging?: boolean;    // Structured logging
}
```

## 🚀 Development Workflow

### Development Server
```bash
# ✅ CORRECT: Use Igniter dev command
npx igniter dev

# Features:
# - Auto-detects framework (Next.js, Vite, etc.)
# - Kills processes on target ports
# - Runs concurrent processes (framework + watcher)
# - Interactive TUI dashboard
# - Live client regeneration

# ❌ WRONG: Running directly
npm run dev  # Misses Igniter.js features
```

### Development Dashboard
```typescript
/**
 * @description Interactive development dashboard
 */
interface DevDashboard {
  processes: {
    framework: Process;    // Next.js, Vite, etc.
    watcher: Process;     // Igniter.js file watcher
    studio?: Process;     // API playground
  };

  controls: {
    restart: () => void;
    clear: () => void;
    quit: () => void;
  };

  logs: {
    framework: LogStream;
    igniter: LogStream;
  };
}
```

## 🎯 Code Generation

### Feature Scaffolding
```bash
# ✅ CORRECT: Generate complete feature slice
npx igniter generate feature products --schema prisma:Product

# Generates:
# src/features/products/
# ├── controllers/products.controller.ts
# ├── procedures/repository.procedure.ts
# ├── schemas/products.schema.ts
# ├── __tests__/products.test.ts
# ├── index.ts
# ├── AGENT.md  # AI context
# └── DOCS.md   # Feature documentation

# ❌ WRONG: Manual file creation
mkdir src/features/products
touch src/features/products/controller.ts  # Missing structure
```

### Schema Generation
```bash
# Generate type-safe client
npx igniter generate schema

# Output: src/igniter.client.ts (auto-generated)
# NEVER edit this file manually!

# With watch mode during development
npx igniter generate schema --watch

# Generate OpenAPI documentation
npx igniter generate docs

# With UI playground
npx igniter generate docs --ui
```

### Controller Generation
```bash
# Generate individual controller
npx igniter generate controller users

# With custom path
npx igniter generate controller auth --path /auth

# With procedures
npx igniter generate controller posts --procedures auth,cache
```

## 🔧 Configuration Management

### ESLint Configuration
```javascript
// .eslintrc.js
module.exports = {
  extends: ["@igniter-js/eslint-config"],

  // For React projects
  // extends: ["@igniter-js/eslint-config/react"],

  parserOptions: {
    project: "./tsconfig.json",
  },

  rules: {
    // Custom overrides
    "@typescript-eslint/no-explicit-any": "error",
  },
};
```

### TypeScript Configuration
```json
// tsconfig.json
{
  "extends": "@igniter-js/typescript-config/base.json",

  // Framework-specific configs
  // "extends": "@igniter-js/typescript-config/react.json",
  // "extends": "@igniter-js/typescript-config/node.json",

  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },

  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Monorepo Configuration
```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"],
      "cache": true
    },
    "dev": {
      "persistent": true,
      "cache": false
    },
    "test": {
      "dependsOn": ["build"],
      "cache": true
    },
    "lint": {
      "outputs": [],
      "cache": true
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "cache": true
    }
  }
}
```

## 🧪 Testing Patterns

### Test Configuration
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'dist/',
        '**/*.config.ts',
        '**/*.d.ts',
      ],
    },
  },
});
```

### Testing Commands
```bash
# Run tests
npm run test

# With coverage
npm run test:coverage

# Watch mode
npm run test:watch

# Specific package in monorepo
npm run test --workspace=@igniter-js/core
```

## 🏗️ Build and Deployment

### Build Configuration
```typescript
// tsup.config.ts
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['cjs', 'esm'],
  dts: true,
  clean: true,
  splitting: false,
  sourcemap: true,
  minify: false,
  external: ['react', 'react-dom'],
  noExternal: ['@igniter-js/core'],
});
```

### Build Commands
```bash
# Build all packages
npm run build

# Build specific package
npm run build --workspace=@igniter-js/core

# Production build
NODE_ENV=production npm run build

# With type checking
npm run build && npm run typecheck
```

## 🐳 Docker Integration

### Docker Compose Generation
```bash
# Generate Docker Compose file
npx igniter docker:init

# With specific services
npx igniter docker:init --services postgres,redis

# Start services
docker-compose up -d

# Generated docker-compose.yml includes:
# - PostgreSQL with health checks
# - Redis with persistence
# - Proper networking
# - Volume management
```

## 📝 Changeset Management

### Version Management
```bash
# Create changeset for version bump
npm run changeset

# Select:
# - Package(s) to version
# - Semver bump type (patch/minor/major)
# - Summary of changes

# Apply changesets
npm run version

# Publish to npm
npm run release
```

## 🤖 AI-Powered Features

### MCP Server Tools
```typescript
/**
 * @description MCP server toolsets
 */
interface MCPToolsets {
  // Memory management
  memory: {
    store: (content: string) => void;
    search: (query: string) => Memory[];
    relate: (ids: string[]) => void;
  };

  // CLI operations
  cli: {
    init: (name: string) => void;
    generate: (type: string, options: any) => void;
    dev: (options: DevOptions) => void;
  };

  // GitHub integration
  github: {
    triageIssues: () => void;
    reviewPR: (prId: string) => void;
    createRelease: () => void;
  };

  // Code investigation
  code: {
    analyzeStructure: () => void;
    findDependencies: () => void;
    suggestRefactoring: () => void;
  };
}
```

### Agent Documentation
```markdown
# AGENT.md Template
# Automatically generated for each feature

## Identity
**Name:** Feature-specific AI agent
**Purpose:** Maintain and extend this feature
**Specialties:** [List relevant technologies]

## Context
- Feature overview
- Architecture decisions
- Business logic patterns
- Testing strategies

## Workflows
1. Adding new endpoints
2. Modifying schemas
3. Updating procedures
4. Writing tests

## Memory Keys
- feature_patterns
- architectural_decisions
- bug_fixes
- performance_insights
```

## 🚨 Tooling Anti-Patterns

### ❌ Manual Client Generation
```typescript
// WRONG: Manually editing generated files
// src/igniter.client.ts
export const api = {
  // Don't add custom code here!
};

// CORRECT: Let CLI generate
npx igniter generate schema
```

### ❌ Bypassing CLI
```bash
# WRONG: Manual scaffolding
mkdir src/features/users
touch src/features/users/controller.ts

# CORRECT: Use CLI
npx igniter generate feature users
```

### ❌ Framework-Specific Scripts
```json
// WRONG: Framework-specific dev scripts
{
  "scripts": {
    "dev": "next dev"  // Misses Igniter features
  }
}

// CORRECT: Use Igniter CLI
{
  "scripts": {
    "dev": "igniter dev"
  }
}
```

## 📋 Tooling Checklist

### Initial Setup
- [ ] Install Igniter CLI globally or use npx
- [ ] Initialize project with `igniter init`
- [ ] Configure ESLint and TypeScript configs
- [ ] Set up git hooks with Husky

### Development
- [ ] Use `igniter dev` for development
- [ ] Generate features with CLI
- [ ] Keep generated files untouched
- [ ] Use watch mode for schema generation

### Quality Assurance
- [ ] Configure linting rules
- [ ] Set up test coverage targets
- [ ] Enable type checking in CI
- [ ] Use changesets for versioning

### Deployment
- [ ] Build with Turborepo caching
- [ ] Generate production schemas
- [ ] Validate OpenAPI documentation
- [ ] Configure Docker services

## 🔄 Migration Guide

### From Manual Setup to CLI
```bash
# 1. Install CLI
npm install -D @igniter-js/cli

# 2. Initialize Igniter.js
npx igniter init --existing

# 3. Migrate features
npx igniter generate feature [name] --migrate

# 4. Update scripts
# package.json
{
  "scripts": {
    "dev": "igniter dev",
    "build": "igniter build",
    "generate": "igniter generate schema"
  }
}

# 5. Remove manual configurations
rm -rf old-config-files
```

---

**Remember**: The Igniter.js CLI is designed to eliminate boilerplate and ensure consistency. Always prefer CLI commands over manual file manipulation for a type-safe, AI-friendly development experience.