# Bun Runtime Rules - Igniter.js Framework

## 🚀 Bun-Specific Development Patterns

### Core Bun Principles
- **Native APIs first** - Use Bun's built-in APIs over Node.js polyfills
- **Zero configuration** - Leverage Bun's built-in TypeScript, JSX, bundling
- **Performance priority** - Sub-100ms cold starts, instant HMR
- **Type-safe runtime** - Full TypeScript integration without transpilation
- **Modern ES modules** - Top-level await, import assertions, direct imports

## 🎯 Bun Server Architecture

### Native Server Implementation
```typescript
/**
 * @description Bun's native serve API with route mapping
 * @performance 50ms startup vs 2-3s for Express
 */
import { serve } from "bun";

const server = serve({
  port: Bun.env.PORT || 3000,

  // ✅ CORRECT: Direct route mapping
  routes: {
    "/*": handleStaticFiles,
    "/api/v1/*": AppRouter.handler,
    "/ws": handleWebSocket,
  },

  // Development-specific features
  development: Bun.env.NODE_ENV !== "production" && {
    hmr: true,      // Native hot module reloading
    console: true,  // Browser console bridging
    inspector: true // DevTools integration
  },

  // Production optimizations
  maxRequestBodySize: 1024 * 1024 * 10, // 10MB
  compression: true,
});

// ❌ WRONG: Using Express/Fastify
import express from "express"; // Unnecessary overhead
```

### Environment Variables
```typescript
// ✅ CORRECT: Bun.env for runtime access
const apiUrl = Bun.env.BUN_PUBLIC_API_URL || "http://localhost:3000";
const secretKey = Bun.env.SECRET_KEY; // Server-only

// ❌ WRONG: process.env (works but less optimal)
const apiUrl = process.env.NEXT_PUBLIC_API_URL;
```

## ⚛️ React 19 Integration

### Advanced HMR with State Preservation
```typescript
/**
 * @description React 19 root persistence across HMR cycles
 * @preserves Component state, scroll position, form data
 */
// src/app/_app.tsx
import { createRoot } from "react-dom/client";

const container = document.getElementById("root")!;

if (import.meta.hot) {
  // Persist root across HMR cycles
  const root = (import.meta.hot.data.root ??= createRoot(container));

  // Preserve application state
  import.meta.hot.data.appState ??= {
    scrollPosition: window.scrollY,
    formData: new FormData(document.forms[0]),
    selectedTab: localStorage.getItem("selectedTab"),
  };

  root.render(
    <StrictMode>
      <App initialState={import.meta.hot.data.appState} />
    </StrictMode>
  );

  // Cleanup on HMR dispose
  import.meta.hot.dispose(() => {
    import.meta.hot.data.appState = captureAppState();
  });
} else {
  // Production: Standard rendering
  createRoot(container).render(
    <StrictMode>
      <App />
    </StrictMode>
  );
}
```

### React 19 Concurrent Features
```typescript
// ✅ CORRECT: Leverage React 19 features
import { use, cache, startTransition } from "react";

// Cached data fetching
const getCachedUser = cache(async (id: string) => {
  return await api.users.get.query({ id });
});

// Component with suspense boundaries
function UserProfile({ userId }: { userId: string }) {
  // React 19's use() hook for promises
  const user = use(getCachedUser(userId));

  return (
    <div>
      <h1>{user.name}</h1>
      <button onClick={() => {
        // Concurrent updates
        startTransition(() => {
          router.push(`/user/${userId}/edit`);
        });
      }}>
        Edit Profile
      </button>
    </div>
  );
}
```

## 🏗️ Build System Configuration

### Bun Native Build
```typescript
// build.ts
import { build } from "bun";
import tailwindPlugin from "bun-plugin-tailwind";

const result = await build({
  // ✅ CORRECT: Scan for HTML entry points
  entrypoints: [...new Bun.Glob("**/*.html").scanSync("src")],

  // Bun-specific optimizations
  target: "browser",
  minify: true,
  splitting: true,        // Code splitting
  sourcemap: "linked",    // External sourcemaps
  naming: "[dir]/[name].[hash].[ext]",

  // Plugin integration
  plugins: [
    tailwindPlugin({
      configPath: "./tailwind.config.ts",
    }),
  ],

  // Output configuration
  outdir: "./dist",
  publicPath: "/assets/",

  // Tree shaking
  treeShaking: true,

  // Define global constants
  define: {
    "import.meta.env.MODE": JSON.stringify(Bun.env.NODE_ENV),
    "import.meta.env.API_URL": JSON.stringify(Bun.env.BUN_PUBLIC_API_URL),
  },
});

// ❌ WRONG: Webpack/Vite configuration
// Not needed with Bun's native build system
```

### TypeScript Configuration for Bun
```json
{
  "compilerOptions": {
    // ✅ CORRECT: Bun-optimized settings
    "moduleResolution": "bundler",     // Bun's bundler resolution
    "module": "preserve",               // Keep ES modules
    "target": "esnext",                // Latest JavaScript features
    "lib": ["esnext", "dom", "dom.iterable"],

    // Import handling
    "allowImportingTsExtensions": true, // Direct .ts imports
    "verbatimModuleSyntax": true,      // Preserve import/export
    "noEmit": true,                    // Bun handles compilation

    // Type checking
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,

    // JSX
    "jsx": "react-jsx",
    "jsxImportSource": "react"
  },

  // Bun-specific paths
  "include": ["src/**/*", "*.ts"],
  "exclude": ["node_modules", "dist"]
}
```

