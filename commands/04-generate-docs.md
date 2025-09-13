# Command: `igniter generate docs`

## Overview
Generates OpenAPI specification and interactive API documentation from your Igniter router.

## Syntax
```bash
igniter generate docs [options]
```

## Purpose
- Generate OpenAPI 3.0 specification
- Create interactive API playground
- Document all endpoints automatically
- Support API client generation

## Options

### `--output <dir>`
- **Type**: String
- **Default**: `"./src"`
- **Description**: Output directory for OpenAPI specification
- **Creates**: `<output>/openapi.json`

### `--ui`
- **Type**: Boolean flag
- **Description**: Generate self-contained HTML with Scalar UI
- **Creates**: `<output>/docs.html`
- **Features**:
  - Interactive API testing
  - Beautiful documentation
  - No external dependencies

## Generated Files

### `openapi.json`
Complete OpenAPI 3.0 specification:

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Igniter.js API",
    "version": "1.0.0",
    "description": "Auto-generated from Igniter router"
  },
  "servers": [
    {
      "url": "http://localhost:3000/api",
      "description": "Development server"
    }
  ],
  "paths": {
    "/users": {
      "get": {
        "operationId": "users.list",
        "summary": "List users",
        "parameters": [
          {
            "name": "page",
            "in": "query",
            "schema": {
              "type": "integer",
              "default": 1
            }
          },
          {
            "name": "limit",
            "in": "query",
            "schema": {
              "type": "integer",
              "default": 10
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UserListResponse"
                }
              }
            }
          }
        }
      },
      "post": {
        "operationId": "users.create",
        "summary": "Create user",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/CreateUserInput"
              }
            }
          }
        },
        "responses": {
          "201": {
            "description": "Created",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/User"
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "User": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string",
            "format": "uuid"
          },
          "email": {
            "type": "string",
            "format": "email"
          },
          "name": {
            "type": "string"
          }
        },
        "required": ["id", "email", "name"]
      }
    }
  }
}
```

### `docs.html` (with --ui)
Self-contained interactive documentation:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Igniter.js API Documentation</title>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
  <script id="api-reference" type="application/json">
    <!-- Embedded OpenAPI spec -->
  </script>
  <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
</body>
</html>
```

## How It Works

1. **Router Introspection**
   - Loads and analyzes router
   - Extracts all controllers
   - Parses action definitions

2. **Schema Extraction**
   - Converts Zod schemas to JSON Schema
   - Resolves type references
   - Handles nested objects

3. **Path Generation**
   - Builds path from controller + action paths
   - Maps HTTP methods
   - Includes parameters

4. **Documentation Enhancement**
   - Extracts JSDoc comments
   - Adds descriptions
   - Includes examples

## Supported Features

### Zod to OpenAPI Mapping

| Zod Type | OpenAPI Type | Format |
|----------|--------------|--------|
| `z.string()` | string | - |
| `z.string().email()` | string | email |
| `z.string().url()` | string | uri |
| `z.string().uuid()` | string | uuid |
| `z.number()` | number | - |
| `z.number().int()` | integer | int32 |
| `z.boolean()` | boolean | - |
| `z.date()` | string | date-time |
| `z.array()` | array | - |
| `z.object()` | object | - |
| `z.enum()` | string | enum |
| `z.union()` | oneOf | - |
| `z.optional()` | nullable | - |

### HTTP Method Mapping

| Igniter Method | HTTP Method | Purpose |
|----------------|-------------|---------|
| `query()` | GET | Read data |
| `mutation()` with method | POST/PUT/DELETE/PATCH | Modify data |
| `stream()` | GET with SSE | Real-time data |

## Examples

### Basic documentation generation
```bash
igniter generate docs
```

### With interactive UI
```bash
igniter generate docs --ui
```

### Custom output directory
```bash
igniter generate docs --output public/api --ui
```

### CI/CD pipeline
```bash
# Generate docs as part of build
igniter generate docs --output dist/api --ui
```

## Integration with API Clients

