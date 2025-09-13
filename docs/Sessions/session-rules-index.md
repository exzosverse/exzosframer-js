# Igniter.js Rules System - Complete Index

**Generated**: September 13, 2025
**Total Rules Files**: 18 + Index
**Coverage**: Complete Framework Ecosystem

## Quick Navigation

### 📚 Foundation Rules
- [**00-index-rules.md**](../rules/00-index-rules.md) - Complete rule system overview
- [**01-core-concepts-rules.md**](../rules/01-core-concepts-rules.md) - Type-safe API layer, Feature-Sliced Architecture
- [**02-client-integration-rules.md**](../rules/02-client-integration-rules.md) - Client patterns and hydration
- [**03-advanced-features-rules.md**](../rules/03-advanced-features-rules.md) - Real-time, caching, observability
- [**04-performance-optimization-rules.md**](../rules/04-performance-optimization-rules.md) - Performance patterns

### 🤖 AI and Evolution
- [**05-autonomous-evolution-rules.md**](../rules/05-autonomous-evolution-rules.md) - Self-improvement protocols
- [**06-memory-management-rules.md**](../rules/06-memory-management-rules.md) - Persistent memory systems
- [**16-mcp-server-rules.md**](../rules/16-mcp-server-rules.md) - AI agent integration

### ⚡ Real-time and Runtimes
- [**07-realtime-patterns-rules.md**](../rules/07-realtime-patterns-rules.md) - SSE architecture
- [**08-bun-runtime-rules.md**](../rules/08-bun-runtime-rules.md) - Bun optimizations
- [**09-deno-runtime-rules.md**](../rules/09-deno-runtime-rules.md) - Deno security patterns
- [**10-express-integration-rules.md**](../rules/10-express-integration-rules.md) - Express.js integration
- [**11-tanstack-start-rules.md**](../rules/11-tanstack-start-rules.md) - TanStack Start patterns

### 🏗️ Architecture and Quality
- [**12-tooling-cli-rules.md**](../rules/12-tooling-cli-rules.md) - CLI development
- [**13-core-architecture-rules.md**](../rules/13-core-architecture-rules.md) - Core architecture patterns
- [**14-adapters-integration-rules.md**](../rules/14-adapters-integration-rules.md) - Framework adapters
- [**15-code-quality-rules.md**](../rules/15-code-quality-rules.md) - ESLint and quality standards

### 🔄 Version Control and Automation
- [**17-git-workflow-rules.md**](../rules/17-git-workflow-rules.md) - Git workflows and conventional commits
- [**18-github-automation-rules.md**](../rules/18-github-automation-rules.md) - GitHub automation and LIA

## Rules by Category

### Type Safety and Architecture
```
01-core-concepts-rules.md       # TypeScript patterns, Zod validation
13-core-architecture-rules.md   # Builder pattern, processor pipeline
14-adapters-integration-rules.md # Framework adapters
15-code-quality-rules.md        # ESLint configuration
```

### Client and Frontend Integration
```
02-client-integration-rules.md  # React, Vue, Angular patterns
08-bun-runtime-rules.md        # Bun + React integration
11-tanstack-start-rules.md     # TanStack Start patterns
```

### Real-time and Communication
```
07-realtime-patterns-rules.md  # SSE, WebSocket, chat patterns
03-advanced-features-rules.md  # Caching, observability
04-performance-optimization-rules.md # Performance patterns
```

### AI and Automation
```
05-autonomous-evolution-rules.md # Self-improvement systems
06-memory-management-rules.md   # Persistent memory
16-mcp-server-rules.md          # AI agent toolset
18-github-automation-rules.md   # LIA workflows
```

### Development Workflow
```
12-tooling-cli-rules.md         # CLI development
17-git-workflow-rules.md        # Version control
18-github-automation-rules.md   # GitHub automation
```

### Runtime Environments
```
08-bun-runtime-rules.md         # Bun-specific patterns
09-deno-runtime-rules.md        # Deno security model
10-express-integration-rules.md # Express.js patterns
```

## Key Patterns Index

### Builder Pattern
- **Location**: `13-core-architecture-rules.md`
- **Pattern**: Fluent configuration API
```typescript
const igniter = Igniter
  .cache(RedisAdapter)
  .docs({ openapi: {...} })
  .create();
```

### Feature-Sliced Architecture
- **Location**: `01-core-concepts-rules.md`
- **Structure**: `features/`, `shared/`, `entities/`, `app/`
- **Purpose**: Maintainable application organization

### Real-time SSE Patterns
- **Location**: `07-realtime-patterns-rules.md`
- **Implementation**: Generator functions for streaming
- **Features**: Chat, presence, typing indicators

### Autonomous Evolution
- **Location**: `05-autonomous-evolution-rules.md`
- **Capabilities**: Self-improvement, pattern learning
- **Verification**: Knowledge validation protocols

