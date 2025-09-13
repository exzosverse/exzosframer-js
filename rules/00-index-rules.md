# Igniter.js Framework Rules - Master Index

## 📚 Complete Rules Documentation

This index provides a comprehensive overview of all Igniter.js framework rules, organized by category and purpose. Each rule file contains specific guidelines, patterns, and best practices for different aspects of development.

---

## 🎯 Core Framework Rules

### [framework-rules.md](./framework-rules.md)
**Purpose**: General framework guidelines and best practices
**When to read**: Starting any Igniter.js project
**Key topics**:
- Engineering principles (SOLID, DRY, KISS, YAGNI)
- Decision framework and trade-offs
- Quality philosophy and standards
- Workflow rules and patterns

### [01-core-concepts-rules.md](./01-core-concepts-rules.md)
**Purpose**: Fundamental Igniter.js concepts and patterns
**When to read**: Learning the framework or implementing core features
**Key topics**:
- Igniter Builder configuration
- Context management and dependency injection
- Controllers and actions with TSDoc
- Procedures (middleware) patterns
- Routing and validation strategies
- **Updated**: Enhanced TSDoc requirements and inline comments

### [02-advanced-features-rules.md](./02-advanced-features-rules.md)
**Purpose**: Production-grade features for scalable applications
**When to read**: Implementing real-time, caching, or background jobs
**Key topics**:
- Realtime (SSE) and automatic revalidation
- Store (Redis) for caching and pub/sub
- Queues (BullMQ) for background jobs
- OpenAPI documentation generation
- Telemetry and monitoring

### [03-client-side-rules.md](./03-client-side-rules.md)
**Purpose**: Frontend integration and client-side patterns
**When to read**: Building React/Next.js applications with Igniter.js
**Key topics**:
- IgniterProvider configuration
- API client usage (RSC vs Client Components)
- useQuery, useMutation, useRealtime hooks
- Cache management and optimistic updates
- Loading states and error handling

---

## 🤖 AI & Automation Rules

### [04-code-agents-rules.md](./04-code-agents-rules.md)
**Purpose**: AI agent integration and code generation
**When to read**: Working with AI assistants or automating development
**Key topics**:
- AI-friendly architecture principles
- AGENT.md structure and configuration
- Editor-specific rules (Cursor, Windsurf, Claude)
- MCP Server integration
- Prompt engineering for Igniter.js

### [05-autonomous-evolution-rules.md](./05-autonomous-evolution-rules.md) ✨ **NEW**
**Purpose**: Self-improvement and continuous learning framework
**When to read**: Setting up autonomous development systems
**Key topics**:
- Evolution cycle protocol
- Knowledge integrity validation
- Hallucination prevention system
- Performance metrics and analytics
- Risk management and escalation

### [06-memory-management-rules.md](./06-memory-management-rules.md) ✨ **NEW**
**Purpose**: Persistent knowledge and context management
**When to read**: Implementing memory systems for AI agents
**Key topics**:
- Memory types and classification
- Storage and retrieval strategies
- Knowledge graph construction
- Proactive memory management
- Context-aware decision making

---

## 🛠️ Development Workflow Rules

### [ai-workflow-automation.md](./ai-workflow-automation.md)
**Purpose**: Workflow automation with AI agents
**When to read**: Setting up automated development pipelines
**Key topics**:
- Task decomposition patterns
- Multi-agent orchestration
- Quality gates and validation
- Continuous integration workflows
- Decision trees for automation

---

## 📁 Commands Documentation

### [commands/](./commands/)
**Purpose**: CLI command reference and usage patterns
**Structure**:
- `actual-cli-commands.md` - Validated command list
- `01-init-command.md` - Project initialization
- `02-dev-command.md` - Development server
- `03-generate-schema.md` - Client generation
- `04-generate-docs.md` - API documentation
- `05-generate-feature.md` - Feature scaffolding
- `06-generate-controller.md` - Controller generation
- `07-generate-procedure.md` - Procedure creation

---

## 🚀 Quick Start Guide

### For New Projects
1. Read [framework-rules.md](./framework-rules.md) - Understand principles
2. Study [01-core-concepts-rules.md](./01-core-concepts-rules.md) - Learn fundamentals
3. Reference [commands/01-init-command.md](./commands/01-init-command.md) - Initialize project

### For AI Integration
1. Review [04-code-agents-rules.md](./04-code-agents-rules.md) - Configure AI tools
2. Implement [05-autonomous-evolution-rules.md](./05-autonomous-evolution-rules.md) - Enable self-improvement
3. Setup [06-memory-management-rules.md](./06-memory-management-rules.md) - Persistent knowledge

### For Advanced Features
1. Explore [02-advanced-features-rules.md](./02-advanced-features-rules.md) - Production features
2. Apply [03-client-side-rules.md](./03-client-side-rules.md) - Frontend patterns
3. Follow [ai-workflow-automation.md](./ai-workflow-automation.md) - Automation workflows

---

## 📋 Rule Categories

### 🔴 CRITICAL Rules (Never Compromise)
- Type safety enforcement
- Context-first architecture
- Generated file protection
- Security and data safety

### 🟡 IMPORTANT Rules (Strong Preference)
- TSDoc documentation
- Inline comment structure
- Testing requirements
- Performance optimization

### 🟢 RECOMMENDED Rules (Best Practices)
- Code organization
- Naming conventions
- Memory management
- Evolution strategies

---

## 🎯 Rule Priority Matrix

| Scenario | Primary Rules | Secondary Rules | Optional Rules |
|----------|--------------|-----------------|----------------|
| **Starting New Project** | framework-rules, 01-core-concepts | commands/*, 04-code-agents | 05-evolution, 06-memory |
| **Adding Features** | 01-core-concepts, commands/05-generate | 02-advanced-features | 03-client-side |
| **AI Development** | 04-code-agents, 05-evolution | 06-memory, ai-workflow | 02-advanced |
| **Production Deploy** | 02-advanced-features | 03-client-side | 05-evolution |
| **Debugging** | 01-core-concepts | 06-memory | 04-code-agents |

---

## 📚 Learning Path

### Beginner
1. **Week 1**: framework-rules → 01-core-concepts
2. **Week 2**: commands/* → Basic features
3. **Week 3**: 03-client-side → Simple app

### Intermediate
1. **Month 1**: 02-advanced-features → Production features
2. **Month 2**: 04-code-agents → AI integration
3. **Month 3**: ai-workflow-automation → Automation

### Advanced
1. **Quarter 1**: 05-autonomous-evolution → Self-improving systems
2. **Quarter 2**: 06-memory-management → Knowledge systems
3. **Quarter 3**: Full integration → Autonomous development

---

## 🔄 Version History

### Latest Updates
- **v2.0.0**: Added autonomous evolution and memory management rules
- **v1.5.0**: Enhanced TSDoc requirements in core concepts
- **v1.0.0**: Initial comprehensive rule system

### Upcoming
- Performance optimization rules
- Security best practices
- Deployment strategies
- Monitoring and observability

---

## 📞 Support & Contribution

### Getting Help
- Review relevant rule files for your use case
- Check command documentation for CLI usage
- Reference anti-patterns in each rule file

### Contributing
- Follow the established rule structure
- Include examples (✅ CORRECT / ❌ WRONG)
- Add to appropriate category
- Update this index

---

**Remember**: These rules are living documents that evolve with the framework. Always prioritize type safety, follow established patterns, and maintain code quality throughout your Igniter.js development journey.