# Core Concepts Rules - Igniter.js Framework

## 🏗️ The Igniter Builder Rules

### Foundation Principles
- **ALWAYS** start with the Igniter Builder as the application foundation
- **ALWAYS** define context type before other configurations
- **NEVER** skip the `.create()` method at the end of builder chain
- **ALWAYS** use fluent interface pattern for configuration

### Builder Configuration Order
```typescript
// ✅ CORRECT ORDER
const igniter = Igniter
  .context<AppContext>()           // 1. Context first
  .middleware([...])               // 2. Global middleware
  .config({ baseURL, basePath })   // 3. Base configuration
  .store(adapter)                  // 4. Store adapter
  .logger(logger)                   // 5. Logger
  .jobs(jobsAdapter)               // 6. Jobs (if needed)
  .telemetry(provider)            // 7. Telemetry (if needed)
  .plugins({ ... })                // 8. Plugins
  .docs({ ... })                   // 9. Documentation
  .create();                       // 10. Create instance

// ❌ WRONG: Context not first
const igniter = Igniter
  .store(adapter)
  .context<AppContext>()  // Context must be first!
```

### Type Safety Enforcement
- **ALWAYS** provide explicit types for context
- **NEVER** use `any` in context definition
- **ALWAYS** ensure type inference flows through builder chain

## 📦 Context Rules

### Base Context Definition
```typescript
// ✅ CORRECT: Single source of truth
// src/igniter.context.ts
export const createIgniterAppContext = () => ({
  database: prismaClient,
  config: appConfig,
  // Other services
});

export type IgniterAppContext = ReturnType<typeof createIgniterAppContext>;

// ❌ WRONG: Manual type definition
export type IgniterAppContext = {
  database: any;  // Never use any
};
```

### Context Access Patterns
- **ALWAYS** access services through context, not direct imports
- **NEVER** import services directly in controllers
- **ALWAYS** use destructuring for context access

```typescript
// ✅ CORRECT
handler: async ({ context, response }) => {
  const users = await context.database.user.findMany();
}

// ❌ WRONG
import { database } from '@/services/database';
handler: async () => {
  const users = await database.user.findMany();
}
```

### Dynamic Context Extension
- **Procedures** extend context by returning objects
- **Context merging** is type-safe and cumulative
- **Each procedure** can add to the context chain

```typescript
// Authentication procedure adds 'user' to context
export const authProcedure = igniter.procedure({
  handler: async (_, { request }) => {
    const user = await verifyToken(request.headers);
    return { user }; // This extends the context
  }
});

// Now context has both database AND user
handler: async ({ context }) => {
  console.log(context.database); // From base context
  console.log(context.user);     // From auth procedure
}
```

## 🎮 Controllers and Actions Rules

### Controller Structure with TSDoc
```typescript
/**
 * @controller UsersController
 * @description Handles all user-related API operations including CRUD and authentication
 * @path /users
 * @tags Users, Authentication
 */
export const usersController = igniter.controller({
  name: 'users',        // Descriptive name
  path: '/users',       // Clear path
  description: 'User management and authentication endpoints',
  actions: {
    // Actions here
  }
});
```

### TSDoc Requirements for Controllers
- **@controller**: Name of the controller
- **@description**: Comprehensive description of purpose
- **@path**: Base path for all actions
- **@tags**: Categories for documentation
- **@security**: Authentication requirements (if applicable)

### Action Types
- **Use `query`** for GET requests (data fetching)
- **Use `mutation`** for POST/PUT/DELETE/PATCH (data modification)
- **Use `stream`** for Server-Sent Events

### Action Response Patterns with Documentation
```typescript
/**
 * @action list
 * @method GET
 * @description Retrieves paginated list of users with optional filtering
 * @query {page: number, limit: number, search?: string}
 * @returns {users: User[], pagination: PaginationMeta}
 * @throws {UnauthorizedError} When authentication fails
 */
list: igniter.query({
  name: 'List Users',
  path: '/' as const,
  query: z.object({
    page: z.number().default(1).describe('Page number'),
    limit: z.number().default(10).describe('Items per page'),
    search: z.string().optional().describe('Search term')
  }),
  handler: async ({ request, response }) => {
    // Business Rule: Apply pagination and filtering
    const { page, limit, search } = request.query;

    // Data Transformation: Format response with metadata
    return response.success({
      users: data,
      pagination: meta
    });
  }
})

/**
 * @action create
 * @method POST
 * @description Creates a new user account with validation
 * @body {email: string, name: string, password: string}
 * @returns {user: User}
 * @throws {ValidationError} Invalid input data
 * @throws {ConflictError} Email already exists
 */
create: igniter.mutation({
  name: 'Create User',
  path: '/' as const,
  body: CreateUserSchema,
  handler: async ({ request, response }) => {
    // Security Rule: Hash password before storage
    const hashedPassword = await hashPassword(request.body.password);

    // Business Logic: Create user with hashed password
    const user = await createUser({
      ...request.body,
      password: hashedPassword
    });

    // Response: Return created user and trigger cache update
    return response.created(user)
      .revalidate(['users.list']); // Trigger cache updates
  }
})

// ❌ WRONG: Missing documentation and response wrapper
handler: async () => {
  return { data }; // Missing TSDoc, response wrapper, and inline comments
}
```

### Inline Comment Requirements
Every significant line must have structured comments:
- `// Business Rule: [message]` - Business requirements
- `// Security Rule: [message]` - Security controls
- `// Data Transformation: [message]` - Data formatting
- `// Business Logic: [message]` - Core operations
- `// Response: [message]` - Response details

## 🔄 Procedures (Middleware) Rules

