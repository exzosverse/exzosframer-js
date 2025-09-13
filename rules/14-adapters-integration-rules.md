# Adapters Integration Rules - Igniter.js Framework

## 🔌 Adapter Architecture Principles

### Core Adapter Principles
- **Interface-first design** - All adapters implement standard interfaces
- **Graceful degradation** - Continue operation when dependencies fail
- **Type-safe integration** - Complete type inference throughout
- **Factory pattern** - Consistent creation patterns across adapters
- **Client exposure** - Access underlying clients when needed

## 🗄️ Redis Adapter (Store)

### Store Adapter Configuration
```typescript
/**
 * @description Redis adapter for caching and pub/sub
 * @pattern Separate clients for commands and subscriptions
 */
import { createRedisStoreAdapter } from '@igniter-js/adapter-redis';
import Redis from 'ioredis';

// ✅ CORRECT: Create Redis client and adapter
const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  db: parseInt(process.env.REDIS_DB || '0'),

  // Connection options
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => Math.min(times * 50, 2000),
  enableReadyCheck: true,
  lazyConnect: false,
});

const storeAdapter = createRedisStoreAdapter(redis);

// Use in Igniter builder
const igniter = Igniter
  .context<AppContext>()
  .store(storeAdapter)
  .create();

// ❌ WRONG: Not handling connection errors
const redis = new Redis(); // No error handling
```

### Store Operations
```typescript
/**
 * @description Type-safe store operations
 */
// Key-value operations with JSON serialization
await igniter.store.set('user:123', {
  name: 'John',
  email: 'john@example.com'
}, { ttl: 3600 }); // 1 hour TTL

const user = await igniter.store.get<User>('user:123');

// Atomic operations
const count = await igniter.store.increment('counter:visits');
await igniter.store.expire('session:abc', 1800); // 30 minutes

// Pub/Sub messaging
await igniter.store.subscribe('user:events', (message) => {
  console.log('User event:', message);
});

await igniter.store.publish('user:events', {
  type: 'USER_CREATED',
  userId: '123',
  timestamp: Date.now()
});
```

### Cache-Aside Pattern
```typescript
/**
 * @description Cache-aside pattern implementation
 */
const getCachedUser = async (userId: string): Promise<User> => {
  const cacheKey = `user:${userId}`;

  // 1. Check cache
  const cached = await igniter.store.get<User>(cacheKey);
  if (cached) return cached;

  // 2. Fetch from database
  const user = await database.user.findUnique({
    where: { id: userId }
  });

  if (user) {
    // 3. Store in cache
    await igniter.store.set(cacheKey, user, { ttl: 3600 });
  }

  return user;
};
```

## 🎯 BullMQ Adapter (Jobs)

### Jobs Adapter Configuration
```typescript
/**
 * @description BullMQ adapter for background jobs
 * @pattern Router-based job organization
 */
import { createBullMQAdapter } from '@igniter-js/adapter-bullmq';

// ✅ CORRECT: Configure with context factory
const jobsAdapter = createBullMQAdapter<AppContext>({
  // Use Redis from store adapter
  store: storeAdapter,

  // Context factory for job execution
  contextFactory: async () => ({
    database: prisma,
    services: {
      email: emailService,
      sms: smsService,
    }
  }),

  // Global prefix for multi-tenancy
  globalPrefix: 'myapp',

  // Logger for debugging
  logger: console,
});

// ❌ WRONG: No context factory
const jobsAdapter = createBullMQAdapter(); // Jobs won't have context
```

### Job Definition Pattern
```typescript
/**
 * @description Type-safe job definition with validation
 */
import { z } from 'zod';

// Define job router
const emailJobs = igniter.jobs.router({
  namespace: 'email',

  jobs: {
    sendWelcome: {
      // Input validation schema
      input: z.object({
        userId: z.string(),
        templateData: z.object({
          name: z.string(),
          activationUrl: z.string(),
        })
      }),

      // Job handler with context
      handler: async ({ input, context }) => {
        const user = await context.database.user.findUnique({
          where: { id: input.userId }
        });

        if (!user) {
          throw new Error(`User ${input.userId} not found`);
        }

        await context.services.email.send({
          to: user.email,
          template: 'welcome',
          data: input.templateData,
        });

        return { success: true, emailId: user.email };
      },

      // Job configuration
      config: {
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 2000,
        },
        removeOnComplete: 100,
        removeOnFail: 500,
      },

      // Lifecycle hooks
      hooks: {
        onStart: async ({ jobId, input }) => {
          console.log(`Starting job ${jobId}`);
        },
        onSuccess: async ({ jobId, result }) => {
          console.log(`Job ${jobId} completed:`, result);
        },
        onFailure: async ({ jobId, error }) => {
          console.error(`Job ${jobId} failed:`, error);
        },
      },
    },
  },
});
```

