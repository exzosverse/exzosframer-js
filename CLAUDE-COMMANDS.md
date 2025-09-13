# 🤖 Claude Code Commands Reference

## Available Claude Personalities

### @claude
The standard Claude assistant for general help and questions.

### @claude-lia
Activates LIA (Learning & Intelligence Agent) personality with:
- First-person perspective
- Proactive assistance
- 5 pillars of responsibility
- Framework-specific expertise

### @claude-code
Specialized for code review and analysis with focus on:
- Type safety
- Performance
- Security
- Best practices

## 📋 Available Commands

All commands work with any Claude personality (@claude, @claude-lia, @claude-code).

### Issue & PR Management

#### `/triage`
Automatically triage and label issues based on content.
```markdown
@claude-lia /triage
```

#### `/review`
Perform comprehensive code review on pull requests.
```markdown
@claude-code /review
```

### Code Generation

#### `/generate [type] [name]`
Generate boilerplate code for various components.

**Types available:**
- `controller` - Generate a REST controller
- `feature` - Generate complete feature structure
- `adapter` - Generate runtime adapter
- `test` - Generate test suite

**Examples:**
```markdown
@claude-lia /generate controller user
@claude-lia /generate feature authentication
@claude-lia /generate test user-service
@claude-lia /generate adapter redis
```

### Maintenance & Operations

#### `/maintenance`
Run maintenance tasks including:
- Dependency updates check
- Security audit
- Performance analysis
- Documentation sync

```markdown
@claude-lia /maintenance
```

#### `/schedule [task]`
Schedule automated tasks for later execution.
```markdown
@claude-lia /schedule dependency-update
```

### Development Commands

#### `/cli [command]`
Interactive CLI assistance for framework commands.
```markdown
@claude-lia /cli help
```

#### `/test [scope]`
Run tests with optional scope.
```markdown
@claude-lia /test unit
@claude-lia /test integration
@claude-lia /test all
```

#### `/build [target]`
Build the project with optional target.
```markdown
@claude-lia /build production
@claude-lia /build development
```

#### `/deploy [environment]`
Deploy to specified environment.
```markdown
@claude-lia /deploy staging
@claude-lia /deploy production
```

### Documentation

#### `/docs [action]`
Manage documentation.
```markdown
@claude-lia /docs update
@claude-lia /docs generate
@claude-lia /docs validate
```

## 🎯 Usage Examples

### Complete Feature Development
```markdown
@claude-lia I need to implement user authentication with JWT tokens.
/generate feature auth
/generate controller auth
/generate test auth
/docs update
```

### Bug Fix Workflow
```markdown
@claude-lia There's a type error in the user controller
/triage
/review
@claude Can you help fix the type error in line 45?
```

### Maintenance Routine
```markdown
@claude-lia /maintenance
/test all
/build production
/docs validate
```

## 🔄 Workflow Integration

### Automatic Triggers

1. **New Issues**: Automatically triaged when opened
2. **Pull Requests**: Automatically reviewed when opened
3. **Mentions**: Responds when @claude, @claude-lia, or @claude-code is mentioned
4. **Commands**: Executes when slash commands are detected

### Response Format

Each Claude personality responds differently:

**@claude**: Standard helpful responses
**@claude-lia**: First-person, proactive guidance
**@claude-code**: Technical, review-focused feedback

## 🎮 Advanced Usage

### Combining Commands
You can use multiple commands in a single comment:
```markdown
@claude-lia
/triage
/generate controller products
/test products
/docs update
```

### Context-Aware Responses
Claude maintains context throughout the conversation:
```markdown
@claude-lia Help me implement caching
# LIA provides caching guidance

@claude-lia /generate feature cache
# LIA generates cache feature based on previous context
```

### Custom Prompts
You can provide specific instructions:
```markdown
@claude-lia Using Redis, implement a distributed cache with TTL support
/generate feature redis-cache
```

## 🔒 Permissions

Claude Code has the following permissions:
- Read repository contents
- Write and edit files
- Create branches and commits
- Add comments to issues and PRs
- Apply labels
- Run npm commands
- Execute git operations

## 📝 Notes

- All commands are processed via GitHub Actions
- Responses appear as comments on issues/PRs
- Generated code creates new branches when appropriate
- Maintenance tasks run with safety checks
- All actions are logged in GitHub Actions history

## 🆘 Getting Help

If you need help with commands:
```markdown
@claude-lia /cli help
@claude-lia What commands are available?
@claude-lia How do I generate a new feature?
```

---

*Powered by Claude Code with LIA Integration for ExzosFramer.js*