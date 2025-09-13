# Code Agents Rules - Igniter.js Framework

## 🤖 AI-Friendly Architecture Principles

### Framework Design for AI
- **Explicit over implicit** - Clear patterns for AI to follow
- **Type-safe throughout** - Full type inference chain
- **Self-documenting code** - Comprehensive JSDoc and types
- **Modular structure** - Feature-sliced for parallel work
- **Consistent patterns** - Predictable code organization

### AI Agent Communication
- **AGENT.md files** - Feature-specific instructions
- **llms.txt** - Framework training document
- **DOCS.md** - Technical implementation details
- **Type definitions** - Serve as contracts
- **JSDoc comments** - Inline explanations

## 📄 AGENT.md Structure Rules

### Root-Level AGENT.md
```markdown
# 1. Identity and Profile
**Name:** Lia
**Position:** AI Agent for [Project Name]
**Specialties:** Igniter.js, TypeScript, [Domain]
**Mission:** [Clear objectives]

## 2. Project Context
- Architecture overview
- Key dependencies
- Business domain
- Technical constraints

## 3. Development Guidelines
- Code standards
- Naming conventions
- Testing requirements
- Documentation standards

## 4. Common Tasks
- Feature implementation patterns
- Debugging procedures
- Deployment process
- Maintenance workflows
```

### Feature-Level AGENT.md
```markdown
# Feature: [Feature Name]

## Overview
[Feature purpose and context]

## Architecture
- Controllers: [Endpoints exposed]
- Procedures: [Middleware used]
- Schemas: [Data validation]
- Services: [Business logic]

## Development Patterns
[Specific patterns for this feature]

## Testing Strategy
[How to test this feature]

## Common Issues
[Known problems and solutions]
```

## 🎯 llms.txt Configuration

### Structure Requirements
```markdown
# Igniter.js Framework Documentation

## Core Concepts
[Essential framework concepts]

## API Reference
[Complete API documentation]

## Code Examples
[Working examples with explanations]

## Common Patterns
[Frequently used patterns]

## Troubleshooting
[Common issues and solutions]
```

### Content Guidelines
- **Complete examples** - Full working code
- **Type annotations** - Show all types
- **Error patterns** - Common mistakes
- **Best practices** - Recommended approaches
- **Anti-patterns** - What to avoid

## 🔧 Editor-Specific Rules

### Cursor Configuration
```json
// .cursorrules
{
  "instructions": "You are working with Igniter.js...",
  "context": {
    "framework": "igniter-js",
    "version": "0.2.x",
    "typescript": "5.x"
  },
  "rules": [
    "Always use context for services",
    "Never import services directly",
    "Follow Feature-Sliced Architecture",
    "Maintain type safety throughout"
  ]
}
```

### Windsurf Rules
```json
// .windsurf/rules.json
{
  "workspace": {
    "framework": "igniter-js",
    "patterns": {
      "controllers": "src/features/*/controllers/*.ts",
      "procedures": "src/features/*/procedures/*.ts",
      "schemas": "src/features/*/schemas/*.ts"
    }
  }
}
```

### Claude Project Instructions
```markdown
// .claude/instructions.md
You are Lia, an expert Igniter.js developer.

Core principles:
1. Type safety is paramount
2. Use procedures for middleware
3. Access services through context
4. Follow existing patterns

When implementing features:
1. Use `igniter generate feature` for scaffolding
2. Register controllers in router
3. Write comprehensive tests
4. Update documentation
```

## 🏗️ MCP Server Integration

### MCP Configuration
```typescript
// .mcp/config.ts
export const mcpConfig = {
  tools: [
    {
      name: 'generate_feature',
      description: 'Generate Igniter.js feature',
      inputSchema: {
        type: 'object',
        properties: {
          name: { type: 'string' },
          schema: { type: 'string' }
        }
      },
      handler: async ({ name, schema }) => {
        return execSync(`igniter generate feature ${name} --schema ${schema}`);
      }
    }
  ]
};
```

### MCP Usage Patterns
```typescript
// ✅ CORRECT: Use MCP tools for scaffolding
await mcp.tools.generate_feature({
  name: 'products',
  schema: 'prisma:Product'
});

// ✅ CORRECT: Use MCP for testing
await mcp.tools.run_tests({
  filter: 'products'
});
```

## 📝 Documentation for AI

### Code Documentation Rules
```typescript
/**
 * Creates a new user account
 *
 * @param input - User registration data
 * @returns Created user object without password
 * @throws {ValidationError} Invalid input data
 * @throws {ConflictError} Email already exists
 *
 * @example
 * ```typescript
 * const user = await createUser({
 *   email: 'user@example.com',
 *   name: 'John Doe'
 * });
 * ```
 */
export async function createUser(input: CreateUserInput): Promise<User> {
  // Implementation
}
```

