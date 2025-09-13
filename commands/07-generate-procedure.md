# Command: `igniter generate procedure`

## Overview
Generates reusable middleware procedures that extend context and provide shared functionality across controllers.

## Syntax
```bash
igniter generate procedure <name> [options]
```

## Arguments
- `name` (required): Procedure name
  - Should describe the functionality (auth, cache, validate)
  - Converted to camelCase with "Procedure" suffix

## Options

### `--type <type>`
- **Type**: String
- **Values**: `auth`, `cache`, `validate`, `rate-limit`, `repository`, `custom`
- **Default**: `custom`
- **Description**: Procedure template type

### `--path <path>`
- **Type**: String
- **Default**: `src/features/<feature>/procedures/`
- **Description**: Output path for procedure file

### `--feature <name>`
- **Type**: String
- **Default**: Current feature or shared
- **Description**: Feature to place procedure in

## Procedure Types

### Authentication Procedure
```typescript
import { igniter } from '@/igniter';
import { TRPCError } from '@trpc/server';
import { verifyToken } from '@/lib/auth';

interface AuthOptions {
  required?: boolean;
  roles?: string[];
}

export const authProcedure = igniter.procedure({
  name: 'Authentication',
  description: 'Validates user authentication and adds user to context',
  handler: async (options: AuthOptions = {}, { request, context }) => {
    const { required = true, roles = [] } = options;

    const token = request.headers.get('Authorization')?.replace('Bearer ', '');

    if (!token && required) {
      throw new TRPCError({
        code: 'UNAUTHORIZED',
        message: 'Authentication required'
      });
    }

    if (token) {
      const user = await verifyToken(token);

      if (!user && required) {
        throw new TRPCError({
          code: 'UNAUTHORIZED',
          message: 'Invalid token'
        });
      }

      if (user && roles.length > 0) {
        if (!roles.includes(user.role)) {
          throw new TRPCError({
            code: 'FORBIDDEN',
            message: 'Insufficient permissions'
          });
        }
      }

      // Return data to merge into context
      return { user };
    }

    return {};
  }
});
```

### Cache Procedure
```typescript
import { igniter } from '@/igniter';
import { createHash } from 'crypto';

interface CacheOptions {
  ttl?: number; // Time to live in seconds
  key?: string; // Custom cache key
}

export const cacheProcedure = igniter.procedure({
  name: 'Cache',
  description: 'Caches responses using Redis store',
  handler: async (options: CacheOptions = {}, { request, context }) => {
    const { ttl = 60, key } = options;

    // Generate cache key from request
    const cacheKey = key || createHash('md5')
      .update(`${request.method}:${request.path}:${JSON.stringify(request.query)}`)
      .digest('hex');

    // Check cache first
    if (context.store) {
      const cached = await context.store.get(cacheKey);
      if (cached) {
        return {
          cached: true,
          cachedData: JSON.parse(cached),
          cacheKey,
          ttl
        };
      }
    }

    // Return cache metadata for handler to use
    return {
      cached: false,
      cacheKey,
      ttl,
      setCacheData: async (data: any) => {
        if (context.store) {
          await context.store.set(
            cacheKey,
            JSON.stringify(data),
            ttl
          );
        }
      }
    };
  }
});
```

### Repository Procedure
```typescript
import { igniter } from '@/igniter';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const repositoryProcedure = igniter.procedure({
  name: 'Repository',
  description: 'Provides database access through repository pattern',
  handler: async (_, { context }) => {
    return {
      repository: {
        users: {
          findMany: async (args?: any) => {
            return prisma.user.findMany(args);
          },
          findUnique: async (args: any) => {
            return prisma.user.findUnique(args);
          },
          create: async (args: any) => {
            return prisma.user.create(args);
          },
          update: async (args: any) => {
            return prisma.user.update(args);
          },
          delete: async (args: any) => {
            return prisma.user.delete(args);
          },
          count: async (args?: any) => {
            return prisma.user.count(args);
          }
        }
      }
    };
  }
});
```

### Validation Procedure
```typescript
import { igniter } from '@/igniter';
import { z } from 'zod';

interface ValidateOptions {
  schema?: z.ZodSchema;
  customRules?: Array<(data: any) => boolean | string>;
}

export const validateProcedure = igniter.procedure({
  name: 'Validation',
  description: 'Advanced validation beyond Zod schemas',
  handler: async (options: ValidateOptions = {}, { request, context }) => {
    const { schema, customRules = [] } = options;

    // Additional schema validation if provided
    if (schema && request.body) {
      const result = schema.safeParse(request.body);
      if (!result.success) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Validation failed',
          cause: result.error.errors
        });
      }
    }

    // Custom validation rules
    for (const rule of customRules) {
      const result = rule(request.body);
      if (typeof result === 'string') {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: result
        });
      }
      if (!result) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Custom validation failed'
        });
      }
    }

    return {
      validated: true
    };
  }
});
```

