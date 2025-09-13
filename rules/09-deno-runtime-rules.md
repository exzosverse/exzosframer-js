# Deno Runtime Rules - Igniter.js Framework

## 🦕 Deno-Specific Development Patterns

### Core Deno Principles
- **Security-first** - Explicit permission model, no implicit access
- **Web standards** - Native Request/Response, Fetch API, URL imports
- **Built-in tooling** - Formatter, linter, test runner, bundler included
- **TypeScript native** - Direct execution without compilation
- **URL imports** - Dependencies from CDN, no node_modules

## 🔒 Security and Permissions Model

### Permission Flags
```bash
# ✅ CORRECT: Explicit permissions for production
deno run \
  --allow-net=localhost:8000,api.example.com \
  --allow-env=DATABASE_URL,API_KEY \
  --allow-read=./config,./src \
  --allow-write=./logs \
  src/index.ts

# ❌ WRONG: Overly permissive for production
deno run -A src/index.ts  # All permissions - development only
```

### Permission Categories
```typescript
/**
 * @permissions Required Deno permissions for Igniter.js
 */
interface DenoPermissions {
  // Network access for server and external APIs
  "--allow-net": ["localhost:8000", "redis:6379", "database:5432"];

  // Environment variables
  "--allow-env": ["DATABASE_URL", "REDIS_URL", "API_KEY"];

  // File system access
  "--allow-read": ["./config", "./src", "./public"];
  "--allow-write": ["./logs", "./temp"];

  // System operations
  "--allow-run": ["prisma"];  // For Prisma CLI
}
```

## 🌐 Native HTTP Server Implementation

### Deno's Built-in Server
```typescript
/**
 * @description Deno native HTTP server with Web Standards
 * @performance Zero framework overhead
 */
import { serve } from "https://deno.land/std@0.203.0/http/server.ts";

// ✅ CORRECT: Direct Request/Response handling
const handler = async (req: Request): Promise<Response> => {
  const url = new URL(req.url);

  // Route to Igniter.js API
  if (url.pathname.startsWith("/api/v1")) {
    return await AppRouter.handler(req);
  }

  // Serve static files
  if (url.pathname.startsWith("/static")) {
    const file = await Deno.readFile(`./public${url.pathname}`);
    return new Response(file, {
      headers: { "content-type": getMimeType(url.pathname) }
    });
  }

  return new Response("Not Found", { status: 404 });
};

// Start server with options
await serve(handler, {
  port: 8000,
  hostname: "0.0.0.0",
  signal: controller.signal,  // Graceful shutdown
  onListen({ port, hostname }) {
    console.log(`🦕 Server running at http://${hostname}:${port}/`);
  },
});

// ❌ WRONG: Using Express/Node.js patterns
import express from "npm:express";  // Unnecessary abstraction
```

### Environment Variables
```typescript
// ✅ CORRECT: Deno.env for secure access
const apiUrl = Deno.env.get("API_URL") || "http://localhost:8000";
const dbUrl = Deno.env.get("DATABASE_URL");

if (!dbUrl) {
  throw new Error("DATABASE_URL environment variable required");
}

// Alternative: Using dotenv for local development
import { load } from "https://deno.land/std@0.203.0/dotenv/mod.ts";
await load({ export: true });  // Loads .env file

// ❌ WRONG: process.env (works but not idiomatic)
const apiUrl = process.env.API_URL;  // Node.js compatibility mode
```

## 📦 Module System and Dependencies

### URL Imports
```typescript
// ✅ CORRECT: Direct URL imports with version pinning
import { serve } from "https://deno.land/std@0.203.0/http/server.ts";
import { z } from "https://deno.land/x/zod@v3.22.4/mod.ts";
import { format } from "https://deno.land/std@0.203.0/datetime/mod.ts";

// JSR imports (new registry)
import { assertEquals } from "jsr:@std/assert@1";

