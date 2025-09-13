# Igniter.js Framework Rules & Guidelines

## 🎯 Core Philosophy
**Type-Safety Above All** • **AI-Friendly Design** • **Developer Experience First**

## 🔴 CRITICAL Rules (Never Compromise)

### Type Safety Enforcement
- **NEVER** break end-to-end type inference chain
- **NEVER** use `any` type without explicit justification
- **NEVER** bypass Zod validation schemas
- **ALWAYS** regenerate client after router changes
- **ALWAYS** verify type consistency across boundaries

### Generated Files Protection
- **NEVER** manually edit `igniter.client.ts`
- **NEVER** manually edit `igniter.schema.ts`
- **NEVER** modify auto-generated type definitions
- **ALWAYS** change backend to update client types
- **ALWAYS** use CLI for regeneration

### Architecture Integrity
- **NEVER** import services directly in controllers
- **NEVER** bypass context for dependency access
- **NEVER** mix feature boundaries
- **ALWAYS** use Feature-Sliced Architecture
- **ALWAYS** encapsulate logic in feature directories

## 🟡 IMPORTANT Rules (Strong Preference)

### Development Workflow
- **ALWAYS** use CLI for scaffolding: `igniter generate feature`
- **ALWAYS** register controllers in `igniter.router.ts`
- **ALWAYS** create AGENT.md for new packages
- **ALWAYS** maintain DOCS.md for features
- **PREFER** RSC for initial data fetching
- **PREFER** procedures for reusable middleware

### API Design Patterns
```typescript
// ✅ CORRECT: Use context for dependencies
handler: async ({ context }) => {
  return context.database.user.findMany();
}

// ❌ WRONG: Direct import
import { db } from '@/lib/database';
handler: async () => {
  return db.user.findMany();
}
```

### Validation Strategy
```typescript
// Layer 1: Schema validation (shape/type)
body: z.object({
  email: z.string().email(),
  age: z.number().min(18)
})

// Layer 2: Business validation (runtime)
handler: ({ context }) => {
  context.plugins.ensure.toBeDefined(user, "User not found");
  context.plugins.ensure.toBeTrue(user.isActive, "Account suspended");
}
```

## 🟢 RECOMMENDED Rules (Best Practices)

### Naming Conventions
- **Controllers**: `[feature]Controller` (camelCase)
- **Actions**: Descriptive verbs (`list`, `create`, `update`, `delete`)
- **Procedures**: `[purpose]Procedure` (e.g., `authProcedure`)
- **Features**: Plural nouns (`users`, `posts`, `products`)
- **Schemas**: `[Model]Schema` with Zod

### File Organization
```
src/features/
├── users/
│   ├── controllers/
│   │   └── users.controller.ts
│   ├── procedures/
│   │   └── repository.procedure.ts
│   ├── schemas/
│   │   └── user.schema.ts
│   ├── index.ts
│   ├── AGENT.md
│   └── DOCS.md
```

### Response Patterns
```typescript
// Queries (GET)
handler: async ({ response }) => {
  const data = await fetchData();
  return response.success(data);
}

// Mutations (POST/PUT/DELETE)
handler: async ({ response }) => {
  const created = await createResource();
  return response.created(created).revalidate(['resource.list']);
}

// Errors
handler: async ({ response }) => {
  if (!authorized) {
    return response.forbidden("Access denied");
  }
}
```

## 🚀 Performance Rules

### Caching Strategy
- **USE** Redis adapter for frequently accessed data
- **SET** appropriate TTL for cache entries
- **INVALIDATE** on mutations with `.revalidate()`
- **IMPLEMENT** cache-aside pattern for reads

### Real-time Optimization
- **ENABLE** `stream: true` only when needed
- **SCOPE** revalidations to specific users
- **BATCH** real-time updates when possible
- **USE** selective query invalidation

### Background Jobs
- **OFFLOAD** heavy operations to BullMQ
- **IMPLEMENT** idempotent job handlers
- **MONITOR** job queue health
- **SET** appropriate retry strategies

## 🛡️ Security Rules

### Authentication & Authorization
- **ALWAYS** validate tokens in procedures
- **NEVER** trust client-provided user IDs
- **IMPLEMENT** rate limiting for public endpoints
- **USE** procedures for permission checks
- **VALIDATE** all user inputs with Zod

### Data Protection
- **NEVER** expose sensitive data in responses
- **SANITIZE** user inputs before storage
- **USE** parameterized queries (Prisma)
- **IMPLEMENT** field-level access control
- **LOG** security-relevant events

## 📝 Documentation Rules

### Required Documentation
- **README.md**: Package overview and setup
- **AGENT.md**: AI agent instructions per package
- **DOCS.md**: Feature technical documentation
- **JSDoc**: All public APIs and types
- **OpenAPI**: Auto-generate with `igniter generate docs`

### Documentation Standards
```typescript
/**
 * Creates a new user account
 * @param input - User registration data
 * @returns Created user object without password
 * @throws {ValidationError} Invalid input data
 * @throws {ConflictError} Email already exists
 */
```

