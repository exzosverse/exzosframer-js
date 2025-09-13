# Express Integration Rules - Igniter.js Framework

## 🚂 Express.js REST API Patterns

### Core Express Principles
- **Battle-tested stability** - Most popular Node.js web framework
- **Middleware ecosystem** - Extensive plugin and middleware support
- **Traditional architecture** - Request/Response with middleware chain
- **Production-ready** - Proven at scale in enterprise applications
- **Express adapter** - Clean integration via `@igniter-js/core/adapters`

## 🏗️ Express Server Architecture

### Standard Express Setup with Igniter.js
```typescript
/**
 * @description Express server with Igniter.js adapter
 * @file src/index.ts
 */
import express from 'express';
import { expressAdapter } from '@igniter-js/core/adapters';
import { AppRouter } from './igniter.router';

const app = express();

// ✅ CORRECT: Use expressAdapter for clean integration
const IGNITER_API_BASE_PATH = process.env.IGNITER_API_BASE_PATH || '/api/v1';
const PORT = process.env.PORT || 3000;

// Mount Igniter.js router with Express adapter
app.use(IGNITER_API_BASE_PATH, expressAdapter(AppRouter.handler));

// Additional Express middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});

// ❌ WRONG: Direct handler without adapter
app.use('/api', AppRouter.handler); // Won't work - incompatible interfaces
```

### Middleware Integration
```typescript
/**
 * @description Express middleware with Igniter.js
 */
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
    },
  },
}));

// CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));

// Compression
app.use(compression());

// Request logging
app.use(morgan('combined'));

// IMPORTANT: Body parsing BEFORE Igniter adapter
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Mount Igniter.js AFTER middleware setup
app.use(IGNITER_API_BASE_PATH, expressAdapter(AppRouter.handler));
```

## 📦 Development Environment

### Package Configuration
```json
// package.json
{
  "name": "starter-express-rest-api",
  "type": "module",  // ES modules support
  "scripts": {
    // Development with hot reload via tsx
    "dev": "tsx watch src/index.ts",

    // Production build and start
    "build": "tsc",
    "start": "NODE_ENV=production node dist/index.js",

    // Database operations
    "db:generate": "prisma generate",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev"
  },
  "dependencies": {
    "express": "^5.1.0",  // Express 5 for modern features
    "@igniter-js/core": "^0.2.6",
    "@igniter-js/adapter-redis": "latest",
    "@igniter-js/adapter-bullmq": "latest",
    "@prisma/client": "^6.11.1",
    "bullmq": "^4",
    "zod": "3.25.67"
  },
  "devDependencies": {
    "@types/express": "^5.0.3",
    "@types/node": "latest",
    "tsx": "^4.20.3",  // TypeScript execution
    "typescript": "^5.0.0"
  }
}
```

### TypeScript Configuration
```json
// tsconfig.json
{
  "compilerOptions": {
    // Module system
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",

    // Express compatibility
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,

    // Type checking
    "strict": true,
    "skipLibCheck": true,

    // Output
    "outDir": "./dist",
    "rootDir": "./src",

    // Path mapping
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules"]
}
```

## 🎯 Controller Patterns

### Feature-Based Controllers
```typescript
/**
 * @controller UserController
 * @description User management endpoints
 * @path /users
 */
export const userController = igniter.controller({
  name: 'Users',
  path: '/users',

  // Apply middleware at controller level
  use: [authProcedure(), rateLimitProcedure()],

  actions: {
    // GET /api/v1/users
    list: igniter.query({
      path: '/',
      query: z.object({
        page: z.number().default(1),
        limit: z.number().default(10),
      }),
      handler: async ({ request, context, response }) => {
        const { page, limit } = request.query;

        const users = await context.database.user.findMany({
          skip: (page - 1) * limit,
          take: limit,
          orderBy: { createdAt: 'desc' },
        });

        return response.success({
          data: users,
          pagination: { page, limit },
        });
      },
    }),

    // POST /api/v1/users
    create: igniter.mutation({
      path: '/',
      body: UserCreateSchema,
      handler: async ({ request, context, response }) => {
        // Business Logic: Validation
        const existingUser = await context.database.user.findUnique({
          where: { email: request.body.email },
        });

        if (existingUser) {
          return response.badRequest('Email already exists');
        }

        // Business Logic: Creation
        const user = await context.database.user.create({
          data: request.body,
        });

        // Business Logic: Background job
        await igniter.jobs.email.schedule({
          task: 'sendWelcomeEmail',
          input: { userId: user.id },
        });

        return response.created(user);
      },
    }),
  },
});
```

## 🔌 Service Layer Integration

### Database Service (Prisma)
```typescript
// src/services/database.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const database = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development'
    ? ['query', 'error', 'warn']
    : ['error'],
});

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = database;
}

// Graceful shutdown
process.on('beforeExit', async () => {
  await database.$disconnect();
});
```

### Cache Service (Redis)
```typescript
// src/services/cache.ts
import Redis from 'ioredis';
import { redisAdapter } from '@igniter-js/adapter-redis';

export const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => Math.min(times * 50, 2000),
});

export const store = redisAdapter({
  redis,
  namespace: 'app',
  ttl: 3600, // Default 1 hour
});
```

