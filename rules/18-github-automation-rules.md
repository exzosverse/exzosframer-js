# GitHub Automation and Integration Rules

## Overview
Comprehensive GitHub automation patterns and integration rules for Igniter.js framework, based on LIA (AI Assistant) workflows and repository automation systems.

## LIA (AI Assistant) Integration System

### Core LIA Workflows

#### 1. LIA CLI Workflow (`lia-cli.yml`)
**Trigger**: `@lia` mentions in issues, PRs, and comments
**Purpose**: Interactive AI assistant for complex development tasks

```yaml
# Activation patterns:
- @lia <request>               # General request
- @lia plan#<uuid> approved    # Plan approval
- @lia plan#<uuid> rejected    # Plan rejection
- @lia plan#<uuid> <changes>   # Plan modification
```

**Workflow Patterns**:
- **Initial Request**: AI creates structured plan with UUID
- **Plan Approval**: User approves with specific format
- **Plan Execution**: AI executes with progress tracking
- **Branch Management**: Never commits to main, creates feature branches
- **PR Creation**: Automatic PR generation for completed work

#### 2. Automated Issue Triage (`lia-issue-automated-triage.yml`)
**Trigger**: New issues, issue comments, manual dispatch
**Purpose**: Automatic label assignment and issue categorization

```yaml
# Label patterns:
kind/*     # bug, feature, documentation, question
area/*     # core, cli, adapters, www, tooling
priority/* # low, medium, high, critical
status/*   # needs-triage, waiting-response, blocked
```

**Triage Process**:
1. Analyze issue title and body
2. Apply appropriate existing labels
3. Remove `status/needs-triage` when processed
4. Focus on `kind/*`, `area/*`, `priority/*` patterns

#### 3. Scheduled Issue Triage (`lia-issue-scheduled-triage.yml`)
**Trigger**: Hourly cron schedule (`0 * * * *`)
**Purpose**: Process unlabeled and needs-triage issues

```bash
# Search patterns:
is:open is:issue no:label                    # Unlabeled issues
is:open is:issue label:"status/needs-triage" # Triage queue
```

**Batch Processing**:
- Finds issues without labels or needing triage
- Processes multiple issues in single workflow run
- Deduplicates issues across searches
- Applies labels based on content analysis

#### 4. Pull Request Review (`lia-pr-review.yml`)
**Trigger**: New PRs, review comments, manual requests
**Purpose**: Automated code review with severity classification

```yaml
# Review triggers:
- Pull request opened
- @lia /review <optional-focus>
- Manual workflow dispatch
```

**Review Process**:
1. **Analysis Phase**: PR diff, file changes, context gathering
2. **Review Creation**: Pending review with structured comments
3. **Comment Classification**: Severity-based feedback system
4. **Review Submission**: Comprehensive summary with recommendations

### LIA Command System

#### Core Commands
```bash
@lia <general-request>           # General task execution
@lia /triage                     # Force issue triage
@lia /review [focus-area]        # Code review request
@lia plan#<uuid> approved        # Approve execution plan
@lia plan#<uuid> rejected        # Reject execution plan
@lia plan#<uuid> <modification>  # Request plan changes
```

#### Focus Areas for Reviews
- `focus on security`           # Security vulnerability scan
- `check performance`          # Performance optimization review
- `review error handling`      # Error handling patterns
- `check for breaking changes` # Breaking change detection

## Issue and PR Templates

### Issue Templates

#### 1. Bug Report Template
**File**: `.github/ISSUE_TEMPLATE/bug_report.md`
**Labels**: `bug`, `help wanted`

**Required Sections**:
- **Bug Description**: Clear, concise problem statement
- **Reproduction Steps**: Numbered list with minimal steps
- **Expected vs Actual Behavior**: Clear distinction
- **Environment Details**: OS, Node.js, Igniter.js versions, framework
- **Minimal Reproducible Example**: Code snippet or repository link
- **Screenshots**: Visual evidence when applicable