### Advanced Scheduling
```typescript
/**
 * @description Advanced job scheduling patterns
 */
// Business hours scheduling
await igniter.jobs.email.sendReport.schedule({
  input: { reportType: 'daily' },
  options: {
    delay: 0,
    schedule: {
      pattern: 'businessHours', // 9 AM - 5 PM weekdays
      timezone: 'America/New_York',
    },
  },
});

// Cron pattern
await igniter.jobs.maintenance.cleanup.schedule({
  input: {},
  options: {
    repeat: {
      pattern: '0 2 * * *', // Daily at 2 AM
      timezone: 'UTC',
    },
  },
});

// Conditional scheduling
await igniter.jobs.notifications.digest.schedule({
  input: { userId: '123' },
  options: {
    delay: 60000, // 1 minute
    condition: async () => {
      // Only run if user is active
      const user = await getUser('123');
      return user.status === 'active';
    },
  },
});
```

### Job Router Merging
```typescript
/**
 * @description Merge multiple job routers
 */
const emailJobs = igniter.jobs.router({ /* ... */ });
const analyticsJobs = igniter.jobs.router({ /* ... */ });
const maintenanceJobs = igniter.jobs.router({ /* ... */ });

// Merge routers
const allJobs = igniter.jobs.merge({
  email: emailJobs,
  analytics: analyticsJobs,
  maintenance: maintenanceJobs,
});

// Register with builder
const igniter = Igniter
  .context<AppContext>()
  .jobs(allJobs)
  .create();

// Usage with namespaces
await igniter.jobs.email.sendWelcome.enqueue({ userId: '123' });
await igniter.jobs.analytics.trackEvent.enqueue({ event: 'signup' });
```

## 🤖 MCP Server Adapter

### MCP Adapter Configuration
```typescript
/**
 * @description MCP adapter for AI tool integration
 * @pattern Router-to-tool mapping
 */
import { createMcpAdapter } from '@igniter-js/adapter-mcp-server';

// ✅ CORRECT: Configure with context and options
const mcpAdapter = createMcpAdapter(AppRouter, {
  // Custom context for MCP tools
  contextFunction: async () => ({
    database: prisma,
    ai: openaiClient,
  }),

  // Tool filtering
  filterTools: (tool) => {
    // Only expose public tools
    return !tool.name.startsWith('internal.');
  },

  // Tool transformation
  transformTool: (tool) => ({
    ...tool,
    description: `[API] ${tool.description}`,
  }),

  // Response transformation
  transformResponse: (response) => ({
    success: response.status === 200,
    data: response.body,
  }),

  // Event hooks
  onToolExecutionStart: async ({ tool, args }) => {
    console.log(`Executing MCP tool: ${tool}`, args);
  },

  onToolExecutionEnd: async ({ tool, result }) => {
    console.log(`Tool completed: ${tool}`, result);
  },
});

// ❌ WRONG: No context or configuration
const mcpAdapter = createMcpAdapter(AppRouter); // Limited functionality
```

### Custom MCP Tools
```typescript
/**
 * @description Add custom tools beyond router actions
 */
const mcpAdapter = createMcpAdapter(AppRouter, {
  customTools: [
    {
      name: 'search_documentation',
      description: 'Search the project documentation',
      schema: z.object({
        query: z.string(),
        limit: z.number().optional().default(10),
      }),
      handler: async ({ args, context }) => {
        const results = await searchDocs(args.query, args.limit);
        return { results };
      },
    },
    {
      name: 'analyze_codebase',
      description: 'Analyze codebase structure',
      schema: z.object({
        path: z.string(),
      }),
      handler: async ({ args }) => {
        const analysis = await analyzeCode(args.path);
        return { analysis };
      },
    },
  ],
});
```

## 📊 OpenTelemetry Adapter

### Telemetry Configuration
```typescript
/**
 * @description OpenTelemetry adapter for observability
 * @pattern Multiple exporters with auto-instrumentation
 */
import { createOpenTelemetryAdapter } from '@igniter-js/adapter-opentelemetry';

// ✅ CORRECT: Production configuration
const telemetryAdapter = await createOpenTelemetryAdapter({
  serviceName: 'my-api',
  serviceVersion: '1.0.0',
  environment: process.env.NODE_ENV,

  // Trace exporters
  traceExporters: ['jaeger', 'console'],

  // Metric exporters
  metricExporters: ['prometheus'],

  // Exporter configurations
  jaegerEndpoint: process.env.JAEGER_ENDPOINT,
  prometheusPort: 9090,

  // Auto-instrumentation
  instrumentations: {
    http: true,
    fs: true,
    dns: true,
  },

  // Sampling
  traceSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
});

// ❌ WRONG: No configuration
const telemetryAdapter = createOpenTelemetryAdapter(); // Missing config
```

