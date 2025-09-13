# Command: `igniter generate controller`

## Overview
Generates a standalone controller file with customizable actions for API endpoints.

## Syntax
```bash
igniter generate controller <name> [options]
```

## Arguments
- `name` (required): Controller name
  - Converted to kebab-case for files
  - Converted to camelCase for exports
  - Automatically pluralized if needed

## Options

### `--path <path>`
- **Type**: String
- **Default**: Inferred from name
- **Description**: Base API path for controller
- **Example**: `--path "/api/v2/products"`

### `--actions <actions>`
- **Type**: String (comma-separated)
- **Values**: `list`, `get`, `create`, `update`, `delete`, custom names
- **Default**: Interactive prompt
- **Description**: Actions to generate

### `--realtime`
- **Type**: Boolean flag
- **Description**: Add Server-Sent Events support
- **Adds**: Stream actions with real-time capabilities

### `--feature <name>`
- **Type**: String
- **Default**: Controller name
- **Description**: Feature directory to place controller in

## Generated File

### Location
```
src/features/<feature>/controllers/<name>.controller.ts
```

### Basic Structure
```typescript
import { igniter } from '@/igniter';
import { z } from 'zod';

export const productsController = igniter.controller({
  name: 'products',
  path: '/products',
  description: 'Product management endpoints',
  actions: {
    // Generated actions based on options
  }
});
```

## Action Templates

### List Action (GET)
```typescript
list: igniter.query({
  name: 'List Products',
  path: '/',
  query: z.object({
    page: z.number().optional().default(1),
    limit: z.number().optional().default(10),
    search: z.string().optional(),
    sort: z.enum(['name', 'price', 'created']).optional()
  }),
  handler: async ({ request, context, response }) => {
    const { page, limit, search, sort } = request.query;

    // TODO: Implement listing logic
    const products = [];
    const total = 0;

    return response.success({
      products,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  }
})
```

### Get by ID Action (GET)
```typescript
get: igniter.query({
  name: 'Get Product',
  path: '/:id',
  handler: async ({ request, context, response }) => {
    const { id } = request.params;

    // TODO: Implement retrieval logic
    const product = null;

    context.plugins.ensure.toBeDefined(
      product,
      'Product not found'
    );

    return response.success({ product });
  }
})
```

### Create Action (POST)
```typescript
create: igniter.mutation({
  name: 'Create Product',
  path: '/',
  method: 'POST',
  body: z.object({
    name: z.string().min(1).max(100),
    price: z.number().positive(),
    description: z.string().optional()
  }),
  handler: async ({ request, context, response }) => {
    const data = request.body;

    // TODO: Implement creation logic
    const product = { id: 'new-id', ...data };

    return response.created({ product })
      .revalidate(['products.list']);
  }
})
```

### Update Action (PUT)
```typescript
update: igniter.mutation({
  name: 'Update Product',
  path: '/:id',
  method: 'PUT',
  body: z.object({
    name: z.string().min(1).max(100).optional(),
    price: z.number().positive().optional(),
    description: z.string().optional()
  }),
  handler: async ({ request, context, response }) => {
    const { id } = request.params;
    const updates = request.body;

    // TODO: Implement update logic
    const product = { id, ...updates };

    return response.success({ product })
      .revalidate(['products.list', 'products.get']);
  }
})
```

### Delete Action (DELETE)
```typescript
delete: igniter.mutation({
  name: 'Delete Product',
  path: '/:id',
  method: 'DELETE',
  handler: async ({ request, context, response }) => {
    const { id } = request.params;

    // TODO: Implement deletion logic

    return response.noContent()
      .revalidate(['products.list']);
  }
})
```

### Real-time Stream Action (with --realtime)
```typescript
stream: igniter.query({
  name: 'Stream Products',
  path: '/stream',
  stream: true,
  handler: async ({ request, response }) => {
    const stream = response.stream({
      headers: {
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive'
      }
    });

    // Send initial data
    stream.send({
      event: 'initial',
      data: { products: [] }
    });

    // Set up real-time updates
    const interval = setInterval(() => {
      stream.send({
        event: 'update',
        data: { timestamp: new Date() }
      });
    }, 5000);

    // Clean up on disconnect
    request.signal.addEventListener('abort', () => {
      clearInterval(interval);
      stream.close();
    });

    return stream;
  }
})
```

## Examples

### Basic controller generation
```bash
igniter generate controller products
```

### Controller with specific actions
```bash
igniter generate controller users --actions list,get,create
```

### Controller with real-time support
```bash
igniter generate controller notifications --realtime
```

### Controller in specific feature
```bash
igniter generate controller settings --feature admin
```

### Full CRUD controller
```bash
igniter generate controller orders \
  --actions list,get,create,update,delete \
  --path "/api/v2/orders"
```

## Interactive Mode

When run without `--actions`, enters interactive:

```
? Which actions would you like to generate?
  ◯ list (GET /)
  ◯ get (GET /:id)
  ◯ create (POST /)
  ◯ update (PUT /:id)
  ◯ delete (DELETE /:id)
  ◯ custom

? Add real-time streaming support? (y/N)
? Add authentication procedure? (Y/n)
```

## Registration

After generation, register in router:

```typescript
// src/igniter.router.ts
import { productsController } from '@/features/products';

export const AppRouter = igniter.router({
  controllers: {
    products: productsController, // Add this
    // ... other controllers
  }
});
```

Or in feature index:

```typescript
// src/features/products/index.ts
export { productsController } from './controllers/products.controller';
```

## Customization Options

### Adding Procedures
```typescript
import { authProcedure } from '../procedures/auth.procedure';
import { cacheProcedure } from '../procedures/cache.procedure';

export const productsController = igniter.controller({
  // ...
  actions: {
    list: igniter.query({
      use: [
        cacheProcedure({ ttl: 60 }), // Cache for 60 seconds
        authProcedure({ required: false }) // Optional auth
      ],
      // ...
    })
  }
});
```

### Custom Action Names
```typescript
export const productsController = igniter.controller({
  actions: {
    search: igniter.query({
      name: 'Search Products',
      path: '/search',
      // ...
    }),

    bulk: igniter.mutation({
      name: 'Bulk Operations',
      path: '/bulk',
      method: 'POST',
      // ...
    })
  }
});
```

## Best Practices

1. **Use procedures** for reusable logic
2. **Add validation** with comprehensive Zod schemas
3. **Include descriptions** for documentation
4. **Handle errors** appropriately
5. **Add revalidation** for cache updates
6. **Use proper HTTP methods** for actions
7. **Follow RESTful conventions** when applicable

## Templates

Override default templates in `.igniter/templates/controller/`:
- `query.hbs` - Query action template
- `mutation.hbs` - Mutation action template
- `stream.hbs` - Stream action template

## Troubleshooting

### Controller not found in client
Ensure registered in router:
```bash
# Check router file
cat src/igniter.router.ts | grep "Controller"
```

### Type errors
Verify imports and schemas:
```bash
npm run typecheck
```

### Path conflicts
Check for duplicate paths:
```bash
# List all controller paths
grep -r "path:" src/features/*/controllers/*.ts
```

## Configuration

In `.igniterrc`:
```json
{
  "generate": {
    "controller": {
      "defaultActions": ["list", "get", "create"],
      "useAuthentication": true,
      "template": "custom"
    }
  }
}
```

## Related Commands
- [`igniter generate feature`](./05-generate-feature.md) - Generate complete feature
- [`igniter generate procedure`](./07-generate-procedure.md) - Generate middleware
- [`igniter generate schema`](./03-generate-schema.md) - Regenerate client after controller