### Memory Management
- **Location**: `06-memory-management-rules.md`
- **Features**: Knowledge graphs, semantic search
- **Persistence**: Cross-session memory with TTL

### LIA Integration
- **Location**: `18-github-automation-rules.md`
- **Commands**: `@lia`, plan approval workflows
- **Automation**: Issue triage, code review, commit generation

## Technical Specifications

### TypeScript Configuration
```json
{
  "strict": true,
  "exactOptionalPropertyTypes": true,
  "noUncheckedIndexedAccess": true,
  "noImplicitReturns": true
}
```

### ESLint Rules
- **Base**: `@typescript-eslint/recommended`
- **Framework**: Custom Igniter.js rules
- **Quality**: Consistent naming, documentation

### Conventional Commits
```
<type>(<scope>): <description>

feat(core): add middleware chaining support
fix(cli): resolve port detection issue
docs(www): update getting started guide
```

### Testing Standards
- **Unit Tests**: Jest/Vitest with 80%+ coverage
- **Integration Tests**: Real database and network calls
- **E2E Tests**: Full application workflows

## Development Tools

### CLI Commands
```bash
igniter dev                 # Development server
igniter build              # Production build
igniter generate schema    # Type generation
igniter generate docs      # OpenAPI docs
igniter generate feature   # Feature scaffolding
```

### GitHub Workflows
- **lia-cli.yml**: Interactive AI assistant
- **lia-issue-automated-triage.yml**: Automatic issue labeling
- **lia-pr-review.yml**: Automated code review
- **lia-issue-scheduled-triage.yml**: Scheduled issue processing

### MCP Server Tools
- **Memory Management**: `store_memory`, `search_memories`
- **GitHub Integration**: Issue/PR management
- **CLI Operations**: Dev server, build, test commands
- **Code Investigation**: Pattern analysis, quality checks

## Framework Capabilities

### Supported Runtimes
- **Node.js**: Full compatibility with Express integration
- **Bun**: Native server, HMR, React 19 support
- **Deno**: Security-first with permissions model
- **Edge**: Cloudflare Workers, Vercel Edge Functions

### Framework Integrations
- **Next.js**: App Router, Server Components, streaming
- **React**: Client components, hydration, state management
- **Vue.js**: Composition API, SSR, reactivity
- **TanStack Start**: File-based routing, full-stack patterns

### Database Adapters
- **Prisma**: Type-safe ORM with migrations
- **Drizzle**: Lightweight ORM with edge support
- **Redis**: Caching and session management
- **PostgreSQL**: Primary database with advanced features

## Quality Metrics

### Code Quality
- **Type Safety**: 100% TypeScript coverage
- **Test Coverage**: 80%+ requirement
- **Documentation**: TSDoc for all public APIs
- **Linting**: Zero ESLint errors

### Performance Benchmarks
- **Cold Start**: <100ms for simple APIs
- **Request Handling**: <1ms overhead
- **Memory Usage**: <50MB baseline
- **Bundle Size**: <10KB client runtime

### Developer Experience
- **Setup Time**: <5 minutes from zero to running
- **Hot Reload**: <100ms for most changes
- **Error Messages**: Actionable with suggestions
- **Documentation**: Searchable with examples

## Usage Examples

### Basic API
```typescript
export const usersController = igniter.controller({
  name: 'users',
  actions: {
    list: igniter.query({
      handler: async () => users
    }),
    create: igniter.mutation({
      input: z.object({ name: z.string() }),
      handler: async ({ input }) => createUser(input)
    })
  }
});
```

### Real-time Chat
```typescript
export const chatController = igniter.controller({
  name: 'chat',
  actions: {
    messages: igniter.stream({
      handler: async function* () {
        const messages = await getMessages();
        yield { event: 'messages', data: messages };
      }
    })
  }
});
```

### Client Integration
```typescript
// React client
const { data } = useIgniterQuery({
  controller: 'users',
  action: 'list'
});

// Real-time updates
useIgniterStream({
  controller: 'chat',
  action: 'messages',
  onData: (message) => setMessages(prev => [...prev, message])
});
```

## Contributing Guidelines

### Rule Creation Process
1. **Analyze**: Study existing patterns and documentation
2. **Document**: Create comprehensive rule file
3. **Validate**: Test patterns with real implementations
4. **Review**: Get community feedback and approval
5. **Integrate**: Add to index and cross-reference

### Rule Maintenance
- **Regular Reviews**: Monthly pattern analysis
- **Community Input**: Gather feedback on effectiveness
- **Framework Updates**: Sync with new releases
- **Performance Monitoring**: Track pattern impact

### Quality Standards
- **Clarity**: Rules must be clear and actionable
- **Examples**: Include code examples for complex patterns
- **Context**: Explain why patterns are recommended
- **Evolution**: Rules should support framework growth

---

*Complete rules system for Igniter.js framework development - Generated September 13, 2025*