// ❌ WRONG: Relative imports from node_modules
import { serve } from "../node_modules/@deno/std/http/server.ts";
```

### Import Maps
```json
// import_map.json
{
  "imports": {
    "@/": "./src/",
    "@std/": "https://deno.land/std@0.203.0/",
    "zod": "https://deno.land/x/zod@v3.22.4/mod.ts",
    "@igniter/": "npm:@igniter-js/core@^0.2.6/",

    // npm: specifier for Node.js packages
    "prisma": "npm:@prisma/client@^6.11.1",
    "bullmq": "npm:bullmq@^4"
  }
}
```

```typescript
// Using import map aliases
import { igniter } from "@igniter/";
import { z } from "zod";
import { serve } from "@std/http/server.ts";
```

### NPM Compatibility
```typescript
// ✅ CORRECT: Using npm: specifier for Node packages
import { PrismaClient } from "npm:@prisma/client";
import { Queue } from "npm:bullmq";

// Configure Node.js compatibility
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: Deno.env.get("DATABASE_URL"),
    },
  },
});

// ❌ WRONG: Trying to import from node_modules directly
import { PrismaClient } from "./node_modules/@prisma/client";
```

## 🏗️ Configuration and Tasks

### deno.json Configuration
```json
{
  "tasks": {
    // Development with hot reload
    "dev": "deno run --watch --allow-net --allow-env --allow-read src/index.ts",

    // Production start
    "start": "deno run --allow-net --allow-env --allow-read=./config src/index.ts",

    // Testing
    "test": "deno test --allow-read --allow-env tests/",

    // Linting and formatting
    "lint": "deno lint",
    "fmt": "deno fmt",

    // Type checking
    "check": "deno check src/**/*.ts",

    // Database operations
    "db:generate": "deno run -A npm:prisma generate",
    "db:push": "deno run -A npm:prisma db push",
    "db:migrate": "deno run -A npm:prisma migrate dev"
  },

  "lint": {
    "rules": {
      "tags": ["recommended"],
      "exclude": ["no-explicit-any"]
    }
  },

  "fmt": {
    "useTabs": false,
    "lineWidth": 100,
    "indentWidth": 2,
    "semiColons": true,
    "singleQuote": true
  },

  "compilerOptions": {
    "lib": ["deno.window", "dom", "dom.iterable"],
    "strict": true
  },

  "importMap": "./import_map.json",

  "lock": "./deno.lock",

  "nodeModulesDir": false  // Don't create node_modules
}
```

## 🧪 Testing with Deno

### Native Test Runner
```typescript
// ✅ CORRECT: Deno's built-in testing
import { assertEquals, assertExists } from "jsr:@std/assert@1";
import { describe, it } from "https://deno.land/std@0.203.0/testing/bdd.ts";

describe("UserController", () => {
  it("should create a user", async () => {
    const response = await fetch("http://localhost:8000/api/v1/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: "Test User",
        email: "test@example.com"
      })
    });

    assertEquals(response.status, 201);
    const user = await response.json();
    assertExists(user.id);
  });
});

// Run with: deno test --allow-net tests/
```

### Test Permissions
```typescript
// tests/test.config.ts
export const testPermissions = {
  permissions: {
    net: ["localhost:8000"],
    env: ["TEST_DATABASE_URL"],
    read: ["./src", "./tests/fixtures"],
    write: ["./tests/temp"]
  }
};
```

## 🔥 Performance Optimization

### Deno-Specific Optimizations
```typescript
// 1. File Operations with Web Streams
const file = await Deno.open("./large-file.json");
const readable = file.readable;

// Stream processing without loading entire file
const decoder = new TextDecoderStream();
const lines = readable
  .pipeThrough(decoder)
  .pipeThrough(new TextLineStream());

for await (const line of lines) {
  // Process line by line
}

// 2. Workers for CPU-intensive tasks
const worker = new Worker(
  new URL("./worker.ts", import.meta.url).href,
  { type: "module" }
);

// 3. Native KV Store
const kv = await Deno.openKv();
await kv.set(["user", userId], userData);
const result = await kv.get(["user", userId]);

// 4. Native cron jobs
Deno.cron("cleanup", "0 0 * * *", async () => {
  await cleanupOldLogs();
});
```

### Memory Management
```typescript
// ✅ CORRECT: Efficient memory usage
// Use ReadableStream for large files
const response = await fetch("https://example.com/large-file");
const reader = response.body!.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  // Process chunk
}

// ❌ WRONG: Loading entire file into memory
const text = await Deno.readTextFile("./huge-file.txt");
```

## 🌍 Deployment Patterns

### Deno Deploy Configuration
```typescript
// main.ts for Deno Deploy
import { serve } from "https://deno.land/std@0.203.0/http/server.ts";
import { AppRouter } from "./src/igniter.router.ts";

