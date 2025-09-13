# Command: `igniter generate schema`

## Overview
Generates TypeScript client and type definitions from your Igniter router configuration.

## Syntax
```bash
igniter generate schema [options]
```

## Purpose
- Generate type-safe client for frontend
- Extract TypeScript types from router
- Enable end-to-end type safety
- Support CI/CD pipelines

## Options

### `--framework <type>`
- **Type**: String
- **Values**: `nextjs`, `vite`, `nuxt`, `sveltekit`, `remix`, `astro`, `express`, `tanstack-start`, `generic`
- **Default**: Auto-detected
- **Description**: Framework type affects import paths and client structure

### `--output <dir>`
- **Type**: String
- **Default**: `"src/"`
- **Description**: Output directory for generated files
- **Creates**:
  - `<output>/igniter.client.ts`
  - `<output>/igniter.schema.ts`

### `--watch`
- **Type**: Boolean flag
- **Description**: Watch for changes and regenerate automatically
- **Use Case**: Development mode alternative

### `--docs`
- **Type**: Boolean flag
- **Description**: Also generate OpenAPI documentation
- **Additional Output**: `openapi.json`

### `--docs-output <dir>`
- **Type**: String
- **Default**: `"./src/docs"`
- **Description**: Directory for OpenAPI docs (when --docs enabled)

## Generated Files

### `igniter.client.ts`
Type-safe client with framework-specific hooks:

```typescript
// AUTO-GENERATED FILE - DO NOT EDIT
import { IgniterClient } from '@igniter-js/core/client';
import type { AppRouter } from './igniter.router';

// Server-side client (RSC)
export const api = new IgniterClient<AppRouter>({
  baseURL: process.env.NEXT_PUBLIC_IGNITER_API_URL,
  basePath: process.env.NEXT_PUBLIC_IGNITER_API_BASE_PATH
});

// Client-side hooks
api.users.list.useQuery = () => {
  // React Query integration
};

api.users.create.useMutation = () => {
  // Mutation hook
};

// Type exports
export type { AppRouter };
export { useIgniterContext } from './providers/igniter.provider';
```

### `igniter.schema.ts`
Extracted TypeScript types:

```typescript
// AUTO-GENERATED FILE - DO NOT EDIT
export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Post {
  id: string;
  title: string;
  content: string;
  authorId: string;
  author?: User;
}

// Request/Response types
export namespace API {
  export namespace Users {
    export interface ListQuery {
      page?: number;
      limit?: number;
    }

    export interface ListResponse {
      users: User[];
      total: number;
    }

    export interface CreateBody {
      email: string;
      name: string;
      password: string;
    }
  }
}
```

## How It Works

1. **Router Discovery**
   - Searches for router file in common locations
   - Parses TypeScript AST
   - Extracts controller definitions

2. **Type Extraction**
   - Analyzes Zod schemas
   - Infers TypeScript types
   - Resolves generic parameters

3. **Client Generation**
   - Creates method for each action
   - Adds framework-specific hooks
   - Maintains type safety

4. **Validation**
   - Type-checks generated code
   - Ensures imports resolve
   - Validates against router

## File Discovery Order

Searches for router in:
1. `src/igniter.router.ts`
2. `src/igniter.router.js`
3. `src/router.ts`
4. `src/router.js`
5. `igniter.router.ts`
6. `igniter.router.js`
7. `router.ts`
8. `router.js`

## Examples

### Basic generation
```bash
igniter generate schema
```

### Watch mode for development
```bash
igniter generate schema --watch
```

### Custom output directory
```bash
igniter generate schema --output lib/generated
```

### With OpenAPI documentation
```bash
igniter generate schema --docs --docs-output public/api
```

### CI/CD pipeline
```bash
# In package.json scripts
"prebuild": "igniter generate schema",
"build": "next build"
```

## Integration Examples

### Next.js App Router
```tsx
// Server Component
import { api } from '@/igniter.client';

export default async function Page() {
  const { users } = await api.users.list.query();
  return <UserList users={users} />;
}
```

### Client Component
```tsx
'use client';
import { api } from '@/igniter.client';

export function UserList() {
  const { data, isLoading } = api.users.list.useQuery();

  if (isLoading) return <Spinner />;
  return <List items={data?.users} />;
}
```

## Error Messages

### Router not found
```
Error: Could not find router file. Searched in:
  - src/igniter.router.ts
  - src/router.ts
  ...
```
**Solution**: Ensure router file exists in expected location

### Type extraction failed
```
Error: Failed to extract types from controller
```
**Solution**: Check for TypeScript errors in controllers

### Invalid Zod schema
```
Error: Cannot parse Zod schema in action
```
**Solution**: Use supported Zod types in schemas

## Performance

Generation timings:
- Small project (~10 controllers): <1s
- Medium project (~50 controllers): 2-3s
- Large project (~100+ controllers): 5-10s

## Watch Mode Behavior

When `--watch` is enabled:

| File Change | Action |
|------------|--------|
| `*.controller.ts` | Regenerate client |
| `igniter.router.ts` | Full regeneration |
| `*.procedure.ts` | Check dependencies |
| `igniter.ts` | Regenerate if types change |

## CI/CD Integration

### GitHub Actions
```yaml
- name: Generate Igniter Client
  run: npx igniter generate schema

- name: Type Check
  run: npm run typecheck
```

### Pre-commit Hook
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "igniter generate schema && git add src/igniter.client.ts src/igniter.schema.ts"
    }
  }
}
```

## Best Practices

1. **Never edit generated files** - Changes will be lost
2. **Include in .gitignore** for dynamic generation
3. **Or commit** for reproducible builds
4. **Run before build** in CI/CD
5. **Use watch mode** during development

## Troubleshooting

### Stale types
```bash
# Force regeneration
rm src/igniter.client.ts src/igniter.schema.ts
igniter generate schema
```

### Import errors
Ensure `tsconfig.json` paths are configured:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

### Memory issues on large projects
```bash
NODE_OPTIONS="--max-old-space-size=4096" igniter generate schema
```

## Configuration

### Igniter Config (`src/igniter.ts`)
```typescript
export const igniter = Igniter
  .config({
    baseURL: 'http://localhost:3000',
    basePath: '/api',
    // Affects client generation
  })
  .create();
```

### Custom Templates
Place in `.igniter/templates/`:
- `client.hbs` - Client template
- `schema.hbs` - Schema template

## Related Commands
- [`igniter dev`](./02-dev-command.md) - Includes automatic schema generation
- [`igniter generate docs`](./04-generate-docs.md) - Generate OpenAPI documentation
- [`igniter generate feature`](./05-generate-feature.md) - Create new features that affect schema