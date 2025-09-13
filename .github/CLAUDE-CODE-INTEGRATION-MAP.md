# 🗺️ Claude Code Integration Map

## Status da Integração

### ✅ Workflows COM Claude Code (6)
1. `claude.yml` - Base Claude Code
2. `claude-code-review.yml` - Review automático
3. `claude-code-config.yml` - Configuração LIA
4. `claude-code-lia-integrated.yml` - **INTEGRAÇÃO COMPLETA**
5. `claude-enhanced.yml` - **TODOS OS COMANDOS**
6. `lia-claude-unified.yml` - Processamento unificado

### 🔄 Workflows Originais LIA (7) - Funcionalidades Acessíveis via Claude Code

| Workflow Original | Como Acessar via Claude Code | Comando |
|-------------------|------------------------------|---------|
| `lia-automated-maintenance.yml` | `@claude-lia /maintenance` | Via `claude-enhanced.yml` |
| `lia-cli.yml` | `@claude-lia /cli` | Via `claude-enhanced.yml` |
| `lia-code-generation.yml` | `@claude-lia /generate [type] [name]` | Via `claude-enhanced.yml` |
| `lia-issue-automated-triage.yml` | `@claude-lia /triage` | Via `claude-enhanced.yml` |
| `lia-issue-scheduled-triage.yml` | `@claude-lia /schedule` | Via `claude-enhanced.yml` |
| `lia-pr-review.yml` | `@claude-code /review` | Via `claude-enhanced.yml` |

## 🎯 Como Usar TUDO via Claude Code

### Método 1: Via `claude-enhanced.yml` (RECOMENDADO)
Este workflow integra TODAS as funcionalidades:

```markdown
# Personalidades
@claude         # Claude padrão
@claude-lia     # LIA completa
@claude-code    # Revisão de código

# Comandos (funcionam com qualquer personalidade)
/triage         # Triagem de issues
/review         # Revisão de código
/generate       # Geração de código
/maintenance    # Manutenção
/cli           # Interface CLI
/schedule      # Agendar tarefas
/test          # Executar testes
/build         # Build do projeto
/deploy        # Deploy
/docs          # Documentação
```

### Método 2: Via `claude-code-lia-integrated.yml`
Este workflow também integra as funcionalidades principais:

```markdown
@claude-lia     # Ativa modo LIA
@claude-code    # Ativa modo revisão

# Comandos principais
/triage
/review
/generate [type] [name]
/maintenance
/cli
/schedule
```

## 📊 Matriz de Cobertura

| Funcionalidade | Claude Enhanced | Claude LIA Integrated | Workflow Original |
|----------------|----------------|----------------------|-------------------|
| Triagem de Issues | ✅ `/triage` | ✅ `/triage` | ✅ Automático |
| Revisão de PRs | ✅ `/review` | ✅ `/review` | ✅ Automático |
| Geração de Código | ✅ `/generate` | ✅ `/generate` | ✅ `/generate` |
| Manutenção | ✅ `/maintenance` | ✅ `/maintenance` | ✅ Cron daily |
| CLI Interativo | ✅ `/cli` | ✅ `/cli` | ✅ `/lia` |
| Agendamento | ✅ `/schedule` | ✅ `/schedule` | ✅ Cron |
| Testes | ✅ `/test` | ❌ | ❌ |
| Build | ✅ `/build` | ❌ | ❌ |
| Deploy | ✅ `/deploy` | ❌ | ❌ |
| Docs | ✅ `/docs` | ❌ | ❌ |

## 🚀 Exemplos de Uso Completo

### Desenvolvimento Completo de Feature
```markdown
@claude-lia Preciso criar uma feature de autenticação

/generate feature auth
/generate controller auth
/generate test auth
/test auth
/build
/docs update
```

### Manutenção e Review
```markdown
@claude-lia /maintenance
@claude-code /review
@claude /triage
```

### Agendamento de Tarefas
```markdown
@claude-lia /schedule dependency-update weekly
@claude-lia /schedule security-scan daily
```

## ✅ Conclusão

**TODAS as funcionalidades dos 13 workflows são acessíveis via Claude Code!**

- **6 workflows** têm integração direta com Claude Code
- **7 workflows** LIA têm suas funcionalidades acessíveis via comandos em `claude-enhanced.yml`
- **100% de cobertura** funcional através dos comandos slash

### Workflow Principal Recomendado
Use `claude-enhanced.yml` que é acionado por:
- `@claude`
- `@claude-lia`
- `@claude-code`
- Qualquer comando `/`

Este workflow único pode executar TODAS as funcionalidades dos 13 workflows!

---

*ExzosFramer.js - Fully Integrated with Claude Code*