serve(async (req) => {
  // Deno Deploy automatically handles the server
  return await AppRouter.handler(req);
});
```

### Docker Deployment
```dockerfile
# Dockerfile
FROM denoland/deno:1.37.0

WORKDIR /app

# Copy dependencies first for caching
COPY import_map.json deno.json ./
RUN deno cache --import-map=import_map.json src/index.ts

# Copy application code
COPY . .

# Compile to single executable (optional)
RUN deno compile --allow-net --allow-env --output server src/index.ts

EXPOSE 8000

CMD ["./server"]
```

### Self-Contained Binary
```bash
# Compile to single executable
deno compile \
  --allow-net \
  --allow-env \
  --allow-read=./config \
  --output=api-server \
  src/index.ts

# Deploy single binary
./api-server
```

## 🔄 Integration with Igniter.js

### Deno-Optimized Configuration
```typescript
// src/igniter.ts
export const igniter = Igniter
  .context<IgniterAppContext>()
  .logger(logger)
  .config({
    // Use Deno.env for configuration
    baseURL: Deno.env.get("API_URL") || "http://localhost:8000",
    basePath: Deno.env.get("API_BASE_PATH") || "/api/v1",

    // Deno-specific fetch configuration
    fetchOptions: {
      // Use native fetch with Web Standards
      signal: AbortSignal.timeout(30000),
      headers: {
        "User-Agent": `Deno/${Deno.version.deno}`,
      },
    },
  })
  .create();
```

### Direct Handler Integration
```typescript
// No adapter needed - direct integration
const handler = async (req: Request): Promise<Response> => {
  const url = new URL(req.url);

  if (url.pathname.startsWith("/api/v1")) {
    // Direct handler call without Express adapter
    return await AppRouter.handler(req);
  }

  return new Response("Not Found", { status: 404 });
};
```

## 🚨 Deno Anti-Patterns

### ❌ Node.js Assumptions
```typescript
// WRONG: Node.js globals
global.myVar = "value";
__dirname, __filename;  // Not available

// CORRECT: Deno alternatives
globalThis.myVar = "value";
import.meta.url;  // Current module URL
new URL(".", import.meta.url).pathname;  // Directory path
```

### ❌ Filesystem Assumptions
```typescript
// WRONG: Synchronous by default
const data = Deno.readTextFileSync("file.txt");  // Blocks

// CORRECT: Async by default
const data = await Deno.readTextFile("file.txt");
```

### ❌ Package Management
```typescript
// WRONG: npm install workflow
// No package.json dependency management

// CORRECT: URL imports with lock file
// Dependencies in import_map.json
// Lock file: deno.lock
```

## 📋 Deno Development Checklist

### Setup
- [ ] Configure deno.json with tasks
- [ ] Set up import_map.json for dependencies
- [ ] Define permission requirements
- [ ] Configure VS Code with Deno extension

### Development
- [ ] Use Web Standards APIs (Request, Response, URL)
- [ ] Leverage Deno.env for environment variables
- [ ] Implement proper permission scoping
- [ ] Use native testing framework

### Deployment
- [ ] Test with production permissions
- [ ] Consider compilation to binary
- [ ] Configure for Deno Deploy if using
- [ ] Set up Docker image with minimal permissions

### Security
- [ ] Audit permission requirements
- [ ] Use minimal permission scope
- [ ] Validate URL imports
- [ ] Enable lock file for dependencies

## 🔄 Migration from Node.js

### Quick Migration Reference
```typescript
// Package management
npm install → URL imports in import_map.json
package.json → deno.json
node_modules → Cached in DENO_DIR

// Runtime
node index.js → deno run index.ts
nodemon → deno run --watch
npm run → deno task

// APIs
process.env → Deno.env.get()
fs.readFile → Deno.readFile()
__dirname → new URL(".", import.meta.url).pathname
require() → import

// Testing
jest/mocha → deno test
chai/assert → jsr:@std/assert

// HTTP
express → Native serve()
req.body → await req.json()
res.send() → new Response()
```

---

**Remember**: Deno's strength lies in its security model, web standards compliance, and built-in tooling. Embrace the permission system and URL imports for a modern, secure development experience.