#### 2. Feature Request Template
**File**: `.github/ISSUE_TEMPLATE/feature_request.md`
**Labels**: `feature-request`

**Required Sections**:
- **Problem Statement**: What problem does this solve?
- **Proposed Solution**: Developer experience description
- **Alternatives Considered**: Why other solutions aren't ideal
- **API Proposal**: Optional code example of envisioned usage
- **Additional Context**: Links, screenshots, use cases

#### 3. Documentation Request Template
**File**: `.github/ISSUE_TEMPLATE/documentation_request.md`
**Labels**: `documentation`, `help wanted`

**Required Sections**:
- **Missing Documentation**: Specific gap identification
- **Importance**: Why this documentation matters
- **Suggested Content**: Optional structure or outline
- **Additional Context**: Related examples or use cases

### Pull Request Template
**File**: `.github/PULL_REQUEST_TEMPLATE.md`

**Required Sections**:
- **PR Type**: Bug fix, feature, docs, refactor, dependency update
- **Purpose**: Problem being solved with issue links
- **Changes Summary**: Detailed description of modifications
- **Testing Instructions**: Step-by-step testing guide
- **Quality Checklist**: Contributing guidelines compliance

## GitHub Prompts System

### AI Agent Prompts

#### 1. Conventional Commits Generator
**File**: `.github/prompts/create-conventional-commits.md`
**Purpose**: Generate properly formatted conventional commits

**Process Flow**:
1. **Repository Analysis**: Check `git status --porcelain`
2. **Change Grouping**: Identify atomic, logical commit groups
3. **Type and Scope Detection**: Based on file locations and changes
4. **Message Generation**: Conventional format with proper scopes
5. **User Approval**: Each commit requires explicit approval
6. **Execution**: Staged commits until working directory clean

**Commit Types and Scopes**:
```bash
feat(core):     # New features in core package
fix(cli):       # Bug fixes in CLI package
docs(www):      # Documentation updates in website
chore(repo):    # Repository maintenance
refactor(adapters): # Code restructuring in adapters
```

#### 2. Pull Request Preparation
**File**: `.github/prompts/prepare-pull-request.md`
**Purpose**: Standardize PR creation with quality gates

**Workflow Steps**:
1. **Branch Hygiene**: Sync with main, verify feature branch
2. **Quality Gates**: Lint, test, build verification
3. **Commit Organization**: Conventional commits with proper scopes
4. **PR Content**: Template-based title and description
5. **Review Readiness**: Complete checklist before creation

#### 3. Blog Post Creation
**File**: `.github/prompts/create-blog-post.md`
**Purpose**: Generate MDX blog posts for website

**Creation Modes**:
- **From Scratch**: Original content with outline
- **From Template**: Release announcements with version details
- **From Documentation**: Transform docs into narrative articles

**Output Structure**:
```
apps/www/src/app/(content)/blog/(posts)/<category>/<slug>/page.mdx
```

#### 4. Bug Report Creation
**File**: `.github/prompts/create-bug-report-issue.md**
**Purpose**: Structured bug report generation

**Information Gathering**:
- Problem context and impact assessment
- Reproduction steps with minimal case
- Environment details and configuration
- Evidence collection (logs, screenshots)
- Severity classification and triage metadata

## Code Review Automation

### Review Severity System
```
🔴 Critical  # Security issues, breaking bugs, data corruption
🟠 High      # Performance issues, logic errors, API problems
🟡 Medium    # Code quality, maintainability, best practices
🟢 Low       # Style issues, minor improvements, suggestions
🔵 Unclear   # Needs more context or investigation
```

### Review Focus Areas

#### Code Quality Criteria (Priority Order)
1. **Correctness**: Logic errors, edge cases, type mismatches
2. **Security**: Vulnerabilities, injection attacks, access control
3. **Performance**: Bottlenecks, memory leaks, optimization opportunities
4. **Maintainability**: Code organization, naming, documentation

#### Review Guidelines
- **Inline Comments**: Preferred for specific code issues
- **Code Suggestions**: Provide exact replacement code when possible
- **Constructive Feedback**: Clear explanations with improvement suggestions
- **Line-Specific**: Only comment on actual diff changes (+ or - lines)

### GitHub MCP Server Integration
```yaml
mcpServers:
  github:
    command: "docker"
    args: ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"]
    includeTools:
      - create_pending_pull_request_review
      - add_comment_to_pending_review
      - submit_pending_pull_request_review