### Type Documentation
```typescript
/**
 * User entity representation
 * @property id - Unique identifier (CUID)
 * @property email - User's email address (unique)
 * @property name - Display name
 * @property role - User role for permissions
 */
export interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'user';
}
```

## 🎮 AI Task Patterns

### Feature Implementation
```markdown
## Task: Implement user authentication

### Steps:
1. Generate feature scaffold
   ```bash
   igniter generate feature auth --schema prisma:User
   ```

2. Implement auth procedure
   - Token verification
   - User context extension
   - Error handling

3. Add login/logout mutations
   - Validate credentials
   - Generate JWT
   - Set secure cookies

4. Create protected routes
   - Use auth procedure
   - Handle unauthorized

5. Write tests
   - Unit tests for auth logic
   - Integration tests for endpoints

6. Update documentation
   - API endpoints in DOCS.md
   - Usage examples
```

### Bug Investigation
```markdown
## Task: Debug failing authentication

### Investigation Steps:
1. Check error logs
   - Server logs for stack traces
   - Client console for errors

2. Verify token flow
   - Token generation
   - Header transmission
   - Token parsing

3. Test procedure chain
   - Procedure execution order
   - Context propagation
   - Error handling

4. Validate schemas
   - Request validation
   - Response structure

5. Check database
   - User records
   - Session data
```

## 🚀 Prompt Engineering for Igniter.js

### Effective Prompts
```markdown
✅ GOOD: "Create a products feature with CRUD operations using Prisma Product model"
- Clear scope
- Specific requirements
- Uses framework patterns

✅ GOOD: "Add caching to the products list endpoint with 5-minute TTL"
- Specific feature
- Clear parameters
- Measurable outcome

❌ BAD: "Make the API faster"
- Too vague
- No specific target
- No success criteria

❌ BAD: "Add authentication"
- Missing implementation details
- No specific requirements
- Too broad
```

### Context Provision
```markdown
## Always provide:
1. Current file path
2. Related files
3. Error messages (complete)
4. Expected behavior
5. What you've tried

## Example:
"In src/features/users/controllers/users.controller.ts,
the list action is throwing a type error.
The error is: Type 'string' is not assignable to type 'number'.
This happens when passing page parameter.
I've checked the schema and it expects a number."
```

## 🎯 AI Agent Best Practices

### Code Generation
- **Use CLI first** - `igniter generate` commands
- **Follow patterns** - Match existing code style
- **Maintain types** - Never use `any`
- **Test immediately** - Verify generated code
- **Document changes** - Update AGENT.md

### Code Review
- **Check type safety** - No type assertions
- **Verify patterns** - Consistent with codebase
- **Test coverage** - New code has tests
- **Documentation** - Comments and types updated
- **Performance** - No obvious bottlenecks

### Refactoring
- **Small increments** - One pattern at a time
- **Maintain tests** - Keep tests passing
- **Preserve types** - Don't break type chain
- **Update docs** - Reflect new structure
- **Commit often** - Easy rollback points

## 🚨 AI Anti-Patterns

### ❌ Hallucinated APIs
```typescript
// WRONG: This API doesn't exist
igniter.magicQuery({
  autoCache: true,
  smartRefetch: true
});
```

### ❌ Pattern Breaking
```typescript
// WRONG: Direct import instead of context
import { database } from '@/lib/database';
```

### ❌ Type Unsafe Code
```typescript
// WRONG: Using any
const result: any = await api.query();
```

### ❌ Missing Error Handling
```typescript
// WRONG: No error handling
const user = await getUser(id);
return user.name; // What if user is null?
```

## 📋 AI Agent Checklist

### Before Starting
- [ ] Read root AGENT.md
- [ ] Read feature AGENT.md (if exists)
- [ ] Understand project structure
- [ ] Check existing patterns
- [ ] Review similar features

### During Development
- [ ] Use CLI for scaffolding
- [ ] Follow existing patterns
- [ ] Maintain type safety
- [ ] Handle errors properly
- [ ] Write tests alongside code

### After Implementation
- [ ] Run type checking
- [ ] Run tests
- [ ] Update documentation
- [ ] Check for breaking changes
- [ ] Commit with clear message

### For AI Agents
- [ ] Provide clear context
- [ ] Include error messages
- [ ] Show file paths
- [ ] Explain what was tried
- [ ] State expected outcome

---

**Remember**: Igniter.js is designed to be AI-friendly. Use the framework's explicit patterns and type safety to guide accurate code generation. Always verify AI-generated code against the framework's principles.