### Procedure Design
- **Single Responsibility**: Each procedure does ONE thing
- **Return Context Extensions**: Return objects to extend context
- **Accept Options**: Make procedures configurable

```typescript
// ✅ CORRECT: Configurable procedure
export const cacheProcedure = igniter.procedure({
  handler: async (options: CacheOptions = {}, { request, context }) => {
    const { ttl = 60 } = options;
    // Implementation
    return { cacheKey, ttl };
  }
});

// Usage with options
use: [cacheProcedure({ ttl: 300 })]
```

### Procedure Chaining
- **Order matters**: Procedures execute sequentially
- **Context accumulates**: Each procedure adds to context
- **Error handling**: Procedures can short-circuit on errors

```typescript
// Execution order: rate-limit → auth → cache
use: [
  rateLimitProcedure({ max: 100 }),
  authProcedure({ required: true }),
  cacheProcedure({ ttl: 60 })
]
```

## 🛣️ Routing Rules

### Path Construction
- **Controller path** + **Action path** = **Full route**
- **Use RESTful conventions** when applicable
- **Parameters** use `:param` syntax

```typescript
controller: {
  path: '/users',
  actions: {
    get: igniter.query({
      path: '/:id',  // Full path: /users/:id
    }),
    list: igniter.query({
      path: '/',     // Full path: /users/
    })
  }
}
```

### Router Registration
```typescript
// ✅ CORRECT: Register in main router
// src/igniter.router.ts
export const AppRouter = igniter.router({
  controllers: {
    users: usersController,
    posts: postsController,
    // All controllers must be registered here
  }
});
```

## ✅ Validation Rules

### Two-Layer Validation Strategy

#### Layer 1: Schema Validation (Zod)
- **Purpose**: Validate shape and type of data
- **When**: Before handler execution
- **Where**: In action definition

```typescript
create: igniter.mutation({
  body: z.object({
    email: z.string().email(),
    name: z.string().min(1).max(100),
    age: z.number().min(18)
  }),
  handler: async ({ request }) => {
    // request.body is now fully typed and validated
  }
})
```

#### Layer 2: Business Validation (Runtime)
- **Purpose**: Validate business rules and conditions
- **When**: Inside handler execution
- **Where**: Using ensure plugin or custom logic

```typescript
handler: async ({ context, request }) => {
  const user = await context.database.user.findUnique({
    where: { id: request.params.id }
  });

  // Business validation
  context.plugins.ensure.toBeDefined(user, "User not found");
  context.plugins.ensure.toBeTrue(
    user.isActive,
    "Account suspended"
  );
}
```

### Validation Best Practices
- **Validate early**: At the edge of your application
- **Be specific**: Provide clear error messages
- **Type narrow**: Use validation for TypeScript narrowing
- **Sanitize inputs**: Clean data before storage

## 🔌 Plugin Rules

### Plugin Integration
```typescript
// ✅ CORRECT: Named plugins with configuration
.plugins({
  auth: new AuthPlugin({ secret: process.env.JWT_SECRET }),
  cache: new CachePlugin({ ttl: 3600 }),
  ensure: new EnsurePlugin()
})

// Access in handlers
handler: async ({ context }) => {
  context.plugins.auth.verify(token);
  context.plugins.cache.get(key);
  context.plugins.ensure.toBeDefined(value);
}
```

### Plugin Development
- **Implement interface**: Follow `IgniterPlugin` contract
- **Extend context**: Plugins can add to context
- **Lifecycle hooks**: Support initialization and cleanup
- **Type safety**: Provide full TypeScript types

## 📚 Documentation Rules

### OpenAPI Generation
```typescript
.docs({
  openapi: '3.0.0',
  info: {
    title: 'API Title',
    version: '1.0.0',
    description: 'Comprehensive description'
  },
  playground: {
    enabled: process.env.NODE_ENV === 'development',
    route: '/docs'
  }
})
```

### Action Documentation
```typescript
list: igniter.query({
  name: 'List Users',  // Clear name
  description: 'Retrieve paginated users', // Purpose
  query: z.object({
    page: z.number().describe('Page number'),
    limit: z.number().describe('Items per page')
  })
})
```

## 🎯 Type Safety Rules

### Never Break the Chain
- **Generated files** maintain type chain
- **Context extensions** preserve types
- **Response types** flow to client
- **Validation** narrows types

### Type Inference Flow
```
Builder → Context → Procedures → Actions → Client
         ↓         ↓            ↓         ↓
      Types    Extended     Validated  Generated
```

## 🚨 Common Anti-Patterns

### ❌ Direct Service Import
```typescript
// WRONG
import { db } from '@/lib/db';
const users = await db.user.findMany();
```

### ❌ Missing Response Wrapper
```typescript
// WRONG
handler: async () => {
  return users; // No response.success()
}
```

### ❌ Context Type Mismatch
```typescript
// WRONG
type AppContext = { db: any }; // Never use any
```

### ❌ Procedure Without Return
```typescript
// WRONG
handler: async () => {
  const user = getUser();
  // Forgot to return { user }
}
```

### ❌ Validation After Processing
```typescript
// WRONG
handler: async ({ request }) => {
  const result = await process(request.body);
  validate(request.body); // Too late!
}
```

## 📋 Core Concepts Checklist

- [ ] Context defined with proper types
- [ ] Builder chain in correct order
- [ ] Controllers registered in router
- [ ] Actions use appropriate type (query/mutation)
- [ ] Procedures return context extensions
- [ ] Validation at both layers
- [ ] Responses use wrapper methods
- [ ] Documentation annotations present
- [ ] Type safety maintained throughout
- [ ] No direct service imports

---

**Remember**: These core concepts form the foundation of every Igniter.js application. Master these patterns for robust, type-safe, and maintainable APIs.