# MCP Server Integration Rules - Igniter.js Framework

## 🤖 MCP Server Architecture Principles

### Core MCP Principles
- **Modular toolsets** - Organized by functional domains
- **Memory-first design** - Persistent cross-session knowledge
- **Agent delegation** - Autonomous task execution capabilities
- **Type-safe validation** - Zod schemas for all tool inputs
- **CLI-native integration** - Direct Igniter.js command access

## 📦 MCP Server Setup

### Installation and Configuration
```bash
# ✅ CORRECT: Install MCP server package
npm install @igniter-js/mcp-server

# Global binary installation
npm install -g @igniter-js/mcp-server

# Or use with npx
npx @igniter-js/mcp-server
```

### Environment Setup
```bash
# .env configuration
GITHUB_TOKEN=your_github_token_here

# Claude Desktop configuration
# ~/.config/claude-desktop/claude_desktop_config.json
{
  "mcpServers": {
    "igniter-mcp-server": {
      "command": "igniter-mcp",
      "args": [],
      "env": {
        "GITHUB_TOKEN": "your_token_here"
      }
    }
  }
}
```

## 🧠 Memory Management Toolset

### Memory Operations
```typescript
/**
 * @toolset Memory Management
 * @description Persistent knowledge storage with MDX format
 */

// Store knowledge with rich metadata
await mcp.store_memory({
  title: "Authentication Pattern",
  content: `# JWT Authentication Implementation

  ## Overview
  Implemented JWT-based authentication with refresh tokens.

  ## Key Components
  - AuthProvider context
  - Token refresh logic
  - Protected route wrapper

  ## Code Example
  \`\`\`typescript
  const useAuth = () => {
    const { token, refreshToken } = useContext(AuthContext);
    // Implementation details...
  };
  \`\`\``,

  type: "code_pattern",
  tags: ["authentication", "jwt", "react"],
  confidence: 0.9,
  source: "implementation",
  metadata: {
    component: "AuthProvider",
    file: "src/contexts/AuthContext.tsx"
  }
});

// Search memories with filters
const patterns = await mcp.search_memories({
  query: "authentication jwt",
  types: ["code_pattern", "architectural_decision"],
  tags: ["react"],
  limit: 10
});

// Create relationships between memories
await mcp.relate_memories({
  sourceId: "auth-pattern-123",
  targetId: "user-management-456",
  relationship: "implements",
  strength: 0.8
});
```

### Memory Types and Categories
```typescript
/**
 * @description Standardized memory classification
 */
enum MemoryType {
  ARCHITECTURAL_DECISION = "architectural_decision",
  CODE_PATTERN = "code_pattern",
  BUG_REPORT = "bug_report",
  TASK = "task",
  FEATURE_SPEC = "feature_spec",
  PERFORMANCE_INSIGHT = "performance_insight",
  SECURITY_ISSUE = "security_issue",
  USER_PREFERENCE = "user_preference",
  LESSON_LEARNED = "lesson_learned",
  DEBUGGING_SESSION = "debugging_session",
  API_MAPPING = "api_mapping",
  REFACTOR_NOTES = "refactor_notes",
  TESTING_STRATEGY = "testing_strategy",
  DEPLOYMENT_CONFIG = "deployment_config"
}
```

## 🔄 Agent Delegation System

### Autonomous Task Execution
```typescript
/**
 * @toolset Agent Delegation
 * @description YOLO mode autonomous development
 */

// Delegate complex tasks to specialized agents
const delegation = await mcp.delegate_to_agent({
  task_id: "implement-authentication",
  agent_type: "gemini", // gemini, claude-code, openai-codex

  execution_config: {
    yolo_mode: true,          // Full autonomous execution
    sandbox_enabled: true,    // Sandboxed environment
    timeout_minutes: 30,      // Max execution time
    allow_file_creation: true,
    allow_package_installation: true
  },

  context: {
    instructions: `Implement JWT authentication system with:
    - Login/logout functionality
    - Token refresh mechanism
    - Protected route wrapper
    - User context management`,

    constraints: [
      "Use React Context API",
      "Follow existing code patterns",
      "Add comprehensive error handling",
      "Include TypeScript types"
    ],

    working_directory: "src/auth/",
    related_files: [
      "src/types/user.ts",
      "src/api/auth.ts"
    ]
  },

  monitoring: {
    progress_updates: true,
    milestone_reporting: true,
    error_escalation: true
  }
});