```

## Automation Security and Permissions

### GitHub App Integration
```yaml
# Required permissions:
contents: write        # File modifications
issues: write         # Issue management
pull-requests: write  # PR creation and review
id-token: write       # Authentication
statuses: write       # Status checks
```

### Security Constraints
- **Branch Protection**: Never commit directly to `main` branch
- **Authenticated Actions**: All operations use GitHub App tokens
- **Scope Limitation**: Tools restricted to necessary operations only
- **Audit Trail**: All AI actions logged in workflow runs

### Access Control
```yaml
# User authorization levels:
OWNER         # Full access to all LIA functions
MEMBER        # Team member access to reviews and triage
COLLABORATOR  # Limited access to specific workflows
```

## Repository Labels System

### Label Categories

#### Kind Labels
```
kind/bug           # Bug reports and fixes
kind/feature       # New feature requests and implementations
kind/documentation # Documentation updates and requests
kind/question      # Questions and support requests
kind/enhancement   # Improvements to existing features
```

#### Area Labels
```
area/core          # packages/core changes
area/cli           # packages/cli changes
area/adapters      # packages/adapters changes
area/mcp-server    # packages/mcp-server changes
area/www           # Website and documentation
area/tooling       # Development tools and scripts
area/repo          # Repository-level changes
```

#### Priority Labels
```
priority/low       # Nice to have, low urgency
priority/medium    # Important, moderate timeline
priority/high      # Urgent, high impact
priority/critical  # Blocking, immediate attention
```

#### Status Labels
```
status/needs-triage    # Awaiting initial review
status/waiting-response # Waiting for user feedback
status/blocked         # Blocked by external dependency
status/ready-for-review # Ready for code review
status/work-in-progress # Active development
```

## Workflow Best Practices

### Issue Management
1. **Automatic Triage**: All new issues get automatic label assignment
2. **Template Enforcement**: Use appropriate templates for issue types
3. **Clear Reproduction**: Bug reports must include minimal reproduction steps
4. **Environment Details**: Always include version and configuration info

### Pull Request Process
1. **Feature Branches**: Never work directly on main branch
2. **Conventional Commits**: All commits follow conventional format
3. **Quality Gates**: Lint, test, and build must pass
4. **Template Completion**: Fill out all PR template sections
5. **Review Assignment**: Automatic or manual reviewer assignment

### AI Assistant Usage
1. **Clear Requests**: Use specific, actionable language in @lia requests
2. **Plan Review**: Always review AI-generated plans before approval
3. **Focus Areas**: Specify review focus for targeted feedback
4. **Branch Management**: Let AI handle branch creation and management

## Error Handling and Recovery

### Workflow Failures
- **Automatic Logging**: All failures logged to GitHub Actions
- **User Notification**: Comments posted on failures with log links
- **Timeout Handling**: Reasonable timeouts prevent hung workflows
- **Retry Logic**: Automatic retry for transient failures

### Manual Overrides
```bash
# Manual workflow triggers:
workflow_dispatch:
  inputs:
    issue_number: # Specific issue to process
    pr_number:    # Specific PR to review
```

### Debugging and Monitoring
- **Action Logs**: Detailed logging in GitHub Actions
- **Error Comments**: Automatic error reporting in issues/PRs
- **Telemetry**: Optional telemetry for workflow performance
- **Audit Trail**: Complete history of AI assistant actions

---

*This automation system ensures consistent, high-quality contributions while leveraging AI assistance for improved developer experience and code quality in the Igniter.js framework.*