### Jobs Service (BullMQ)
```typescript
// src/services/jobs.ts
import { bullmqAdapter } from '@igniter-js/adapter-bullmq';
import { Queue, Worker } from 'bullmq';

const connection = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
};

// Define job queues
export const emailQueue = new Queue('email', { connection });
export const analyticsQueue = new Queue('analytics', { connection });

// Job workers
new Worker('email', async (job) => {
  const { userId } = job.data;
  // Process email job
  await sendEmail(userId);
}, { connection });

// Register with Igniter
export const jobs = bullmqAdapter({
  queues: {
    email: emailQueue,
    analytics: analyticsQueue,
  },
});
```

## 🚀 Production Optimizations

### Error Handling
```typescript
/**
 * @middleware Global error handler
 */
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  igniter.logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
  });

  if (res.headersSent) {
    return next(err);
  }

  res.status(500).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Internal Server Error'
      : err.message,
  });
});
```

### Graceful Shutdown
```typescript
const server = app.listen(PORT);

// Graceful shutdown handling
const gracefulShutdown = async (signal: string) => {
  console.log(`\n${signal} received, starting graceful shutdown...`);

  // Stop accepting new connections
  server.close(() => {
    console.log('HTTP server closed');
  });

  // Close database connections
  await database.$disconnect();

  // Close Redis connections
  await redis.quit();

  // Exit process
  process.exit(0);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
```

### Performance Monitoring
```typescript
/**
 * @middleware Request timing
 */
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;

    igniter.logger.info('Request completed', {
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
    });

    // Send metrics to monitoring service
    if (duration > 1000) {
      igniter.logger.warn('Slow request detected', {
        url: req.url,
        duration: `${duration}ms`,
      });
    }
  });

  next();
});
```

## 🧪 Testing Express APIs

### Integration Testing
```typescript
// tests/api.test.ts
import request from 'supertest';
import { app } from '../src/index';

describe('User API', () => {
  it('should create a new user', async () => {
    const response = await request(app)
      .post('/api/v1/users')
      .send({
        name: 'Test User',
        email: 'test@example.com',
      })
      .expect(201);

    expect(response.body).toHaveProperty('id');
    expect(response.body.email).toBe('test@example.com');
  });

  it('should handle validation errors', async () => {
    const response = await request(app)
      .post('/api/v1/users')
      .send({
        name: 'Test User',
        // Missing required email
      })
      .expect(400);

    expect(response.body).toHaveProperty('error');
  });
});
```

## 🐳 Docker Deployment

### Dockerfile
```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY src ./src

# Build TypeScript
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

## 📋 Express Integration Checklist

### Setup
- [ ] Install Express and type definitions
- [ ] Configure TypeScript for Node.js/Express
- [ ] Set up expressAdapter from Igniter.js
- [ ] Configure environment variables

### Middleware
- [ ] Add security middleware (helmet, cors)
- [ ] Configure body parsing
- [ ] Set up request logging
- [ ] Implement error handling

### Services
- [ ] Initialize database connection
- [ ] Set up Redis cache
- [ ] Configure background jobs
- [ ] Add monitoring/telemetry

### Production
- [ ] Implement graceful shutdown
- [ ] Add health check endpoints
- [ ] Configure compression
- [ ] Set up rate limiting

## 🔄 Migration from Pure Express

### Quick Migration Guide
```typescript
// Traditional Express
app.get('/users', async (req, res) => {
  const users = await db.users.findAll();
  res.json(users);
});

// With Igniter.js
export const userController = igniter.controller({
  path: '/users',
  actions: {
    list: igniter.query({
      path: '/',
      handler: async ({ response, context }) => {
        const users = await context.database.user.findMany();
        return response.success(users);
      },
    }),
  },
});

// Mount with adapter
app.use('/api/v1', expressAdapter(AppRouter.handler));
```

## 🚨 Express Anti-Patterns

### ❌ Mixing Express Routes with Igniter
```typescript
// WRONG: Don't mix routing patterns
app.get('/api/v1/custom', handler);  // Express route
app.use('/api/v1', expressAdapter(AppRouter.handler));  // Igniter routes

// CORRECT: All API routes through Igniter
app.use('/api/v1', expressAdapter(AppRouter.handler));
```

### ❌ Wrong Middleware Order
```typescript
// WRONG: Body parsing after Igniter adapter
app.use('/api/v1', expressAdapter(AppRouter.handler));
app.use(express.json());  // Too late!

// CORRECT: Body parsing before
app.use(express.json());
app.use('/api/v1', expressAdapter(AppRouter.handler));
```

### ❌ Missing Error Boundaries
```typescript
// WRONG: No error handling
app.use('/api/v1', expressAdapter(AppRouter.handler));

// CORRECT: Global error handler
app.use('/api/v1', expressAdapter(AppRouter.handler));
app.use(errorHandler);
```

---

**Remember**: Express provides a stable, battle-tested foundation for REST APIs. The expressAdapter enables seamless integration with Igniter.js while maintaining access to the entire Express ecosystem.