# Advanced Features Rules - Igniter.js Framework

## 🚀 Realtime (SSE) Rules

### Core Realtime Principles
- **Single SSE connection** per client for efficiency
- **Channel-based** communication model
- **Server-to-client only** (unidirectional)
- **Automatic reconnection** on connection loss

### Automatic UI Revalidation
```typescript
// ✅ CORRECT: Mutation with revalidation
create: igniter.mutation({
  handler: async ({ request, context, response }) => {
    const newPost = await context.database.post.create({
      data: request.body
    });

    // Trigger automatic refetch on all clients
    return response.created(newPost)
      .revalidate(['posts.list']); // Query key to invalidate
  }
})

// ❌ WRONG: Forgot revalidation
create: igniter.mutation({
  handler: async ({ request, context, response }) => {
    const newPost = await context.database.post.create({
      data: request.body
    });
    return response.created(newPost); // No revalidation!
  }
})
```

### Scoped Revalidation Rules
- **Define scopes** in IgniterProvider on client
- **Target specific users** with scope functions
- **Use consistent scope naming**: `user:id`, `role:name`, `tenant:id`

```typescript
// ✅ CORRECT: Scoped revalidation
updateProfile: igniter.mutation({
  use: [authProcedure()],
  handler: async ({ context, response }) => {
    const updated = await updateUser(context.user.id);

    // Only revalidate for the specific user
    return response.success(updated)
      .revalidate(
        ['user.profile'],
        (ctx) => [`user:${ctx.user.id}`] // Scope function
      );
  }
})
```

### Custom Data Streams
```typescript
// ✅ CORRECT: Custom stream action
notifications: igniter.query({
  path: '/stream',
  stream: true, // Enable streaming
  handler: async ({ response, request, context }) => {
    const stream = response.stream();

    // Send initial data
    stream.send({
      event: 'initial',
      data: { notifications: [] }
    });

    // Set up subscription
    const unsubscribe = context.store.subscribe(
      `notifications:${context.user.id}`,
      (data) => {
        stream.send({
          event: 'notification',
          data
        });
      }
    );

    // Clean up on disconnect
    request.signal.addEventListener('abort', () => {
      unsubscribe();
      stream.close();
    });

    return stream;
  }
})
```

## 💾 Store (Redis) Rules

### Store Configuration
```typescript
// ✅ CORRECT: Redis store setup
import { RedisAdapter } from '@igniter-js/adapter-redis';

const store = new RedisAdapter({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  db: 0,
  keyPrefix: 'igniter:' // Namespace keys
});

const igniter = Igniter
  .context<AppContext>()
  .store(store)
  .create();
```

### Key-Value Operations
```typescript
// ✅ CORRECT: Store usage patterns
handler: async ({ context }) => {
  // Set with TTL
  await context.store.set('key', value, 3600); // 1 hour TTL

  // Get with type safety
  const cached = await context.store.get<UserData>('key');

  // Delete
  await context.store.delete('key');

  // Check existence
  const exists = await context.store.exists('key');

  // Atomic increment
  const count = await context.store.incr('counter');
}
```

### Pub/Sub Patterns
```typescript
// ✅ CORRECT: Pub/Sub implementation
// Publisher
await context.store.publish('channel:updates', {
  type: 'USER_UPDATED',
  userId: user.id,
  changes: updates
});

// Subscriber
const unsubscribe = await context.store.subscribe(
  'channel:updates',
  (message) => {
    console.log('Received:', message);
  }
);

// Clean up
unsubscribe();
```

### Cache-Aside Pattern
```typescript
// ✅ CORRECT: Cache-aside implementation
handler: async ({ context, response }) => {
  const cacheKey = `users:list:${page}:${limit}`;

  // Check cache first
  const cached = await context.store.get(cacheKey);
  if (cached) {
    return response.success(JSON.parse(cached));
  }

  // Fetch from database
  const users = await context.database.user.findMany({
    skip: (page - 1) * limit,
    take: limit
  });

  // Cache the result
  await context.store.set(
    cacheKey,
    JSON.stringify(users),
    300 // 5 minutes TTL
  );

  return response.success(users);
}
```