### Tracing Patterns
```typescript
/**
 * @description Distributed tracing patterns
 */
// Manual span creation
const span = igniter.telemetry.startSpan('database.query', {
  attributes: {
    'db.system': 'postgresql',
    'db.statement': 'SELECT * FROM users',
  },
});

try {
  const result = await database.query(sql);
  span.setStatus({ code: 'OK' });
  return result;
} catch (error) {
  span.recordException(error);
  span.setStatus({ code: 'ERROR', message: error.message });
  throw error;
} finally {
  span.end();
}

// Automatic instrumentation in actions
const action = igniter.query({
  handler: async ({ context, telemetry }) => {
    // Automatic span created for this action

    // Child spans for operations
    await telemetry.trace('cache.lookup', async () => {
      return await context.store.get('key');
    });

    await telemetry.trace('database.query', async () => {
      return await context.database.user.findMany();
    });
  },
});
```

### Metrics Collection
```typescript
/**
 * @description Metrics and monitoring patterns
 */
// Counter metrics
igniter.telemetry.metrics.counter('api.requests', {
  labels: { endpoint: '/users', method: 'GET' },
}).add(1);

// Histogram for latency
const timer = igniter.telemetry.metrics.histogram('api.latency', {
  buckets: [0.1, 0.5, 1, 2, 5],
});

const end = timer.startTimer();
// ... operation ...
end({ endpoint: '/users' });

// Gauge for current values
igniter.telemetry.metrics.gauge('queue.size', {
  labels: { queue: 'email' },
}).set(42);
```

## 🔄 Common Integration Patterns

### Adapter Composition
```typescript
/**
 * @description Combine multiple adapters
 */
const igniter = Igniter
  .context<AppContext>()

  // Layer adapters for full functionality
  .store(redisAdapter)        // Caching & pub/sub
  .jobs(bullmqAdapter)        // Background processing
  .telemetry(otelAdapter)     // Observability

  // Adapters can reference each other
  .config({
    // BullMQ uses Redis from store
    jobsUseStoreRedis: true,
  })

  .create();
```

### Error Handling Pattern
```typescript
/**
 * @description Graceful degradation for adapters
 */
// All adapters handle missing dependencies gracefully
try {
  const storeAdapter = createRedisStoreAdapter(redis);
} catch (error) {
  console.warn('Redis unavailable, using in-memory store');
  const storeAdapter = createInMemoryAdapter();
}

// No-op fallbacks prevent crashes
if (!isServer) {
  // Browser environment - return no-op adapter
  return {} as IgniterStoreAdapter;
}
```

### Context Enhancement
```typescript
/**
 * @description Adapters enhance action context
 */
const action = igniter.query({
  handler: async ({ context }) => {
    // All adapters available in context

    // Store operations
    await context.store.set('key', 'value');

    // Job scheduling
    await context.jobs.email.send.enqueue({ to: 'user@example.com' });

    // Telemetry
    context.telemetry.startSpan('operation');

    // Direct client access
    const redisClient = context.store.client;
  },
});
```

## 🚨 Adapter Anti-Patterns

### ❌ Missing Error Handling
```typescript
// WRONG: No error handling
const redis = new Redis();
const adapter = createRedisStoreAdapter(redis);

// CORRECT: Handle connection errors
const redis = new Redis({
  retryStrategy: (times) => Math.min(times * 50, 2000),
});

redis.on('error', (err) => {
  console.error('Redis error:', err);
});
```

### ❌ Blocking Operations
```typescript
// WRONG: Synchronous operations
const value = redis.getSync('key'); // Blocks event loop

// CORRECT: Always use async
const value = await redis.get('key');
```

### ❌ Memory Leaks
```typescript
// WRONG: Not cleaning up subscriptions
igniter.store.subscribe('channel', handler);
// Never unsubscribed

// CORRECT: Clean up subscriptions
const unsubscribe = await igniter.store.subscribe('channel', handler);
// Later...
await unsubscribe();
```

## 📋 Adapter Integration Checklist

### Setup
- [ ] Install adapter packages
- [ ] Configure connection settings
- [ ] Set up error handling
- [ ] Configure environment variables

### Redis Adapter
- [ ] Configure connection pooling
- [ ] Set up pub/sub channels
- [ ] Implement cache strategies
- [ ] Handle connection errors

### BullMQ Adapter
- [ ] Define job routers
- [ ] Configure context factory
- [ ] Set up job scheduling
- [ ] Implement lifecycle hooks

### MCP Adapter
- [ ] Configure tool filtering
- [ ] Add custom tools
- [ ] Set up event hooks
- [ ] Test tool execution

### OpenTelemetry Adapter
- [ ] Configure exporters
- [ ] Set up sampling rates
- [ ] Enable auto-instrumentation
- [ ] Configure metrics collection

---

**Remember**: Adapters provide the bridge between Igniter.js and external services. Always configure them with proper error handling, use type-safe patterns, and leverage graceful degradation to ensure resilience.