## 🔄 Testing Rules

### Test Coverage Requirements
- **Unit tests**: Business logic and utilities
- **Integration tests**: API endpoints
- **E2E tests**: Critical user flows
- **Type tests**: Generic implementations
- **Performance tests**: Heavy operations

### Test Organization
```
src/features/users/
├── __tests__/
│   ├── users.controller.test.ts
│   ├── user.schema.test.ts
│   └── repository.test.ts
```

## 🎯 Client-Side Rules

### Hook Usage
```typescript
// ✅ CORRECT: Client Component
'use client';
const { data, isLoading } = api.users.list.useQuery();

// ✅ CORRECT: Server Component
const users = await api.users.list.query();

// ❌ WRONG: Mixing patterns
'use client';
const users = await api.users.list.query(); // Error!
```

### State Management
- **USE** built-in query cache
- **AVOID** redundant state duplication
- **LEVERAGE** optimistic updates
- **IMPLEMENT** proper error boundaries
- **USE** Suspense for loading states

## 🚨 Anti-Patterns to Avoid

### Common Mistakes
```typescript
// ❌ Breaking type chain
const result = await api.users.list.query() as any;

// ❌ Direct database access in controller
import { prisma } from '@/lib/prisma';

// ❌ Nested try-catch instead of ensure
try {
  if (!user) throw new Error();
} catch {
  // handle
}

// ❌ Manual type definitions for API
interface UserResponse {
  // Manually defining what's auto-generated
}

// ❌ Synchronous heavy operations
handler: () => {
  const result = expensiveComputation(); // Block event loop
}
```

## 📊 Monitoring & Observability

### Required Telemetry
- **TRACE** API request flows
- **MEASURE** endpoint latencies
- **TRACK** error rates and types
- **MONITOR** cache hit ratios
- **ALERT** on degraded performance

### Logging Standards
```typescript
context.logger.info('User created', { userId, email });
context.logger.error('Payment failed', { error, userId, amount });
context.logger.debug('Cache miss', { key, feature: 'users' });
```

## 🔧 Development Tools

### Essential Commands
```bash
# Development
igniter dev --docs        # With API playground
igniter dev --verbose     # With detailed logging

# Generation
igniter generate feature <name> --schema prisma:Model
igniter generate schema   # Update TypeScript types
igniter generate docs --ui # Generate OpenAPI + UI

# Testing
npm test -- --filter @igniter-js/core
npm run test:watch

# Quality
npm run lint:fix
npm run typecheck
```

## 📈 Scalability Rules

### Horizontal Scaling
- **DESIGN** stateless handlers
- **USE** Redis for shared state
- **IMPLEMENT** distributed locks
- **HANDLE** concurrent job processing
- **PREPARE** for multi-instance deployment

### Database Optimization
- **USE** connection pooling
- **IMPLEMENT** query pagination
- **OPTIMIZE** N+1 queries with includes
- **INDEX** frequently queried fields
- **BATCH** bulk operations

## 🎨 Code Style

### TypeScript Standards
```typescript
// Prefer const assertions
const ROLES = ['user', 'admin'] as const;

// Use discriminated unions
type Result =
  | { success: true; data: User }
  | { success: false; error: string };

// Leverage type inference
const createUser = (input: z.infer<typeof UserSchema>) => {
  // Implementation
};
```

### Async Patterns
```typescript
// ✅ Parallel when independent
const [users, posts] = await Promise.all([
  getUsers(),
  getPosts()
]);

// ✅ Sequential when dependent
const user = await getUser(id);
const posts = await getPostsByUser(user.id);
```

## 🚦 Migration Rules

### Version Compatibility
- **MAINTAIN** backward compatibility in minor versions
- **DOCUMENT** breaking changes in major versions
- **PROVIDE** migration guides
- **DEPRECATE** before removing
- **VERSION** API endpoints when needed

### Database Migrations
- **USE** Prisma migrations for schema changes
- **TEST** migrations on staging first
- **BACKUP** before production migrations
- **IMPLEMENT** rollback strategies
- **DOCUMENT** migration impacts

## 📋 Checklist for New Features

- [ ] Created with CLI: `igniter generate feature`
- [ ] Registered in `igniter.router.ts`
- [ ] Zod schemas defined and validated
- [ ] Procedures implemented for auth/permissions
- [ ] Context used for all dependencies
- [ ] Response patterns follow standards
- [ ] Real-time considerations addressed
- [ ] Tests written (unit/integration)
- [ ] DOCS.md created and comprehensive
- [ ] OpenAPI schema regenerated
- [ ] Type-safety verified end-to-end
- [ ] Performance optimizations applied
- [ ] Security validations in place
- [ ] Error handling comprehensive
- [ ] Logging implemented appropriately

---

**Remember**: These rules exist to maintain code quality, ensure type safety, and provide an exceptional developer experience. When in doubt, prioritize type safety and follow existing patterns in the codebase.