// Monitor delegation progress
const status = await mcp.check_delegation_status({
  delegation_id: delegation.id
});

// List all active delegations
const active = await mcp.list_active_delegations({
  agent_type: "gemini",
  status: "running"
});
```

### Agent Environment Management
```typescript
/**
 * @description Agent environment setup and validation
 */
// Check agent environment
const envCheck = await mcp.check_agent_environment({
  agent_type: "gemini",
  requirements: [
    "node_version >= 18",
    "git_available",
    "package_manager_available"
  ]
});

// Setup agent environment
await mcp.setup_agent_environment({
  agent_type: "gemini",
  install_dependencies: true,
  configure_workspace: true,
  validate_setup: true
});
```

## 📋 Task Management System

### Task Lifecycle Management
```typescript
/**
 * @toolset Task Management
 * @description Complete CRUD operations for development tasks
 */

// Create structured tasks
await mcp.create_task({
  title: "Implement user authentication",
  description: "Add JWT-based authentication system",

  feature: "auth",
  priority: "high", // low, medium, high, critical
  status: "todo",   // todo, in_progress, blocked, testing, done, cancelled

  metadata: {
    estimated_hours: 8,
    complexity: "medium",
    category: "backend"
  },

  dependencies: [
    "setup-database-schema",
    "configure-jwt-library"
  ],

  subtasks: [
    "Create user model",
    "Implement login endpoint",
    "Add token validation middleware",
    "Create logout functionality"
  ],

  delegation_config: {
    suitable_for_delegation: true,
    preferred_agent: "gemini",
    delegation_instructions: "Follow REST API patterns"
  }
});

// Advanced task filtering
const tasks = await mcp.list_tasks({
  feature: "auth",
  status: ["todo", "in_progress"],
  priority: ["high", "critical"],
  assignee: "gemini-agent",
  has_dependencies: false
});

// Task statistics and insights
const stats = await mcp.get_task_statistics({
  group_by: "feature",
  include_delegation_insights: true,
  time_range: "last_30_days"
});
```

## ⚙️ CLI Integration Toolset

### Development Lifecycle Management
```typescript
/**
 * @toolset CLI Integration
 * @description Native Igniter.js CLI access
 */

// Start development server
await mcp.start_dev_server({
  port: 3000,
  hot_reload: true,
  open_browser: false
});

// Generate complete features
await mcp.generate_feature({
  name: "users",
  schema_source: "prisma:User", // prisma:Model or zod:Schema
  include_crud: true,
  include_tests: true,

  options: {
    auth_required: true,
    cache_enabled: true,
    validation_strict: true
  }
});

// Generate API documentation
await mcp.generate_docs({
  output_format: "openapi",
  include_ui: true,
  export_path: "./docs/api.json"
});

// Package management with auto-detection
await mcp.add_package_dependency({
  package: "@types/jsonwebtoken",
  version: "latest",
  dev_dependency: true
});
```

## 🔍 Code Investigation Tools

### Source Code Analysis
```typescript
/**
 * @toolset Code Investigation
 * @description Deep source analysis and dependency tracing
 */

// Find symbol implementations across codebase
const implementation = await mcp.find_implementation({
  symbol: "authenticateUser",
  search_scope: "project", // file, feature, project

  filters: {
    file_types: [".ts", ".tsx"],
    exclude_patterns: ["node_modules", "dist"],
    include_dependencies: true
  }
});

// Explore file structure and dependencies
const analysis = await mcp.explore_source({
  file_path: "src/auth/AuthProvider.tsx",

  analysis_depth: "deep", // surface, medium, deep
  include_ast: true,
  include_dependencies: true,
  include_exports: true
});

// Trace complete dependency chains
const dependencyChain = await mcp.trace_dependency_chain({
  start_file: "src/auth/index.ts",
  max_depth: 5,
  detect_cycles: true,
  include_external: false
});
```

## 🐙 GitHub Integration

### Repository Automation
```typescript
/**
 * @toolset GitHub Integration
 * @description Repository interaction and issue management
 */

// Search issues with advanced filters
const issues = await mcp.search_github_issues({
  repo: "owner/repository",
  state: "open",
  labels: ["bug", "authentication"],
  assignee: "developer",
  sort: "updated",
  limit: 20
});

