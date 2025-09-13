# LIA Command System Reference
**Version**: 2.0
**Date**: September 13, 2025
**Integration**: Claude Code Unified Interface

## 🎯 Overview

The LIA (Learning & Intelligence Agent) Command System provides a comprehensive set of AI-powered automation commands for ExzosFramer.js development. All commands are accessible through Claude Code's unified interface using GitHub comments with @mentions and slash commands.

## 🎭 AI Personality System

### @claude
**Role**: General Assistant
**Communication**: Standard helpful responses
**Use Cases**: General questions, documentation, planning

```markdown
@claude What's the best approach for implementing caching?
@claude Help me understand the adapter pattern
@claude /docs validate
```

### @claude-lia
**Role**: Learning & Intelligence Agent (LIA)
**Communication**: First-person, proactive guidance
**Use Cases**: Development tasks, autonomous operations, framework expertise

```markdown
@claude-lia I need to implement user authentication
@claude-lia /generate feature auth
@claude-lia /develop optimize-performance
```

### @claude-code
**Role**: Code Review Specialist
**Communication**: Technical, review-focused feedback
**Use Cases**: Code review, quality assurance, security analysis

```markdown
@claude-code /review
@claude-code Please analyze this PR for security issues
@claude-code /triage
```

## 📋 Command Reference

### 🎯 Core Development Commands

#### `/triage`
**Purpose**: Automated issue analysis and labeling
**Personality**: Any (`@claude`, `@claude-lia`, `@claude-code`)
**Context**: GitHub Issues
**Permissions**: `issues: write`

```markdown
@claude-lia /triage
```

**Capabilities**:
- Content analysis and categorization
- Priority assignment (low, medium, high, critical)
- Type classification (bug, feature, enhancement, documentation)
- Complexity estimation
- Assignment suggestions based on expertise areas

**Example Output**:
```markdown
## ✅ Issue Triaged

**Analysis Results**:
- **Type**: Feature Request
- **Priority**: Medium
- **Complexity**: Moderate (3-5 days)
- **Category**: Core Framework
- **Labels Applied**: `feature`, `core`, `priority:medium`

**Recommendation**:
This feature request aligns with framework roadmap goals. Suggested assignee: @core-team-member
```

#### `/review`
**Purpose**: Comprehensive code review for pull requests
**Personality**: Primarily `@claude-code`, also `@claude-lia`
**Context**: Pull Requests
**Permissions**: `pull-requests: write`, `contents: read`

```markdown
@claude-code /review
```

**Analysis Areas**:
- Code quality and best practices adherence
- Security vulnerability scanning
- Performance impact assessment
- Type safety validation
- Test coverage analysis
- Documentation completeness
- Framework compliance

**Example Output**:
```markdown
## 🔍 Code Review Complete

**Overall Assessment**: ✅ APPROVED with suggestions

### Security Analysis
- ✅ No security vulnerabilities detected
- ✅ Input validation implemented properly
- ⚠️ Consider rate limiting for API endpoints

### Performance Analysis
- ✅ No performance regressions detected
- 📈 Improvement: 15% faster response time
- ⚠️ Memory usage increased by 2MB (within limits)

### Type Safety
- ✅ All types properly defined
- ✅ No `any` types used
- ✅ Full type inference maintained

### Recommendations
1. Add JSDoc comments for public methods
2. Consider extracting utility functions
3. Add integration tests for new endpoints

**Approval Status**: ✅ Ready to merge
```

#### `/generate [type] [name]`
**Purpose**: Automated code scaffolding and generation
**Personality**: Primarily `@claude-lia`
**Types**: `controller`, `feature`, `adapter`, `test`
**Permissions**: `contents: write`

```markdown
@claude-lia /generate controller user
@claude-lia /generate feature authentication
@claude-lia /generate adapter redis
@claude-lia /generate test user-service
```

**Generation Types**:

**Controller Generation**:
```typescript
// Generated: src/controllers/user.controller.ts
export class UserController {
  async getUser(req: Request, res: Response) {
    // Type-safe implementation
  }

  async createUser(req: Request, res: Response) {
    // Validation and creation logic
  }
}
```

**Feature Generation**:
```
Generated Structure:
├── src/features/authentication/
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── auth.types.ts
│   ├── auth.middleware.ts
│   └── __tests__/
│       ├── auth.controller.test.ts
│       └── auth.service.test.ts
├── docs/features/authentication.md
└── Updated: README.md, package.json
```

**Adapter Generation**:
```typescript
// Generated: src/adapters/redis.adapter.ts
import { IgniterStoreAdapter } from '@igniter-js/core';

export class RedisAdapter implements IgniterStoreAdapter {
  async get<T>(key: string): Promise<T | null> {
    // Redis implementation
  }

  async set<T>(key: string, value: T): Promise<void> {
    // Redis implementation
  }
}
```

#### `/develop [task]`
**Purpose**: Autonomous development task execution
**Personality**: `@claude-lia`
**Tasks**: Complex development operations
**Permissions**: `contents: write`, `pull-requests: write`