## 🔧 Queues (BullMQ) Rules

### Queue Configuration
```typescript
// ✅ CORRECT: BullMQ setup
import { BullMQAdapter } from '@igniter-js/adapter-bullmq';

const jobs = new BullMQAdapter({
  connection: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
  },
  defaultJobOptions: {
    removeOnComplete: 100,  // Keep last 100 completed
    removeOnFail: 50,       // Keep last 50 failed
    attempts: 3,            // Retry 3 times
    backoff: {
      type: 'exponential',
      delay: 2000
    }
  }
});
```

### Job Definition
```typescript
// ✅ CORRECT: Type-safe job definition
// src/services/jobs.ts
import { z } from 'zod';

export const emailJobs = igniter.jobs('emails', {
  sendWelcome: {
    input: z.object({
      userId: z.string(),
      email: z.string().email()
    }),
    handler: async ({ input }) => {
      await sendEmail({
        to: input.email,
        template: 'welcome',
        data: { userId: input.userId }
      });
    }
  },

  sendNewsletter: {
    input: z.object({
      userIds: z.array(z.string()),
      subject: z.string()
    }),
    handler: async ({ input }) => {
      // Bulk email logic
    }
  }
});
```

### Job Scheduling
```typescript
// ✅ CORRECT: Scheduling jobs
handler: async ({ context, response }) => {
  const user = await createUser(data);

  // Schedule immediate job
  await context.jobs.emails.schedule({
    task: 'sendWelcome',
    input: {
      userId: user.id,
      email: user.email
    }
  });

  // Schedule delayed job
  await context.jobs.emails.schedule({
    task: 'sendNewsletter',
    input: { userIds: [user.id], subject: 'Welcome!' },
    options: {
      delay: 24 * 60 * 60 * 1000, // 24 hours
      priority: 1
    }
  });

  return response.created(user);
}
```

### Job Processing Rules
- **Idempotent handlers**: Jobs may be retried
- **Error handling**: Use try-catch and proper logging
- **Timeout configuration**: Set realistic timeouts
- **Progress reporting**: Use job.updateProgress() for long tasks

## 📊 OpenAPI Documentation Rules

### Documentation Configuration
```typescript
// ✅ CORRECT: OpenAPI setup
const igniter = Igniter
  .context<AppContext>()
  .docs({
    openapi: '3.0.0',
    info: {
      title: 'My API',
      version: '1.0.0',
      description: 'API Documentation',
      contact: {
        email: 'api@example.com'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: 'https://api.production.com',
        description: 'Production'
      },
      {
        url: 'http://localhost:3000',
        description: 'Development'
      }
    ],
    playground: {
      enabled: true,
      route: '/docs',
      security: (request) => {
        // Custom access control
        return process.env.NODE_ENV === 'development';
      }
    }
  })
  .create();
```

### Action Documentation
```typescript
// ✅ CORRECT: Well-documented action
list: igniter.query({
  name: 'List Users',
  description: 'Retrieve a paginated list of users with optional filtering',
  tags: ['Users'],
  query: z.object({
    page: z.number()
      .optional()
      .default(1)
      .describe('Page number (1-based)'),
    limit: z.number()
      .optional()
      .default(10)
      .describe('Number of items per page'),
    search: z.string()
      .optional()
      .describe('Search term for filtering users'),
    role: z.enum(['admin', 'user'])
      .optional()
      .describe('Filter by user role')
  }),
  handler: async ({ request, context, response }) => {
    // Implementation
  }
})
```