## 📦 Package Management

### Bun Package Manager
```bash
# ✅ CORRECT: Use bun for package management
bun add react@latest
bun add -d @types/react
bun install --frozen-lockfile  # CI/CD

# ❌ WRONG: npm/yarn/pnpm
npm install react  # Slower, creates package-lock.json
```

### Workspace Configuration
```json
// package.json
{
  "workspaces": ["packages/*", "apps/*"],
  "trustedDependencies": [
    // Packages that run postinstall scripts
    "@prisma/client"
  ]
}
```

## 🔥 Performance Optimization

### Bun-Specific Optimizations
```typescript
// 1. Native file operations
const file = Bun.file("./data.json");
const data = await file.json(); // Direct JSON parsing

// 2. Native hashing
const hash = Bun.hash("my-string"); // Fast native hashing

// 3. Native SQLite
import { Database } from "bun:sqlite";
const db = new Database("app.db");

// 4. Native testing
import { test, expect } from "bun:test";
test("fast native tests", () => {
  expect(2 + 2).toBe(4);
});

// 5. Native WebSocket
const ws = new WebSocketServer({
  port: 8080,
  perMessageDeflate: true,
});
```

### Memory Management
```typescript
// ✅ CORRECT: Leverage Bun's garbage collector
if (import.meta.env.MODE === "production") {
  // Aggressive GC for production
  setInterval(() => {
    if (global.gc) global.gc();
  }, 60000); // Every minute
}

// Monitor memory usage
const memoryUsage = process.memoryUsage();
if (memoryUsage.heapUsed > 500_000_000) { // 500MB
  console.warn("High memory usage detected");
}
```

## 🌐 API Integration with Igniter.js

### Bun-Optimized Client
```typescript
// src/igniter.client.ts
export const api = createIgniterClient<AppRouter>({
  // ✅ CORRECT: Bun environment variables
  baseURL: Bun.env.BUN_PUBLIC_API_URL || "http://localhost:3000",
  basePath: Bun.env.BUN_PUBLIC_API_BASE_PATH || "/api/v1",

  // Bun-specific fetch options
  fetchOptions: {
    // Native compression support
    compress: true,
    // Connection pooling
    keepalive: true,
    // Custom headers
    headers: {
      "X-Runtime": "Bun",
      "X-Version": Bun.version,
    },
  },
});
```

### Direct Router Integration
```typescript
// No Express adapter needed
const server = serve({
  routes: {
    // ✅ CORRECT: Direct handler integration
    "/api/v1/*": async (req) => {
      return await AppRouter.handler(req);
    },
  },
});

// ❌ WRONG: Express adapter (unnecessary)
app.use("/api/v1", expressAdapter(AppRouter));
```

## 🧪 Testing with Bun

### Native Test Runner
```typescript
// ✅ CORRECT: Use Bun's built-in test runner
import { test, expect, describe, beforeEach } from "bun:test";

describe("UserController", () => {
  beforeEach(() => {
    // Reset database
  });

  test("creates user", async () => {
    const response = await api.users.create.mutate({
      name: "Test User",
      email: "test@example.com",
    });

    expect(response.id).toBeDefined();
    expect(response.name).toBe("Test User");
  });

  // Snapshot testing
  test("matches snapshot", () => {
    const component = render(<UserCard user={mockUser} />);
    expect(component).toMatchSnapshot();
  });
});
```

## 🚨 Bun Anti-Patterns

### ❌ Node.js Polyfills
```typescript
// WRONG: Using Node.js APIs
import fs from "fs";
import path from "path";
import crypto from "crypto";

// CORRECT: Use Bun native APIs
import { file, write } from "bun";
const hash = Bun.hash("data");
```

### ❌ CommonJS Modules
```javascript
// WRONG: CommonJS syntax
module.exports = { handler };
const module = require("module");

// CORRECT: ES Modules
export { handler };
import { module } from "module";
```

### ❌ Webpack/Vite Plugins
```typescript
// WRONG: Build tool specific
import vitePlugin from "vite-plugin";

// CORRECT: Bun plugins or native features
import bunPlugin from "bun-plugin";
```

## 📋 Bun Development Checklist

### Setup
- [ ] Use `bun init` for new projects
- [ ] Configure TypeScript for Bun bundler
- [ ] Set up Bun environment variables
- [ ] Enable HMR with state preservation

### Development
- [ ] Use Bun native APIs over Node.js
- [ ] Leverage built-in TypeScript support
- [ ] Implement React 19 concurrent features
- [ ] Use native test runner

### Build & Deploy
- [ ] Configure native build pipeline
- [ ] Optimize with code splitting
- [ ] Enable production minification
- [ ] Use `bun --compile` for binaries

### Performance
- [ ] Monitor startup time (<100ms)
- [ ] Track memory usage
- [ ] Profile with Bun inspector
- [ ] Optimize bundle size

## 🔗 Migration from Node.js

### Quick Migration Guide
```typescript
// 1. Package manager
- npm install → bun install
- npm run dev → bun dev
- npx → bunx

// 2. Runtime
- node index.js → bun index.ts
- nodemon → bun --hot

// 3. Environment
- process.env → Bun.env
- __dirname → import.meta.dir
- __filename → import.meta.path

// 4. APIs
- fs.readFile → Bun.file().text()
- crypto.randomBytes → crypto.getRandomValues()
- child_process → Bun.spawn()
```

---

**Remember**: Bun's strength lies in its simplicity and performance. Avoid over-engineering and leverage native features for optimal development experience.