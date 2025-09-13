# Git and Version Control Workflow Rules

## Overview
Comprehensive Git workflow patterns and version control rules for Igniter.js framework development, based on repository analysis and established patterns.

## Conventional Commits Standard

### Commit Message Format
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Primary Commit Types
- **feat**: New features or enhancements
- **fix**: Bug fixes and corrections
- **docs**: Documentation-only changes
- **refactor**: Code restructuring without functionality changes
- **chore**: Maintenance tasks (dependencies, build, tooling)
- **test**: Adding or modifying tests
- **ci**: CI/CD workflow changes
- **perf**: Performance improvements

### Scope Guidelines
Based on repository structure analysis:
- **core**: Changes to `packages/core`
- **cli**: Changes to `packages/cli`
- **mcp-server**: Changes to `packages/mcp-server`
- **adapters**: Changes to `packages/adapters`
- **eslint-config**: Changes to `packages/eslint-config`
- **starters**: Changes to starter templates
- **www**: Changes to documentation website
- **repo**: Repository-level changes (root configs, CI/CD)
- **docs**: Documentation updates

### Commit Examples
```bash
feat(core): enhance URL generation with query parameter support
fix(core): ensure parsed body and query are reassigned to context
chore(core): bump version to 0.2.68
feat(mcp-server): introduce comprehensive tooling integration
docs(www): restructure MCP server documentation
refactor(starter-nextjs): update example feature and dependencies
```

## Branch Strategy

### Main Branches
- **main**: Production-ready code, protected branch
- **fork/main**: Fork synchronization with upstream

### Feature Branch Naming
```
feat/<feature-name>
fix/<bug-description>
docs/<documentation-update>
chore/<maintenance-task>
cursor/<cursor-ai-generated>
release/<version>
```

### Feature Development Workflow
1. **Create Feature Branch**: Always branch from `main`
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feat/new-feature
   ```

2. **Development**: Make atomic commits with conventional format
   ```bash
   git add path/to/specific/files
   git commit -m "feat(scope): description"
   ```

3. **Push and PR**: Push to origin and create pull request
   ```bash
   git push origin feat/new-feature
   gh pr create --title "feat(scope): description" --body "Detailed description"
   ```

## LIA (AI Assistant) Integration

### Automated Workflows
- **AI-Triggered Actions**: `@lia` mentions trigger automated workflows
- **Plan-Based Development**: Complex changes require plan approval
- **Automated Triage**: Issues and PRs get automated initial triage

### LIA Workflow Patterns
1. **Initial Request**: User mentions `@lia` with request
2. **Plan Generation**: AI creates structured plan with UUID
3. **User Approval**: User approves with `@lia plan#<uuid> approved`
4. **Execution**: AI executes approved plan with progress updates
5. **Completion**: Final summary and PR creation if needed

### LIA Commit Rules
- Never commit directly to `main` branch
- Use descriptive commit messages following conventional format
- Stage specific files, never use `git add .`
- Create PRs for new feature branches
- Report progress through GitHub comments

## Pull Request Guidelines

### PR Template Requirements
- Clear description of changes and purpose
- Type classification (bug fix, feature, docs, etc.)
- Testing instructions
- Checklist completion
- Link to related issues

### Review Process
- Automated triage via LIA workflows
- Code quality checks via ESLint configuration
- Documentation updates required for new features
- Test coverage for new functionality

### Merge Strategy
- Squash and merge for feature branches
- Conventional commit message for merge commits
- Delete feature branches after successful merge

## Release Management

### Version Bumping
- Follow semantic versioning (SemVer)
- Version bumps via `chore(scope): bump version to X.Y.Z`
- Automated version management in monorepo packages

### Release Branches
- Create release branches for major versions
- Hotfix branches for critical production fixes
- Tag releases with proper version format

## Repository Hygiene

### Ignored Files (.gitignore)
```
# Build outputs
dist/
build/
.next/
out/

# Dependencies
node_modules/
.pnp.*

# Environment
.env*

# IDE and OS
.vscode/
.DS_Store
Thumbs.db

# Monorepo specific
packages/*/dist
apps/*/build
yarn.lock
pnpm-lock.yaml

# AI and tooling
.cursor/
.trae/
.gemini/
.copilot/
```

### Git Configuration
```bash
# Global configuration for Igniter.js contributors
git config user.name "Your Name"
git config user.email "your.email@domain.com"

# Useful aliases
git config alias.quick-commit "!f() { git add -A && git commit -m \"$1\" --no-verify; }; f"
git config alias.push-all "!git push origin $(git branch --show-current)"
git config alias.sync "!git pull origin $(git branch --show-current) && git push origin $(git branch --show-current)"
```

## Monorepo Workflow

### Package Dependencies
- Use `npm` as primary package manager
- Lock files (yarn.lock, pnpm-lock.yaml) are ignored
- Workspace management via package.json workspaces

### Cross-Package Changes
- Atomic commits across related packages
- Version bumps coordinated across dependencies
- Testing integration between packages

### Build and Release
- Turborepo for build orchestration
- Individual package versioning
- Coordinated releases for breaking changes

## Security and Compliance

### Sensitive Information
- Never commit API keys, tokens, or credentials
- Use environment variables for configuration
- Review commits for accidental sensitive data exposure

### Backup and Recovery
- Fork repository serves as backup (`remotes/fork/main`)
- Regular synchronization between fork and origin
- Disaster recovery procedures documented

## Workflow Integration Tools

### GitHub CLI Integration
```bash
# Issue management
gh issue create --title "Bug: description" --body "Details"
gh issue comment <number> --body "Update"

# PR management
gh pr create --title "feat(scope): description" --body "Details"
gh pr view <number>
gh pr merge <number> --squash
```

### Automation Scripts
- Pre-commit hooks for code quality
- Automated testing on push
- Release automation via GitHub Actions

## Quality Gates

### Pre-commit Checks
- ESLint validation
- TypeScript compilation
- Unit test execution
- Conventional commit format validation

### CI/CD Pipeline
- Automated testing across Node.js versions
- Build verification for all packages
- Documentation generation and deployment
- Security vulnerability scanning

## Best Practices

### Commit Granularity
- One logical change per commit
- Separate concerns (feature vs. test vs. docs)
- Atomic commits that can be safely reverted

### Collaboration
- Clear PR descriptions with context
- Responsive code review participation
- Constructive feedback and iteration

### Documentation
- Update docs with code changes
- Maintain CHANGELOG.md for releases
- Document breaking changes prominently

## Troubleshooting

### Common Issues
- **Merge Conflicts**: Resolve by rebasing feature branch
- **Failed CI**: Check ESLint and TypeScript errors
- **LIA Workflow Failures**: Verify GitHub permissions and tokens

### Recovery Procedures
- Undo last commit: `git reset --soft HEAD~1`
- Force push after rebase: `git push --force-with-lease`
- Emergency rollback: Create hotfix branch from last known good commit

---

*This workflow ensures consistent, high-quality contributions to the Igniter.js framework while leveraging AI-assisted development through LIA integration.*