### Rate Limiting Procedure
```typescript
import { igniter } from '@/igniter';
import { RateLimiter } from '@/lib/rate-limiter';

interface RateLimitOptions {
  windowMs?: number;
  maxRequests?: number;
  keyGenerator?: (request: any) => string;
}

export const rateLimitProcedure = igniter.procedure({
  name: 'RateLimit',
  description: 'Limits request rate per client',
  handler: async (options: RateLimitOptions = {}, { request, context }) => {
    const {
      windowMs = 60000, // 1 minute
      maxRequests = 100,
      keyGenerator = (req) => req.headers.get('x-forwarded-for') || 'anonymous'
    } = options;

    const key = keyGenerator(request);
    const limiter = new RateLimiter({
      windowMs,
      max: maxRequests,
      store: context.store
    });

    const allowed = await limiter.check(key);

    if (!allowed) {
      throw new TRPCError({
        code: 'TOO_MANY_REQUESTS',
        message: 'Rate limit exceeded'
      });
    }

    return {
      rateLimit: {
        remaining: allowed.remaining,
        reset: allowed.reset
      }
    };
  }
});
```

## Usage in Controllers

### Single Procedure
```typescript
import { authProcedure } from '../procedures/auth.procedure';

export const usersController = igniter.controller({
  actions: {
    profile: igniter.query({
      use: [authProcedure()],
      handler: async ({ context }) => {
        // context.user is now available
        return context.user;
      }
    })
  }
});
```

### Multiple Procedures
```typescript
import { authProcedure } from '../procedures/auth.procedure';
import { cacheProcedure } from '../procedures/cache.procedure';
import { rateLimitProcedure } from '../procedures/rate-limit.procedure';

export const postsController = igniter.controller({
  actions: {
    list: igniter.query({
      use: [
        rateLimitProcedure({ maxRequests: 50 }),
        authProcedure({ required: false }),
        cacheProcedure({ ttl: 300 })
      ],
      handler: async ({ context, response }) => {
        // Check if cached
        if (context.cached) {
          return response.success(context.cachedData);
        }

        // Fetch data
        const posts = await fetchPosts();

        // Cache the result
        await context.setCacheData(posts);

        return response.success(posts);
      }
    })
  }
});
```

### Procedure with Options
```typescript
export const adminController = igniter.controller({
  actions: {
    dashboard: igniter.query({
      use: [
        authProcedure({
          required: true,
          roles: ['admin', 'moderator']
        })
      ],
      handler: async ({ context }) => {
        // Only admins and moderators can access
        return getDashboardData();
      }
    })
  }
});
```

## Examples

### Generate auth procedure
```bash
igniter generate procedure auth --type auth
```

### Generate cache procedure for feature
```bash
igniter generate procedure cache --type cache --feature products
```

### Generate custom procedure
```bash
igniter generate procedure logger --type custom
```

### Generate repository procedure
```bash
igniter generate procedure repository --type repository --feature users
```

## Context Extension

Procedures extend the context by returning data:

```typescript
// Before procedure
context = {
  database: PrismaClient,
  logger: Logger,
  store: RedisStore
}

// After auth procedure
context = {
  database: PrismaClient,
  logger: Logger,
  store: RedisStore,
  user: { id: '123', email: 'user@example.com' } // Added by procedure
}
```

## Best Practices

1. **Keep procedures focused** - Single responsibility
2. **Make them reusable** - Accept options for flexibility
3. **Return context data** - Extend context for handlers
4. **Handle errors gracefully** - Use appropriate error codes
5. **Document options** - Clear interface definitions
6. **Test thoroughly** - Unit test procedures independently

## Testing Procedures

```typescript
// __tests__/auth.procedure.test.ts
import { authProcedure } from '../auth.procedure';

describe('AuthProcedure', () => {
  it('should authenticate valid token', async () => {
    const mockRequest = {
      headers: new Headers({
        'Authorization': 'Bearer valid-token'
      })
    };

    const result = await authProcedure.handler(
      { required: true },
      { request: mockRequest, context: {} }
    );

    expect(result.user).toBeDefined();
    expect(result.user.id).toBe('123');
  });

  it('should throw on invalid token', async () => {
    const mockRequest = {
      headers: new Headers({
        'Authorization': 'Bearer invalid-token'
      })
    };

    await expect(
      authProcedure.handler(
        { required: true },
        { request: mockRequest, context: {} }
      )
    ).rejects.toThrow('Invalid token');
  });
});
```

## Configuration

In `.igniterrc`:
```json
{
  "generate": {
    "procedure": {
      "defaultType": "custom",
      "path": "src/shared/procedures",
      "template": "custom"
    }
  }
}
```

## Troubleshooting

### Procedure not extending context
Ensure returning data from handler:
```typescript
// ✅ Correct
handler: async () => {
  return { user: userData };
}

// ❌ Wrong
handler: async () => {
  const user = userData;
  // Missing return
}
```

### Type errors in context
Update context type definition:
```typescript
// src/igniter.context.ts
export interface IgniterAppContext {
  database: PrismaClient;
  logger: Logger;
  store?: RedisStore;
  user?: User; // Add extended types
}
```

## Related Commands
- [`igniter generate feature`](./05-generate-feature.md) - Generate complete feature with procedures
- [`igniter generate controller`](./06-generate-controller.md) - Use procedures in controllers
- [`igniter dev`](./02-dev-command.md) - Test procedures in development