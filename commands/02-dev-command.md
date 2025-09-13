# Command: `igniter dev`

## Overview
Starts development mode with interactive dashboard, hot reload, and automatic schema generation.

## Syntax
```bash
igniter dev [options]
```

## Features
- **Interactive Dashboard**: Real-time process monitoring
- **Auto Port Management**: Kills existing processes on port
- **Hot Reload**: Automatic regeneration on file changes
- **OpenAPI Docs**: Auto-generated API playground
- **Framework Integration**: Runs framework dev server alongside Igniter

## Options

### `--framework <type>`
- **Type**: String
- **Values**: `nextjs`, `vite`, `nuxt`, `sveltekit`, `remix`, `astro`, `express`, `tanstack-start`, `generic`
- **Default**: Auto-detected
- **Description**: Specify framework type
- **Auto-detection**: Checks package.json and project structure

### `--output <dir>`
- **Type**: String
- **Default**: `"src/"`
- **Description**: Output directory for generated client files
- **Files Generated**:
  - `igniter.client.ts` - Type-safe client
  - `igniter.schema.ts` - TypeScript types

### `--port <number>`
- **Type**: Number
- **Default**: `3000`
- **Description**: Port for the development server
- **Behavior**: Auto-kills existing process on port

### `--cmd <command>`
- **Type**: String
- **Default**: Framework-specific command
- **Description**: Custom command to start dev server
- **Example**: `--cmd "npm run custom-dev"`

### `--no-framework`
- **Type**: Boolean flag
- **Description**: Run only Igniter watcher without framework server
- **Use Case**: API-only development, microservices

### `--no-interactive`
- **Type**: Boolean flag
- **Description**: Use concurrent mode instead of interactive dashboard
- **Use Case**: CI environments, logging to files

### `--docs-output <dir>`
- **Type**: String
- **Default**: `"./src/docs"`
- **Description**: Output directory for OpenAPI documentation
- **Files Generated**:
  - `openapi.json` - OpenAPI specification
  - `index.html` - Interactive documentation UI

## Interactive Dashboard

When running in interactive mode (default):

```
┌─────────────────────────────────────────┐
│         Igniter.js Dev Server           │
├─────────────────────────────────────────┤
│ [Next.js]  ● Running on port 3000       │
│ [Igniter]  ● Watching for changes       │
│ [Docs]     ● Available at /api/docs     │
├─────────────────────────────────────────┤
│ Commands:                               │
│ r - Restart all                         │
│ c - Clear console                       │
│ q - Quit                                │
└─────────────────────────────────────────┘
```

## Process Management

The dev command manages multiple processes:

1. **Framework Process**
   - Runs framework-specific dev command
   - Monitors for crashes and auto-restarts
   - Passes PORT environment variable

2. **Igniter Process**
   - Watches for router changes
   - Regenerates client and schema
   - Updates OpenAPI documentation

## Framework Commands

Default commands per framework:

| Framework | Command | Port |
|-----------|---------|------|
| Next.js | `npm run dev` | 3000 |
| Vite | `npm run dev` | 5173 |
| Nuxt | `npm run dev` | 3000 |
| SvelteKit | `npm run dev` | 5173 |
| Remix | `npm run dev` | 3000 |
| Astro | `npm run dev` | 4321 |
| Express | `npm run dev` | 3000 |
| TanStack Start | `npm run dev` | 3000 |

## File Watching

Monitors these patterns:
- `**/*.controller.{ts,js}` - Controllers
- `**/*.procedure.{ts,js}` - Procedures
- `src/igniter.router.{ts,js}` - Main router
- `src/igniter.{ts,js}` - Configuration

## Examples

### Basic development
```bash
igniter dev
```

### Custom port
```bash
igniter dev --port 4000
```

### API-only mode
```bash
igniter dev --no-framework
```

### Custom framework command
```bash
igniter dev --cmd "yarn workspace app dev"
```

### Non-interactive mode for CI
```bash
igniter dev --no-interactive > dev.log 2>&1
```

### Custom output directories
```bash
igniter dev \
  --output lib/generated \
  --docs-output public/api-docs
```

## Generated Files

### Client (`igniter.client.ts`)
```typescript
// Auto-generated - DO NOT EDIT
export const api = {
  users: {
    list: {
      query: async () => {...},
      useQuery: () => {...}
    },
    create: {
      mutation: async () => {...},
      useMutation: () => {...}
    }
  }
}
```

### Schema (`igniter.schema.ts`)
```typescript
// Auto-generated types
export interface User {
  id: string;
  email: string;
  name: string;
}
```

### OpenAPI (`openapi.json`)
```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Igniter.js API",
    "version": "1.0.0"
  },
  "paths": {
    "/api/users": {
      "get": {...},
      "post": {...}
    }
  }
}
```

## Environment Variables

Passed to processes:

```env
PORT=3000                    # Development server port
NODE_ENV=development        # Environment mode
IGNITER_DEV=true           # Igniter dev mode flag
```

## Troubleshooting

### Port already in use
The CLI automatically kills processes on the port, but if issues persist:
```bash
lsof -ti:3000 | xargs kill -9
igniter dev
```

### Framework not detected
```bash
igniter dev --framework nextjs
```

### Schema not generating
Check for TypeScript errors:
```bash
npm run typecheck
```

### Interactive mode issues
Fall back to concurrent mode:
```bash
igniter dev --no-interactive
```

## Performance Tips

1. **Use specific output paths** to avoid unnecessary file watching
2. **Disable unused features** with `--no-framework` if API-only
3. **Close other watchers** (VSCode, etc.) to reduce system load
4. **Use production builds** periodically to test performance

## Debug Mode

Enable detailed logging:
```bash
igniter dev --debug
```

Shows:
- File change events
- Generation timings
- Process lifecycle
- Error stack traces

## API Playground

Access at `http://localhost:3000/api/docs`:
- Interactive API testing
- Real-time request/response
- Type validation
- Authentication testing

## Hot Reload Behavior

| Change Type | Action |
|------------|--------|
| Controller added | Regenerate client & schema |
| Controller modified | Regenerate client & schema |
| Router modified | Full regeneration |
| Config modified | Restart Igniter process |
| Framework files | Framework handles reload |

## Exit Codes

- `0`: Clean shutdown
- `1`: Configuration error
- `2`: Port binding failed
- `3`: Framework process crashed
- `4`: Generation error

## Related Commands
- [`igniter init`](./01-init-command.md) - Create new project
- [`igniter generate schema`](./03-generate-schema.md) - Manual schema generation
- [`igniter generate docs`](./04-generate-docs.md) - Generate documentation only