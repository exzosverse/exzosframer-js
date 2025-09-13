# Core Architecture Rules - Igniter.js Framework

## 🏗️ Core Architecture Principles

### Foundation Principles
- **Type-safe by design** - Complete type inference from server to client
- **Fluent builder pattern** - Intuitive configuration through method chaining
- **Processor pipeline** - Modular request processing with clear boundaries
- **Framework agnostic** - Adapter pattern for any framework integration
- **Plugin extensibility** - Self-referential plugins with type safety

## 🎯 Builder Pattern

### Fluent Configuration
```typescript
/**
 * @description Core builder pattern for framework initialization
 * @pattern Immutable builder with type flow
 */
import { Igniter } from '@igniter-js/core';

// ✅ CORRECT: Fluent builder pattern
export const igniter = Igniter
  // 1. Define base context type
  .context<AppContext>()

  // 2. Register global middleware
  .middleware([
    corsMiddleware(),
    authMiddleware(),
    rateLimitMiddleware()
  ])

  // 3. Configure adapters
  .store(redisStore)           // Caching & pub/sub
  .logger(structuredLogger)    // Logging
  .jobs(bullmqJobs)            // Background jobs
  .telemetry(openTelemetry)   // Metrics & tracing

  // 4. Register plugins
  .plugins({
    auth: authPlugin,
    ensure: ensurePlugin,
    mail: mailPlugin
  })

  // 5. Configure documentation
  .docs({
    openapi: {
      info: { title: 'API', version: '1.0.0' },
      servers: [{ url: 'https://api.example.com' }]
    }
  })

  // 6. Set configuration
  .config({
    baseURL: process.env.API_URL || 'http://localhost:3000',
    basePath: '/api/v1',
    timeout: 30000,
    customProperty: 'value' // Type-safe custom config
  })

  // 7. Create instance
  .create();

// ❌ WRONG: Breaking the chain
const builder = Igniter.context<AppContext>();
builder.store = redisStore; // Direct assignment breaks type flow
```

### Context Type Flow
```typescript
/**
 * @description Type-safe context enhancement
 */
// Base context
interface BaseContext {
  database: PrismaClient;
  services: {
    email: EmailService;
    sms: SMSService;
  };
}

// Middleware can enhance context
const authMiddleware = igniter.middleware({
  handler: async (_, { request }) => {
    const user = await validateToken(request.headers.authorization);
    return { user }; // This extends context
  }
});

// Actions receive enhanced context
const action = igniter.query({
  use: [authMiddleware],
  handler: ({ context }) => {
    // context.user is available and typed
    // context.database is from base context
    // context.plugins.* are from registered plugins
  }
});
```

## 📡 Request Processing Pipeline

### Processor Chain
```typescript
/**
 * @description Request processing stages
 * @pattern Chain of Responsibility
 */
enum ProcessingStage {
  ROUTE_RESOLUTION = "route-resolver",
  CONTEXT_BUILDING = "context-builder",
  MIDDLEWARE_EXECUTION = "middleware-executor",
  VALIDATION = "validator",
  HANDLER_EXECUTION = "handler",
  RESPONSE_PROCESSING = "response-processor",
  TELEMETRY = "telemetry"
}

// Each processor has single responsibility
interface Processor<TIn, TOut> {
  process(input: TIn): Promise<TOut>;
  canHandle(input: TIn): boolean;
  onError(error: Error, input: TIn): void;
}
```

### Route Resolution
```typescript
/**
 * @description Efficient route matching with rou3
 */
// ✅ CORRECT: Let router handle path matching
const router = igniter.router({
  controllers: {
    users: usersController,
    posts: postsController
  }
});

// Router automatically handles:
// - Path parameter extraction
// - Method matching
// - 404 responses
// - Route precedence

// ❌ WRONG: Manual route parsing
if (request.url.includes('/users')) {
  // Manual parsing is error-prone
}
```

## 🔌 Adapter System

