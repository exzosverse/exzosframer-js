# Command: `igniter generate feature`

## Overview
Scaffolds a complete feature slice following Feature-Sliced Architecture with controllers, schemas, procedures, and tests.

## Syntax
```bash
igniter generate feature <name> [options]
```

## Arguments
- `name` (required): Feature name (singular or plural)
  - Converted to kebab-case for directories
  - Converted to camelCase for variables
  - Converted to PascalCase for types

## Options

### `--schema <source>`
- **Type**: String
- **Values**:
  - `prisma:ModelName` - From Prisma schema
  - `zod` - Interactive Zod builder
  - `json` - From JSON file
  - `typescript` - From TypeScript interface
- **Default**: Interactive prompt
- **Description**: Source for generating schemas

### `--crud`
- **Type**: Boolean flag
- **Description**: Generate full CRUD operations
- **Creates**: list, get, create, update, delete actions

### `--realtime`
- **Type**: Boolean flag
- **Description**: Add Server-Sent Events support
- **Adds**: Stream actions and real-time revalidation

### `--tests`
- **Type**: Boolean flag
- **Description**: Generate test files
- **Creates**: Unit and integration tests

### `--path <path>`
- **Type**: String
- **Default**: `"src/features"`
- **Description**: Base path for feature generation

## Generated Structure

```
src/features/<name>/
├── controllers/
│   └── <name>.controller.ts       # API endpoints
├── procedures/
│   └── repository.procedure.ts    # Database access layer
├── schemas/
│   └── <name>.schema.ts          # Zod validation schemas
├── services/
│   └── <name>.service.ts         # Business logic (if complex)
├── __tests__/
│   ├── <name>.controller.test.ts # Controller tests
│   ├── <name>.service.test.ts    # Service tests
│   └── <name>.integration.test.ts # Integration tests
├── index.ts                       # Public exports
├── AGENT.md                       # AI instructions
└── DOCS.md                        # Technical documentation
```

## Schema Sources

### From Prisma Model
```bash
igniter generate feature users --schema prisma:User
```

Reads from `prisma/schema.prisma`:
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

### Interactive Zod Builder
```bash
igniter generate feature products --schema zod
```

Prompts for:
1. Field name
2. Field type (string, number, boolean, date, etc.)
3. Validations (min, max, email, url, etc.)
4. Optional/required
5. Default values

### From JSON File
```bash
igniter generate feature orders --schema orders.json
```

Reads from `orders.json`:
```json
{
  "id": "string",
  "customerId": "string",
  "items": [
    {
      "productId": "string",
      "quantity": "number",
      "price": "number"
    }
  ],
  "total": "number",
  "status": "pending|processing|completed"
}
```

## Generated Files

### Controller (`<name>.controller.ts`)
```typescript
import { igniter } from '@/igniter';
import { z } from 'zod';
import {
  CreateUserSchema,
  UpdateUserSchema,
  UserSchema
} from '../schemas/user.schema';
import { repositoryProcedure } from '../procedures/repository.procedure';

export const usersController = igniter.controller({
  name: 'users',
  path: '/users',
  description: 'User management endpoints',
  actions: {
    list: igniter.query({
      name: 'List Users',
      path: '/',
      query: z.object({
        page: z.number().optional().default(1),
        limit: z.number().optional().default(10),
        search: z.string().optional()
      }),
      use: [repositoryProcedure()],
      handler: async ({ request, context, response }) => {
        const { page, limit, search } = request.query;
        const users = await context.repository.users.findMany({
          where: search ? {
            OR: [
              { name: { contains: search } },
              { email: { contains: search } }
            ]
          } : undefined,
          skip: (page - 1) * limit,
          take: limit
        });

        const total = await context.repository.users.count();

        return response.success({
          users,
          pagination: {
            page,
            limit,
            total,
            pages: Math.ceil(total / limit)
          }
        });
      }
    }),

    get: igniter.query({
      name: 'Get User',
      path: '/:id',
      use: [repositoryProcedure()],
      handler: async ({ request, context, response }) => {
        const user = await context.repository.users.findUnique({
          where: { id: request.params.id }
        });

        context.plugins.ensure.toBeDefined(
          user,
          'User not found'
        );

        return response.success({ user });
      }
    }),

    create: igniter.mutation({
      name: 'Create User',
      path: '/',
      method: 'POST',
      body: CreateUserSchema,
      use: [repositoryProcedure()],
      handler: async ({ request, context, response }) => {
        const user = await context.repository.users.create({
          data: request.body
        });

        return response.created({ user })
          .revalidate(['users.list']);
      }
    }),

    update: igniter.mutation({
      name: 'Update User',
      path: '/:id',
      method: 'PUT',
      body: UpdateUserSchema,
      use: [repositoryProcedure()],
      handler: async ({ request, context, response }) => {
        const user = await context.repository.users.update({
          where: { id: request.params.id },
          data: request.body
        });

        return response.success({ user })
          .revalidate(['users.list', 'users.get']);
      }
    }),

    delete: igniter.mutation({
      name: 'Delete User',
      path: '/:id',
      method: 'DELETE',
      use: [repositoryProcedure()],
      handler: async ({ request, context, response }) => {
        await context.repository.users.delete({
          where: { id: request.params.id }
        });

        return response.noContent()
          .revalidate(['users.list']);
      }
    })
  }
});
```