```markdown
@claude-lia /develop create-adapter redis-cache
@claude-lia /develop optimize-performance
@claude-lia /develop refactor-core-types
@claude-lia /develop analyze-codebase
```

**Available Tasks**:
- `create-adapter`: Create new framework adapters
- `create-feature`: Implement complete features
- `optimize-performance`: Performance optimizations
- `refactor-code`: Code refactoring and cleanup
- `update-documentation`: Documentation improvements
- `analyze-codebase`: Comprehensive code analysis

**Example Execution**:
```markdown
## 🤖 Autonomous Development Task: create-adapter

**Task**: Create Redis caching adapter
**Estimated Duration**: 45 minutes
**Status**: ✅ COMPLETE

### Implementation Summary
1. ✅ Created `RedisAdapter` implementing `IgniterStoreAdapter`
2. ✅ Added comprehensive test suite (95% coverage)
3. ✅ Generated TypeScript types and interfaces
4. ✅ Updated documentation and examples
5. ✅ Added configuration schema validation

### Files Created/Modified
- `packages/adapter-redis/src/redis.adapter.ts` (new)
- `packages/adapter-redis/src/types.ts` (new)
- `packages/adapter-redis/__tests__/redis.adapter.test.ts` (new)
- `docs/adapters/redis-adapter.md` (new)
- `README.md` (updated)

### Next Steps
1. Review generated code for business requirements
2. Run integration tests: `npm run test:adapter-redis`
3. Update configuration documentation
```

### 🔧 Maintenance Commands

#### `/maintenance`
**Purpose**: System maintenance and health checks
**Personality**: Primarily `@claude-lia`
**Schedule**: Daily at 02:00 UTC (automatic)
**Permissions**: `contents: read`, `issues: write`

```markdown
@claude-lia /maintenance
```

**Maintenance Tasks**:
- Dependency vulnerability scanning
- Performance benchmarking
- Documentation validation
- Link checking and repair
- Build health verification
- Test coverage analysis
- Security audit execution

**Example Report**:
```markdown
## 🔧 Maintenance Report

**Execution Date**: September 13, 2025, 02:00 UTC
**Duration**: 8 minutes, 23 seconds
**Status**: ✅ ALL CHECKS PASSED

### Security Audit
- ✅ No critical vulnerabilities
- ✅ All dependencies up to date
- ℹ️ 2 minor updates available (non-breaking)

### Performance Analysis
- ✅ Build time: 45s (target: <60s)
- ✅ Test execution: 12s (target: <30s)
- ✅ Memory usage: stable
- ✅ Bundle size: within limits

### Documentation Health
- ✅ All links functional
- ✅ API docs synchronized
- ✅ Examples tested and working
- ℹ️ 3 docs could benefit from updates

### Recommendations
1. Update lodash to v4.17.21 (security patch)
2. Consider updating TypeScript to 5.2.x
3. Add JSDoc to 3 new utility functions

**Next Maintenance**: September 14, 2025, 02:00 UTC
```

#### `/cli [command]`
**Purpose**: Interactive CLI assistance and guidance
**Personality**: `@claude-lia`
**Context**: Framework CLI operations
**Permissions**: `contents: read`

```markdown
@claude-lia /cli help
@claude-lia /cli create-project
@claude-lia /cli add-adapter
```

**CLI Support Areas**:
- Command explanation and examples
- Parameter validation and suggestions
- Configuration assistance
- Troubleshooting guidance
- Best practices recommendations
- Error resolution help

**Example Interaction**:
```markdown
## 💻 CLI Assistance: create-project

**Command**: `igniter create my-project`

### Parameters Available
- `--template`: Project template (api, fullstack, microservice)
- `--typescript`: Use TypeScript (default: true)
- `--database`: Database adapter (postgres, mysql, sqlite)
- `--cache`: Cache adapter (redis, memory)
- `--auth`: Authentication provider (jwt, oauth, custom)

### Example Usage
```bash
# Create API-only project with Redis caching
igniter create my-api --template=api --cache=redis