### Framework Adapters
```typescript
/**
 * @description Adapter pattern for framework integration
 */
// Next.js adapter
import { nextRouteHandlerAdapter } from '@igniter-js/core/adapters';

export async function handler(req: NextRequest) {
  return nextRouteHandlerAdapter(AppRouter.handler)(req);
}

// Express adapter
import { expressAdapter } from '@igniter-js/core/adapters';

app.use('/api/v1', expressAdapter(AppRouter.handler));

// Custom adapter implementation
const customAdapter = (handler: IgniterHandler) => {
  return async (customReq: CustomRequest) => {
    // Transform custom request to standard Request
    const standardReq = new Request(customReq.url, {
      method: customReq.method,
      headers: customReq.headers,
      body: customReq.body
    });

    // Process with Igniter
    const response = await handler(standardReq);

    // Transform Response back to custom format
    return transformResponse(response);
  };
};
```

### Store Adapter Interface
```typescript
/**
 * @description Unified store interface
 */
interface IgniterStoreAdapter {
  // Key-value operations
  get(key: string): Promise<string | null>;
  set(key: string, value: string, ttl?: number): Promise<void>;
  del(key: string): Promise<void>;

  // Pub/sub operations
  publish(channel: string, message: string): Promise<void>;
  subscribe(channel: string, handler: (msg: string) => void): Subscription;

  // Set operations
  sadd(key: string, ...members: string[]): Promise<number>;
  srem(key: string, ...members: string[]): Promise<number>;
  smembers(key: string): Promise<string[]>;
}

// Implementation example
const redisAdapter: IgniterStoreAdapter = {
  async get(key) {
    return await redis.get(key);
  },
  async set(key, value, ttl) {
    if (ttl) {
      await redis.setex(key, ttl, value);
    } else {
      await redis.set(key, value);
    }
  },
  // ... other methods
};
```

## 🎨 Plugin Architecture

### Self-Referential Plugins
```typescript
/**
 * @description Plugins with access to their own actions
 * @pattern Self-reference with type safety
 */
const authPlugin = igniter.plugin({
  name: 'auth',

  // Define plugin actions
  actions: {
    login: igniter.mutation({
      body: LoginSchema,
      handler: async ({ request, self }) => {
        const { email, password } = request.body;

        // Plugin can call its own actions
        const user = await self.validateUser({ email, password });
        const token = await self.generateToken({ userId: user.id });

        return { user, token };
      }
    }),

    validateUser: igniter.query({
      handler: async ({ request }) => {
        // Validation logic
      }
    }),

    generateToken: igniter.query({
      handler: async ({ request }) => {
        // Token generation
      }
    })
  },

  // Extend context with plugin utilities
  context: () => ({
    auth: {
      getCurrentUser: async () => { /* ... */ },
      hasPermission: async (permission: string) => { /* ... */ }
    }
  })
});

// Usage in actions
const protectedAction = igniter.query({
  handler: async ({ context }) => {
    // Access plugin context
    const user = await context.plugins.auth.getCurrentUser();

    // Call plugin actions
    const token = await context.plugins.auth.generateToken({
      userId: user.id
    });
  }
});
```

### Plugin Events
```typescript
/**
 * @description Event-driven plugin communication
 */
const analyticsPlugin = igniter.plugin({
  name: 'analytics',

  // Subscribe to events
  onInit: async ({ subscribe }) => {
    await subscribe('user:created', async (data) => {
      await trackEvent('User Signup', data);
    });

    await subscribe('order:completed', async (data) => {
      await trackRevenue(data.amount);
    });
  },

  // Publish events
  actions: {
    track: igniter.mutation({
      handler: async ({ request, publish }) => {
        await publish('analytics:event', request.body);
      }
    })
  }
});
```

## 🎯 Type System Patterns

### Complete Type Inference
```typescript
/**
 * @description End-to-end type safety
 */
// Server-side definition
const userController = igniter.controller({
  actions: {
    create: igniter.mutation({
      body: z.object({
        name: z.string(),
        email: z.string().email()
      }),
      handler: async ({ request }) => {
        const user = await createUser(request.body);
        return { user };
      }
    })
  }
});

// Client-side usage (auto-generated types)
const { data, error } = await api.users.create.mutate({
  name: "John", // Type-checked
  email: "john@example.com" // Type-checked
});

// data.user is fully typed
// error is typed with possible error shapes
```