### Postman Import
1. Generate OpenAPI spec: `igniter generate docs`
2. In Postman: Import → File → Select `openapi.json`
3. Collection created with all endpoints

### Insomnia Import
1. Generate spec: `igniter generate docs`
2. In Insomnia: Import/Export → Import Data → From File
3. Select `openapi.json`

### Generate TypeScript Client
```bash
# Using openapi-typescript
npx openapi-typescript src/openapi.json --output src/api-types.ts
```

### Generate Python Client
```bash
# Using openapi-python-client
openapi-python-client generate --path src/openapi.json
```

## Customization

### Adding Metadata
In `igniter.ts`:
```typescript
export const igniter = Igniter
  .docs({
    openapi: {
      info: {
        title: 'My API',
        version: '2.0.0',
        description: 'Production API',
        contact: {
          email: 'api@example.com'
        }
      },
      servers: [
        {
          url: 'https://api.example.com',
          description: 'Production'
        }
      ]
    }
  })
  .create();
```

### Adding Descriptions
In controllers:
```typescript
export const usersController = igniter.controller({
  name: 'users',
  description: 'User management endpoints',
  actions: {
    list: igniter.query({
      name: 'List Users',
      description: 'Retrieve paginated list of users',
      query: z.object({
        page: z.number().describe('Page number'),
        limit: z.number().describe('Items per page')
      }),
      handler: async () => {
        // ...
      }
    })
  }
});
```

## Serving Documentation

### Development Server
In `igniter dev`, docs available at:
```
http://localhost:3000/api/docs
```

### Production Hosting

#### Next.js
```typescript
// app/api/docs/route.ts
import { readFileSync } from 'fs';
import { join } from 'path';

export async function GET() {
  const html = readFileSync(
    join(process.cwd(), 'src/docs.html'),
    'utf-8'
  );
  return new Response(html, {
    headers: { 'Content-Type': 'text/html' }
  });
}
```

#### Express
```typescript
app.get('/api/docs', (req, res) => {
  res.sendFile(path.join(__dirname, 'docs.html'));
});
```

## Security Considerations

### Authentication Documentation
```typescript
export const authProcedure = igniter.procedure({
  name: 'Authentication',
  description: 'Requires Bearer token',
  handler: async () => {
    // ...
  }
});
```

Generates:
```json
{
  "security": [
    {
      "bearerAuth": []
    }
  ],
  "components": {
    "securitySchemes": {
      "bearerAuth": {
        "type": "http",
        "scheme": "bearer"
      }
    }
  }
}
```

### Hiding Internal Endpoints
```typescript
export const internalController = igniter.controller({
  name: 'internal',
  hidden: true, // Excludes from OpenAPI
  actions: {
    // ...
  }
});
```

## Troubleshooting

### Missing endpoints
Ensure controllers are registered in router:
```typescript
// src/igniter.router.ts
export const AppRouter = igniter.router({
  controllers: {
    users: usersController,
    posts: postsController
    // All controllers must be here
  }
});
```

### Invalid schema generation
Check for unsupported Zod types:
```typescript
// Supported
z.object({ name: z.string() })

// Not supported (use preprocessor)
z.custom()
```

### Large specification files
Split into multiple files:
```bash
igniter generate docs --output src/docs/users --filter users
igniter generate docs --output src/docs/posts --filter posts
```

## Best Practices

1. **Add descriptions** to all schemas and actions
2. **Use consistent naming** for operations
3. **Include examples** in complex schemas
4. **Version your API** properly
5. **Regenerate on deploy** for accuracy

## Performance

Generation time by project size:
- Small (~10 endpoints): <500ms
- Medium (~50 endpoints): 1-2s
- Large (~200 endpoints): 3-5s
- Enterprise (~1000 endpoints): 10-15s

## Related Commands
- [`igniter dev`](./02-dev-command.md) - Includes automatic docs generation
- [`igniter generate schema`](./03-generate-schema.md) - Generate TypeScript client
- [`igniter generate feature`](./05-generate-feature.md) - Add new endpoints to docs