# Command: `igniter init`

## Overview
Creates a new Igniter.js project with interactive setup wizard or predefined options.

## Syntax
```bash
igniter init [project-name] [options]
```

## Arguments
- `project-name` (optional): Name of the project directory
  - Use `.` to initialize in current directory
  - Must be valid npm package name (lowercase, no spaces)
  - If omitted, shows help message

## Options

### `--force`
- **Type**: Boolean
- **Default**: false
- **Description**: Skip all confirmation prompts and overwrite existing files
- **Use Case**: CI/CD environments, automated setups

### `--pm, --package-manager <manager>`
- **Type**: String
- **Values**: `npm`, `yarn`, `pnpm`, `bun`
- **Default**: Auto-detected or npm
- **Description**: Package manager for dependency installation

### `--template <template>`
- **Type**: String
- **Values**:
  - `starter-nextjs`: Next.js App Router starter
  - `starter-express-rest-api`: Express REST API starter
  - `sample-realtime-chat`: Real-time chat example
  - `sample-saas-boilerplate`: SaaS application template
- **Description**: Use specific project template

### `--framework <framework>`
- **Type**: String
- **Values**: `nextjs`, `vite`, `nuxt`, `sveltekit`, `remix`, `astro`, `express`, `tanstack-start`
- **Default**: Auto-detected
- **Description**: Target framework for the project

### `--features <features>`
- **Type**: String (comma-separated)
- **Values**: `store`, `jobs`, `mcp`, `logging`, `telemetry`
- **Default**: None
- **Description**: Enable specific Igniter.js features
- **Details**:
  - `store`: Redis adapter for caching/pubsub
  - `jobs`: BullMQ for background jobs
  - `mcp`: Model Context Protocol server
  - `logging`: Structured logging with Pino
  - `telemetry`: OpenTelemetry integration

### `--database <database>`
- **Type**: String
- **Values**: `none`, `postgresql`, `mysql`, `sqlite`
- **Default**: `none`
- **Description**: Database provider configuration

### `--orm <orm>`
- **Type**: String
- **Values**: `prisma`, `drizzle`
- **Default**: None (if database is selected, prompts for ORM)
- **Description**: ORM provider for database access

### `--no-git`
- **Type**: Boolean flag
- **Description**: Skip git repository initialization
- **Use Case**: When integrating into existing repository

### `--no-install`
- **Type**: Boolean flag
- **Description**: Skip automatic dependency installation
- **Use Case**: Custom installation process, CI environments

### `--no-docker`
- **Type**: Boolean flag
- **Description**: Skip Docker Compose setup
- **Use Case**: Non-containerized deployments

## Interactive Flow

When run without options, enters interactive mode:

1. **Project Name Validation**
   - Validates npm package naming rules
   - Checks for existing directories
   - Prompts for overwrite confirmation

2. **Framework Selection**
   - Auto-detects if in existing project
   - Shows supported frameworks list
   - Configures framework-specific settings

3. **Feature Selection**
   - Multi-select features to enable
   - Configures required dependencies
   - Sets up adapter configurations

4. **Database Setup** (if not `none`)
   - Selects database provider
   - Chooses ORM (Prisma/Drizzle)
   - Configures connection strings

5. **Package Manager**
   - Auto-detects from lockfiles
   - Falls back to user preference
   - Configures scripts accordingly

## File Structure Created

```
<project-name>/
├── src/
│   ├── features/           # Feature-sliced architecture
│   ├── igniter.ts          # Main configuration
│   ├── igniter.router.ts   # Router assembly
│   ├── igniter.context.ts  # Base context
│   └── igniter.client.ts   # Auto-generated client
├── prisma/
│   └── schema.prisma       # If database selected
├── docker-compose.yml      # If Docker enabled
├── .env.example           # Environment variables template
├── .gitignore
├── package.json
├── tsconfig.json
├── README.md
└── AGENT.md               # AI agent instructions

```

## Examples

### Basic initialization
```bash
igniter init my-app
```

### Full-featured Next.js app
```bash
igniter init my-saas \
  --framework nextjs \
  --features store,jobs,telemetry \
  --database postgresql \
  --orm prisma \
  --pm pnpm
```

### Initialize in current directory
```bash
igniter init . --force
```

### CI/CD friendly setup
```bash
igniter init api-service \
  --template starter-express-rest-api \
  --force \
  --no-install \
  --no-git
```

## Post-Installation

After successful initialization:

1. **Navigate to directory**: `cd <project-name>`
2. **Install dependencies** (if skipped): `npm install`
3. **Configure environment**: Copy `.env.example` to `.env`
4. **Run migrations** (if database): `npx prisma migrate dev`
5. **Start development**: `igniter dev`

## Error Handling

Common errors and solutions:

- **Invalid project name**: Use lowercase, no spaces, valid npm name
- **Directory not empty**: Use `--force` or choose different name
- **Port already in use**: The CLI will auto-kill processes on port
- **Missing dependencies**: Run `npm install` manually

## Environment Variables

Created `.env.example` includes:

```env
# Database (if selected)
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"

# Redis (if store feature enabled)
REDIS_URL="redis://localhost:6379"

# API Configuration
NEXT_PUBLIC_IGNITER_API_URL="http://localhost:3000"
NEXT_PUBLIC_IGNITER_API_BASE_PATH="/api"

# Telemetry (if enabled)
OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
```

## Docker Compose Setup

If Docker is enabled, creates:

```yaml
version: '3.8'
services:
  postgres:  # If PostgreSQL selected
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"

  redis:     # If store feature enabled
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

## Best Practices

1. **Always use templates** for standard projects
2. **Enable features incrementally** - start minimal
3. **Configure database early** if needed
4. **Use consistent package manager** across team
5. **Commit `.env.example`**, never `.env`

## Troubleshooting

### Permission denied
```bash
sudo npm install -g @igniter-js/cli
```

### Template not found
```bash
igniter init --template list  # Show available templates
```

### Framework not detected
```bash
igniter init . --framework nextjs  # Explicitly specify
```

## Related Commands
- [`igniter dev`](./02-dev-command.md) - Start development after init
- [`igniter generate feature`](./05-generate-feature.md) - Add features to project