### Security Schemes
```typescript
// ✅ CORRECT: Security configuration
.docs({
  securitySchemes: {
    bearerAuth: {
      type: 'http',
      scheme: 'bearer',
      bearerFormat: 'JWT',
      description: 'JWT Bearer token authentication'
    },
    apiKey: {
      type: 'apiKey',
      in: 'header',
      name: 'X-API-Key',
      description: 'API Key authentication'
    }
  }
})

// Apply to actions
authenticated: igniter.query({
  security: [{ bearerAuth: [] }],
  handler: async ({ context }) => {
    // Handler for authenticated endpoint
  }
})
```

## 🎭 Igniter Studio Rules

### Studio Configuration
```typescript
// ✅ CORRECT: Studio setup
.docs({
  playground: {
    enabled: process.env.NODE_ENV !== 'production',
    route: '/studio',
    theme: 'dark',
    authentication: {
      type: 'bearer',
      default: process.env.DEV_TOKEN
    },
    defaultHeaders: {
      'X-Request-Source': 'studio'
    }
  }
})
```

### Studio Best Practices
- **Development only**: Disable in production
- **Authentication**: Require auth for sensitive environments
- **Custom headers**: Add tracking headers
- **Environment presets**: Configure for different environments

## 🔌 Telemetry Rules

### OpenTelemetry Configuration
```typescript
// ✅ CORRECT: Telemetry setup
import { OpenTelemetryAdapter } from '@igniter-js/adapter-opentelemetry';

const telemetry = new OpenTelemetryAdapter({
  serviceName: 'my-api',
  serviceVersion: process.env.npm_package_version,
  environment: process.env.NODE_ENV,
  exporters: {
    traces: {
      type: 'otlp',
      endpoint: process.env.OTEL_EXPORTER_OTLP_ENDPOINT
    },
    metrics: {
      type: 'prometheus',
      port: 9090
    }
  },
  sampling: {
    ratio: process.env.NODE_ENV === 'production' ? 0.1 : 1.0
  }
});
```

### Custom Spans
```typescript
// ✅ CORRECT: Custom instrumentation
handler: async ({ context }) => {
  const span = context.telemetry.startSpan('database.query');

  try {
    span.setAttributes({
      'db.system': 'postgresql',
      'db.operation': 'SELECT',
      'db.table': 'users'
    });

    const result = await context.database.user.findMany();

    span.setStatus({ code: SpanStatusCode.OK });
    return result;
  } catch (error) {
    span.recordException(error);
    span.setStatus({
      code: SpanStatusCode.ERROR,
      message: error.message
    });
    throw error;
  } finally {
    span.end();
  }
}
```

## 🚨 Advanced Features Anti-Patterns

### ❌ Memory Leaks in Streams
```typescript
// WRONG: No cleanup
handler: async ({ response }) => {
  const stream = response.stream();
  setInterval(() => {
    stream.send(data);
  }, 1000);
  // Interval never cleared!
  return stream;
}
```

### ❌ Unbounded Cache Growth
```typescript
// WRONG: No TTL
await context.store.set(key, value); // No expiration!
```

### ❌ Job Without Error Handling
```typescript
// WRONG: No error handling
handler: async ({ input }) => {
  await riskyOperation(input); // May fail!
}
```

### ❌ Broadcasting to All Clients
```typescript
// WRONG: No scoping
return response.success(data)
  .revalidate(['sensitive.data']); // Goes to everyone!
```

## 📋 Advanced Features Checklist

- [ ] SSE connection properly managed
- [ ] Revalidation keys consistent
- [ ] Scopes defined for targeted updates
- [ ] Cache keys have appropriate TTL
- [ ] Pub/Sub subscriptions cleaned up
- [ ] Jobs are idempotent
- [ ] Job retry logic configured
- [ ] OpenAPI documentation complete
- [ ] Security schemes defined
- [ ] Telemetry sampling appropriate
- [ ] Custom spans have proper attributes
- [ ] Stream cleanup on disconnect
- [ ] Error handling in all async operations

---

**Remember**: Advanced features require careful consideration of performance, scalability, and resource management. Always implement proper cleanup and error handling.