// Create issues from tasks
await mcp.create_github_issue({
  repo: "owner/repository",
  title: "Implement JWT authentication",
  body: `## Description
  Add JWT-based authentication system

  ## Tasks
  - [ ] Create user model
  - [ ] Implement login endpoint
  - [ ] Add middleware

  ## Acceptance Criteria
  - Users can login/logout
  - Tokens expire appropriately
  - Protected routes work`,

  labels: ["enhancement", "auth"],
  assignees: ["developer"]
});

// Search code patterns across repositories
const codeResults = await mcp.search_github_code({
  query: "useAuth jwt authentication",
  language: "typescript",
  filename: "*.tsx"
});
```

## 🔧 File Analysis Engine

### Static Analysis and Health Assessment
```typescript
/**
 * @toolset File Analysis
 * @description TypeScript-aware file analysis
 */

// Analyze individual files
const fileAnalysis = await mcp.analyze_file({
  file_path: "src/auth/AuthProvider.tsx",

  analysis_options: {
    check_typescript_errors: true,
    extract_exports: true,
    identify_patterns: true,
    calculate_complexity: true
  }
});

// Comprehensive feature analysis
const featureHealth = await mcp.analyze_feature({
  feature_name: "auth",

  health_checks: {
    code_coverage: true,
    test_completeness: true,
    documentation_status: true,
    dependency_health: true
  }
});
```

## 🔌 API Validation Workflow

### Testing and Documentation
```typescript
/**
 * @toolset API Validation
 * @description OpenAPI and HTTP testing capabilities
 */

// Get OpenAPI specification
const spec = await mcp.get_openapi_spec({
  base_url: "http://localhost:3000",
  spec_path: "/api/v1/docs/openapi.json"
});

// Test API endpoints
const response = await mcp.make_api_request({
  method: "POST",
  url: "http://localhost:3000/api/v1/auth/login",
  headers: {
    "Content-Type": "application/json"
  },
  body: {
    email: "test@example.com",
    password: "password"
  },
  timeout: 5000
});
```

## 🚨 MCP Integration Anti-Patterns

### ❌ Memory Pollution
```typescript
// WRONG: Storing temporary or low-value information
await mcp.store_memory({
  title: "Random debug log",
  content: "console.log was added here",
  type: "code_pattern" // Not actually a pattern!
});

// CORRECT: Store meaningful patterns
await mcp.store_memory({
  title: "Error Handling Pattern",
  content: "Comprehensive error boundary implementation",
  type: "code_pattern",
  confidence: 0.8
});
```

### ❌ Delegation Abuse
```typescript
// WRONG: Delegating simple tasks
await mcp.delegate_to_agent({
  task_id: "fix-typo",
  instructions: "Fix spelling error in comment"
});

// CORRECT: Delegate complex implementations
await mcp.delegate_to_agent({
  task_id: "implement-complex-feature",
  instructions: "Implement complete authentication system"
});
```

### ❌ Task Fragmentation
```typescript
// WRONG: Overly granular tasks
await mcp.create_task({ title: "Add import statement" });
await mcp.create_task({ title: "Define interface" });
await mcp.create_task({ title: "Export function" });

// CORRECT: Meaningful task units
await mcp.create_task({
  title: "Implement user authentication module",
  subtasks: ["Add imports", "Define interfaces", "Export functions"]
});
```

## 📋 MCP Server Checklist

### Setup
- [ ] Install @igniter-js/mcp-server package
- [ ] Configure Claude Desktop integration
- [ ] Set up GitHub token environment variable
- [ ] Initialize memory management system

### Memory Management
- [ ] Store architectural decisions
- [ ] Create code pattern memories
- [ ] Establish memory relationships
- [ ] Regular reflection and cleanup

### Agent Delegation
- [ ] Configure agent environments
- [ ] Set up delegation monitoring
- [ ] Define task suitability criteria
- [ ] Implement progress tracking

### Task Management
- [ ] Create structured task hierarchy
- [ ] Set up dependency management
- [ ] Configure delegation workflows
- [ ] Monitor task statistics

### Integration
- [ ] Connect with CLI tools
- [ ] Set up GitHub automation
- [ ] Configure API validation
- [ ] Enable code investigation

---

**Remember**: The MCP server enables sophisticated AI agent interactions with Igniter.js projects. Use it to build persistent knowledge, automate complex workflows, and delegate development tasks while maintaining type safety and organized toolset architecture.