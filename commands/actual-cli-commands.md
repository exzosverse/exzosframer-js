# Igniter.js CLI - Comandos Reais Validados

## ✅ Comandos Implementados no CLI

### 🚀 `igniter init`
**Descrição**: Criar novo projeto Igniter.js com setup interativo
**Uso**: `igniter init [project-name]`
**Opções**:
- `--force`: Pular confirmações e sobrescrever arquivos
- `--pm, --package-manager <manager>`: npm, yarn, pnpm, bun
- `--template <template>`: starter-nextjs, starter-express-rest-api
- `-f, --framework <framework>`: nextjs, vite, nuxt, sveltekit, remix, astro, express
- `--features <features>`: store,jobs,mcp,logging,telemetry
- `--database <database>`: none, postgresql, mysql, sqlite
- `--orm <orm>`: prisma, drizzle
- `--no-git`: Pular inicialização do git
- `--no-install`: Pular instalação de dependências
- `--no-docker`: Pular setup do Docker Compose

### 🔧 `igniter dev`
**Descrição**: Iniciar modo desenvolvimento com dashboard interativo
**Uso**: `igniter dev`
**Opções**:
- `--framework <type>`: nextjs, vite, nuxt, sveltekit, remix, astro, express, tanstack-start, generic
- `--output <dir>`: Diretório de saída (padrão: "src/")
- `--port <number>`: Porta do servidor (padrão: 3000)
- `--cmd <command>`: Comando customizado para iniciar servidor
- `--no-framework`: Desabilitar servidor do framework (apenas Igniter)
- `--no-interactive`: Usar modo concorrente ao invés de interativo
- `--docs-output <dir>`: Diretório para docs OpenAPI (padrão: "./src/docs")

**Funcionalidades**:
- Kill automático de processos na porta antes de iniciar
- Dashboard interativo com status de processos
- Geração automática de schema e docs

### 📝 `igniter generate`
Comando pai para subcomandos de geração

#### `igniter generate schema`
**Descrição**: Gerar schema do cliente a partir do router
**Uso**: `igniter generate schema`
**Opções**:
- `--framework <type>`: Tipo do framework
- `--output <dir>`: Diretório de saída (padrão: "src/")
- `--watch`: Watch mode para regeneração automática
- `--docs`: Habilitar geração de documentação OpenAPI
- `--docs-output <dir>`: Diretório para docs (padrão: "./src/docs")

#### `igniter generate docs`
**Descrição**: Gerar especificação OpenAPI
**Uso**: `igniter generate docs`
**Opções**:
- `--output <dir>`: Diretório de saída (padrão: "./src")
- `--ui`: Gerar HTML com Scalar UI

#### `igniter generate feature`
**Descrição**: Scaffolding de feature completa
**Uso**: `igniter generate feature <name>`
**Opções**:
- `--schema <source>`: prisma:Model, zod, json
- `--crud`: Incluir operações CRUD completas
- `--realtime`: Adicionar suporte SSE
- `--tests`: Gerar testes

**Cria estrutura**:
```
src/features/<name>/
├── controllers/<name>.controller.ts
├── procedures/repository.procedure.ts
├── schemas/<name>.schema.ts
├── __tests__/<name>.test.ts
├── index.ts
├── AGENT.md
└── DOCS.md
```

#### `igniter generate controller`
**Descrição**: Criar novo controller
**Uso**: `igniter generate controller <name>`
**Opções**:
- `--path <path>`: Caminho do controller
- `--actions <actions>`: list,get,create,update,delete
- `--realtime`: Adicionar suporte streaming

#### `igniter generate procedure`
**Descrição**: Criar procedure (middleware)
**Uso**: `igniter generate procedure <name>`
**Opções**:
- `--type <type>`: auth, cache, validate, rate-limit
- `--path <path>`: Caminho do procedure

### 🛠️ Opções Globais
- `--debug`: Habilitar logging detalhado
- `--version`: Mostrar versão
- `--help`: Mostrar ajuda

## 📦 Comandos via package.json (npm scripts)

No monorepo raiz:
```bash
npm run build         # Build de todos os packages
npm run dev          # Modo desenvolvimento
npm run test         # Rodar testes
npm run test:watch   # Testes em watch mode
npm run lint         # Verificar linting
npm run lint:fix     # Corrigir linting
npm run clean        # Limpar build artifacts
npm run format       # Formatar código
npm run typecheck    # Verificar tipos
npm run changeset    # Gerenciar versões
npm run release      # Publicar packages
```

## 🔍 Locais dos Arquivos Gerados

### Cliente TypeScript
- **Arquivo**: `src/igniter.client.ts`
- **Auto-gerado**: Nunca editar manualmente
- **Regeneração**: Automática em dev mode ou via `generate schema`

### Schema de Tipos
- **Arquivo**: `src/igniter.schema.ts`
- **Conteúdo**: Tipos TypeScript extraídos do router

### Documentação OpenAPI
- **Arquivo**: `src/docs/openapi.json`
- **UI**: `src/docs/index.html` (com --ui)
- **Playground**: Disponível em `/api/docs` no dev mode

### Router Principal
- **Arquivo**: `src/igniter.router.ts`
- **Função**: Registrar todos os controllers

### Configuração Igniter
- **Arquivo**: `src/igniter.ts`
- **Conteúdo**: Builder com adapters e configurações

## ⚠️ Comandos NÃO Implementados (Futuros)

Os seguintes comandos foram propostos mas ainda não existem:
- `igniter analyze` - Análise de código
- `igniter task` - Gerenciamento de tarefas
- `igniter delegate` - Delegação para AI
- `igniter memory` - Sistema de memória
- `igniter workflow` - Automação de workflows
- `igniter realtime` - Monitoramento SSE
- `igniter doctor` - Diagnóstico de problemas
- `igniter migrate` - Migrações de banco

## 🚨 Detecção de Framework

O CLI detecta automaticamente:
- Next.js
- Vite
- Nuxt
- SvelteKit
- Remix
- Astro
- Express
- TanStack Start

Fallback para "generic" se não detectado.

## 💡 Exemplos de Uso

```bash
# Criar novo projeto Next.js com todas as features
igniter init my-app --framework nextjs --features store,jobs,telemetry --database postgresql

# Desenvolvimento com dashboard interativo
igniter dev

# Gerar feature CRUD completa a partir do Prisma
igniter generate feature products --schema prisma:Product --crud --tests

# Gerar docs com UI interativa
igniter generate docs --ui

# Build para produção
npm run build

# Rodar testes específicos
npm test -- --filter @igniter-js/core
```

## 🔗 Integração com Ferramentas AI

O CLI é otimizado para uso com agentes AI:
- Estrutura consistente de arquivos
- AGENT.md em cada feature
- Documentação auto-gerada
- Tipos end-to-end
- Padrões previsíveis

---

**Nota**: Este documento reflete os comandos REALMENTE implementados no CLI v0.2.64, baseado na análise do código fonte em `packages/cli/src/index.ts`.