### Schema Integration
```typescript
/**
 * @description Zod schema integration
 */
// ✅ CORRECT: Define schemas separately
const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  role: z.enum(['admin', 'user'])
});

const CreateUserSchema = UserSchema.omit({ id: true });
const UpdateUserSchema = CreateUserSchema.partial();

// Use in actions
const createUser = igniter.mutation({
  body: CreateUserSchema,
  handler: async ({ request }) => {
    // request.body is typed as z.infer<typeof CreateUserSchema>
  }
});

// ❌ WRONG: Inline complex schemas
const action = igniter.mutation({
  body: z.object({
    // Complex inline schema is hard to maintain
    user: z.object({
      profile: z.object({
        // Deeply nested...
      })
    })
  })
});
```

## 🚦 Error Handling

### Structured Errors
```typescript
/**
 * @description Consistent error handling
 */
import { IgniterError } from '@igniter-js/core';

// ✅ CORRECT: Use IgniterError for structured errors
throw new IgniterError({
  code: 'USER_NOT_FOUND',
  message: 'User does not exist',
  statusCode: 404,
  metadata: {
    userId: request.params.id,
    timestamp: new Date().toISOString()
  }
});

// Error boundaries in processors
class CustomProcessor {
  async process(input: ProcessorInput) {
    try {
      return await this.execute(input);
    } catch (error) {
      // Log to telemetry
      this.telemetry.recordError(error);

      // Transform to client-safe error
      if (error instanceof IgniterError) {
        return error.toResponse();
      }

      // Generic error for unexpected cases
      return new IgniterError({
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
        statusCode: 500
      }).toResponse();
    }
  }
}
```

## 🔄 Client-Server Communication

### Universal Client
```typescript
/**
 * @description Environment-aware client
 */
// Client detects environment automatically
import { createIgniterClient } from '@igniter-js/core/client';

const client = createIgniterClient<AppRouter>({
  baseURL: process.env.NEXT_PUBLIC_API_URL,

  // Browser: Uses fetch
  // Server: Can use direct calls
  // Worker: Uses fetch with specific headers

  // Custom fetch implementation
  fetch: async (url, options) => {
    // Add custom headers, auth, etc.
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'X-Custom-Header': 'value'
      }
    });
  }
});
```

### Server-Side Calling
```typescript
/**
 * @description Direct server invocation
 */
// In server components or API routes
const result = await AppRouter.$caller.users.create({
  body: { name: 'John', email: 'john@example.com' }
});

// Benefits:
// - No HTTP overhead
// - Full type safety
// - Direct database access
// - Useful for testing
```

## 🚨 Core Anti-Patterns

### ❌ Breaking Type Chain
```typescript
// WRONG: Losing type information
const builder = Igniter.context();
const configured = builder.store(store);
// Types are lost between assignments

// CORRECT: Maintain chain
const igniter = Igniter
  .context<Context>()
  .store(store)
  .create();
```

### ❌ Manual Route Handling
```typescript
// WRONG: Bypassing router
if (req.url === '/api/users') {
  // Manual handling
}

// CORRECT: Use router
const router = igniter.router({
  controllers: { users: userController }
});
```

### ❌ Context Pollution
```typescript
// WRONG: Modifying context directly
handler: ({ context }) => {
  context.newProp = 'value'; // Mutation!
}

// CORRECT: Return new context from middleware
middleware: () => {
  return { newProp: 'value' };
}
```

## 📋 Core Architecture Checklist

### Initialization
- [ ] Define base context type
- [ ] Configure adapters (store, logger, jobs)
- [ ] Register global middleware
- [ ] Set up plugins with proper types
- [ ] Configure documentation

### Development
- [ ] Use fluent builder pattern
- [ ] Maintain type chain
- [ ] Implement proper error boundaries
- [ ] Use structured errors
- [ ] Follow processor patterns

### Integration
- [ ] Choose appropriate adapter
- [ ] Configure framework-specific settings
- [ ] Set up environment detection
- [ ] Implement proper error handling
- [ ] Configure telemetry

### Testing
- [ ] Use server-side caller for tests
- [ ] Mock adapters properly
- [ ] Test middleware composition
- [ ] Validate type inference
- [ ] Test error scenarios

---

**Remember**: The core architecture is designed for extensibility and type safety. Always maintain the type chain, use appropriate adapters, and leverage the plugin system for modular functionality.