### Schema (`<name>.schema.ts`)
```typescript
import { z } from 'zod';

export const UserSchema = z.object({
  id: z.string().cuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['user', 'admin']).default('user'),
  createdAt: z.date(),
  updatedAt: z.date()
});

export const CreateUserSchema = UserSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true
});

export const UpdateUserSchema = CreateUserSchema.partial();

export type User = z.infer<typeof UserSchema>;
export type CreateUser = z.infer<typeof CreateUserSchema>;
export type UpdateUser = z.infer<typeof UpdateUserSchema>;
```

### Procedure (`repository.procedure.ts`)
```typescript
import { igniter } from '@/igniter';

export const repositoryProcedure = igniter.procedure({
  name: 'Repository',
  description: 'Provides database access',
  handler: async (_, { context }) => {
    return {
      repository: {
        users: context.database.user
      }
    };
  }
});
```

### AGENT.md
```markdown
# Feature: Users

## Overview
User management feature providing CRUD operations for user entities.

## Architecture
- **Controller**: Handles HTTP requests and responses
- **Schema**: Validates input/output data
- **Procedure**: Provides database access layer
- **Service**: Business logic (if needed)

## API Endpoints
- `GET /users` - List users with pagination
- `GET /users/:id` - Get single user
- `POST /users` - Create new user
- `PUT /users/:id` - Update user
- `DELETE /users/:id` - Delete user

## Development Guidelines
1. Maintain type safety throughout
2. Use procedures for dependency injection
3. Validate all inputs with Zod schemas
4. Handle errors appropriately
5. Add tests for new functionality
```

## Examples

### Basic feature generation
```bash
igniter generate feature products
```

### From Prisma with CRUD
```bash
igniter generate feature posts --schema prisma:Post --crud
```

### With real-time support
```bash
igniter generate feature notifications --realtime
```

### Full-featured generation
```bash
igniter generate feature orders \
  --schema prisma:Order \
  --crud \
  --realtime \
  --tests
```

### Custom path
```bash
igniter generate feature admin/users --path src/admin/features
```

## Interactive Mode

When run without `--schema`, enters interactive mode:

```
? What is the data source for the schema?
  ❯ Prisma model
    Zod (interactive builder)
    JSON file
    TypeScript interface
    Skip (manual creation)

? Select Prisma model:
  ❯ User
    Post
    Comment

? Generate CRUD operations? (Y/n)
? Add real-time support? (y/N)
? Generate tests? (Y/n)
```

## Registration

After generation, register in router:

```typescript
// src/igniter.router.ts
import { usersController } from '@/features/users';

export const AppRouter = igniter.router({
  controllers: {
    users: usersController, // Add this line
    // ... other controllers
  }
});
```

## Testing Generated Code

### Run tests
```bash
npm test -- --filter users
```

### Test structure
```typescript
// __tests__/users.controller.test.ts
describe('UsersController', () => {
  it('should list users', async () => {
    const response = await api.users.list.query();
    expect(response.users).toBeDefined();
  });

  it('should create user', async () => {
    const user = await api.users.create.mutation({
      body: {
        email: 'test@example.com',
        name: 'Test User'
      }
    });
    expect(user.id).toBeDefined();
  });
});
```

## Customization

### Templates
Override default templates in `.igniter/templates/`:
- `controller.hbs`
- `schema.hbs`
- `procedure.hbs`
- `test.hbs`

### Configuration
In `.igniterrc`:
```json
{
  "generate": {
    "feature": {
      "path": "src/features",
      "crud": true,
      "tests": true,
      "template": "custom"
    }
  }
}
```

## Best Practices

1. **Use Prisma models** when available for consistency
2. **Always generate tests** for maintainability
3. **Add real-time** only when needed (performance cost)
4. **Document in AGENT.md** for AI assistance
5. **Review generated code** before committing

## Troubleshooting

### Prisma model not found
```bash
# Ensure Prisma is initialized
npx prisma init

# Generate Prisma client
npx prisma generate
```

### Feature already exists
```bash
# Use different name or remove existing
rm -rf src/features/users
igniter generate feature users
```

### Schema validation errors
Check Zod schemas for:
- Circular dependencies
- Invalid type combinations
- Missing imports

## Related Commands
- [`igniter generate controller`](./06-generate-controller.md) - Generate controller only
- [`igniter generate procedure`](./07-generate-procedure.md) - Generate procedure only
- [`igniter generate schema`](./03-generate-schema.md) - Regenerate client after feature