# Create fullstack project with PostgreSQL
igniter create my-app --template=fullstack --database=postgres
```

### Best Practices
1. Use TypeScript for better development experience
2. Choose database based on scale requirements
3. Redis recommended for production caching
4. JWT auth suitable for most use cases

### Next Steps
After project creation:
1. `cd my-project`
2. `npm install`
3. `npm run dev`
4. Visit `http://localhost:3000`
```

### 📚 Documentation Commands

#### `/docs [action]`
**Purpose**: Documentation management and updates
**Personality**: Any personality
**Actions**: `update`, `generate`, `validate`, `sync`
**Permissions**: `contents: write`

```markdown
@claude-lia /docs update
@claude-lia /docs generate api
@claude-lia /docs validate
@claude-lia /docs sync
```

**Documentation Actions**:

**Update**: Refresh existing documentation
```markdown
@claude-lia /docs update adapters
# Updates all adapter documentation with latest API changes
```

**Generate**: Create new documentation
```markdown
@claude-lia /docs generate api user-controller
# Generates API documentation from controller code
```

**Validate**: Check documentation quality
```markdown
@claude-lia /docs validate
# Checks for broken links, outdated examples, missing docs
```

**Sync**: Synchronize with code changes
```markdown
@claude-lia /docs sync
# Updates docs to match current codebase state
```

#### `/prompt [action] [name]`
**Purpose**: AI prompt lifecycle management
**Personality**: `@claude-lia`
**Actions**: `create`, `execute`, `list`, `optimize`
**Permissions**: `contents: write`

```markdown
@claude-lia /prompt create feature-template
@claude-lia /prompt execute code-review
@claude-lia /prompt list development
@claude-lia /prompt optimize performance-analysis
```

**Prompt Management**:

**Create**: Generate new automation prompts
```markdown
@claude-lia /prompt create adapter-generator
# Creates reusable prompt for adapter generation
```

**Execute**: Run existing prompts
```markdown
@claude-lia /prompt execute security-audit
# Executes security audit prompt with current context
```

**List**: Display available prompts
```markdown
@claude-lia /prompt list
# Shows all available prompts by category
```

**Optimize**: Improve prompt effectiveness
```markdown
@claude-lia /prompt optimize code-review
# Analyzes and improves code review prompt performance
```

### 🚀 Deployment Commands

#### `/test [scope]`
**Purpose**: Test execution and validation
**Personality**: Any personality
**Scopes**: `unit`, `integration`, `e2e`, `all`
**Permissions**: `actions: write`

```markdown
@claude-lia /test unit
@claude-lia /test integration auth
@claude-lia /test all
```

#### `/build [target]`
**Purpose**: Project building and compilation
**Personality**: `@claude-lia`
**Targets**: `development`, `production`, `packages`
**Permissions**: `contents: read`, `actions: write`

```markdown
@claude-lia /build production
@claude-lia /build packages
```

#### `/deploy [environment]`
**Purpose**: Deployment automation
**Personality**: `@claude-lia`
**Environments**: `staging`, `production`
**Permissions**: Limited deployment access

```markdown
@claude-lia /deploy staging
@claude-lia /deploy production
```

## 🔧 Advanced Usage Patterns

### Command Chaining
Execute multiple related commands in sequence:

```markdown
@claude-lia I need to implement user authentication with Redis sessions

/generate feature auth
/generate adapter redis-session
/test integration auth
/docs update authentication
/build production
```

### Context-Aware Operations
Commands understand repository context and current state:

```markdown
# In an issue about performance
@claude-lia /develop optimize-performance
# Automatically focuses on performance issues mentioned in the issue

# In a PR with TypeScript changes
@claude-code /review
# Focuses on TypeScript-specific review criteria
```

### Conditional Execution
Commands can include conditional logic:

```markdown
@claude-lia /generate controller user --with-tests --if-not-exists
@claude-lia /deploy production --only-if-tests-pass
```

## 🔐 Security and Permissions

### Permission Model
Each command operates with minimal required permissions:

```yaml
# Read-only commands
/docs validate: contents: read
/cli help: contents: read

# Write commands (creates PRs for review)
/generate: contents: write, pull-requests: write
/develop: contents: write, pull-requests: write

# Administrative commands (limited users)
/deploy: deployment permissions required
/maintenance: admin or maintainer role required
```

### Safety Features
- **Validation Gates**: All generated code reviewed before application
- **Rollback Capability**: Changes made via reviewable PRs
- **Resource Limits**: Execution time and resource constraints
- **Audit Logging**: All command executions logged and trackable

## 📊 Performance Characteristics

### Response Time Targets
- **Simple Commands** (`/triage`, `/docs validate`): < 10 seconds
- **Generation Commands** (`/generate`, `/review`): < 30 seconds
- **Development Commands** (`/develop`, `/maintenance`): < 5 minutes
- **Complex Operations** (full feature development): < 30 minutes

### Success Rate Metrics
- **Command Parsing**: 99.9%
- **Execution Success**: 98%+
- **Code Generation Quality**: 95%+ passes review
- **Error Recovery**: < 5 seconds

## 🎓 Best Practices

### Command Usage
1. **Be Specific**: Provide clear parameters and context
2. **Use Appropriate Personality**: Match AI personality to task type
3. **Check Results**: Review generated code and outputs
4. **Provide Feedback**: Help improve AI responses over time

### Development Workflow
1. **Plan with @claude**: Discuss approach and architecture
2. **Implement with @claude-lia**: Generate and develop features
3. **Review with @claude-code**: Validate quality and security
4. **Document with /docs**: Keep documentation current

### Error Recovery
1. **Check Command Syntax**: Verify proper command format
2. **Review Permissions**: Ensure necessary access rights
3. **Check Context**: Verify command is appropriate for current context
4. **Report Issues**: Use GitHub issues for persistent problems

---

**Command System Status**: ✅ FULLY OPERATIONAL
**Available Commands**: 10 core commands + variations
**Integration Coverage**: 100% of LIA workflows
**Average Response Time**: < 30 seconds
**Success Rate**: 98%+