# TanStack Start Integration Rules - Igniter.js Framework

## 🚀 TanStack Start Full-Stack Patterns

### Core TanStack Start Principles
- **File-based routing** - Intuitive route organization with TanStack Router
- **Type-safe routing** - Full TypeScript integration from routes to API
- **Server-side fetching** - Leverage loaders for SSR data fetching
- **Vite-powered** - Lightning-fast HMR and build performance
- **Unified architecture** - Seamless frontend-backend integration

## 🏗️ Architecture Overview

### Catch-All API Integration
```typescript
/**
 * @file src/routes/api/v1/$.ts
 * @description Single entry point for all API requests
 */
import { createFileRoute } from '@tanstack/react-router';
import { AppRouter } from '@/igniter.router';

export const Route = createFileRoute('/api/v1/$')({
  // GET requests via loader
  loader: async ({ request }) => {
    return await AppRouter.handler(request);
  },

  // POST/PUT/DELETE via action
  action: async ({ request }) => {
    return await AppRouter.handler(request);
  },
});

// ✅ CORRECT: Direct request delegation to Igniter.js
// ❌ WRONG: Implementing API logic in route files
```

### File-Based Routing Structure
```
src/routes/
├── __root.tsx          # Root layout with providers
├── index.tsx           # Home page (/)
├── about.tsx          # About page (/about)
├── products/
│   ├── index.tsx      # Products list (/products)
│   └── $id.tsx        # Product detail (/products/:id)
└── api/
    └── v1/
        └── $.ts       # API catch-all handler
```

## 🎯 Router Configuration

### TanStack Router Setup
```typescript
// src/router.tsx
import { createRouter } from '@tanstack/react-router';
import { routeTree } from './routeTree.gen';

export const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  defaultStaleTime: 0,

  // Context for all routes
  context: {
    queryClient,
    auth: undefined!,
  },
});

// Type registration
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
```

### Root Layout with Providers
```typescript
// src/routes/__root.tsx
import { createRootRouteWithContext } from '@tanstack/react-router';
import { IgniterProvider } from '@/providers/igniter.provider';
import { TanStackRouterDevtools } from '@tanstack/router-devtools';

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
});

function RootComponent() {
  return (
    <IgniterProvider>
      <Outlet />
      {process.env.NODE_ENV === 'development' && (
        <TanStackRouterDevtools />
      )}
    </IgniterProvider>
  );
}
```

## 📡 Server-Side Data Fetching

### Route Loaders with Igniter.js
```typescript
/**
 * @description Server-side data fetching with loaders
 * @file src/routes/products/index.tsx
 */
import { createFileRoute } from '@tanstack/react-router';
import { api } from '@/igniter.client';

export const Route = createFileRoute('/products/')({
  // Server-side data fetching
  loader: async ({ context }) => {
    // Direct API call on server (no HTTP)
    const products = await api.products.list.query();
    return { products };
  },

  // Client component receives loaded data
  component: ProductsPage,
});

function ProductsPage() {
  const { products } = Route.useLoaderData();

  return (
    <div>
      {products.map(product => (
        <ProductCard key={product.id} {...product} />
      ))}
    </div>
  );
}
```

### Dynamic Route Parameters
```typescript
/**
 * @description Dynamic routes with params
 * @file src/routes/products/$id.tsx
 */
export const Route = createFileRoute('/products/$id')({
  // Parse and validate params
  parseParams: (params) => ({
    id: z.string().parse(params.id),
  }),

  // Load data based on params
  loader: async ({ params }) => {
    const product = await api.products.get.query({ id: params.id });
    if (!product) throw new NotFoundError();
    return { product };
  },

  // Error boundary for this route
  errorComponent: ProductErrorComponent,

  component: ProductDetailPage,
});
```

## 🎭 Client-Side Patterns

### Search Params Management
```typescript
/**
 * @description Type-safe search params
 */
import { z } from 'zod';

const searchSchema = z.object({
  q: z.string().optional(),
  page: z.number().default(1),
  sort: z.enum(['name', 'price']).default('name'),
});

export const Route = createFileRoute('/products/')({
  validateSearch: searchSchema,

  loader: async ({ context, search }) => {
    const products = await api.products.list.query({
      query: search.q,
      page: search.page,
      sort: search.sort,
    });
    return { products };
  },

  component: function ProductsPage() {
    const navigate = Route.useNavigate();
    const search = Route.useSearch();

    const updateSearch = (updates: Partial<typeof search>) => {
      navigate({
        search: (prev) => ({ ...prev, ...updates }),
      });
    };

    return (
      <div>
        <SearchBar
          value={search.q}
          onChange={(q) => updateSearch({ q })}
        />
        {/* ... */}
      </div>
    );
  },
});
```

### Optimistic Updates
```typescript
/**
 * @description Optimistic UI updates with mutations
 */
function ProductForm() {
  const navigate = Route.useNavigate();
  const utils = api.useUtils();

  const createMutation = api.products.create.useMutation({
    onMutate: async (newProduct) => {
      // Cancel outgoing refetches
      await utils.products.list.cancel();

      // Snapshot previous value
      const previousProducts = utils.products.list.getData();

      // Optimistically update
      utils.products.list.setData(undefined, (old) => [
        ...old,
        { ...newProduct, id: 'temp-' + Date.now() },
      ]);

      return { previousProducts };
    },

    onError: (err, newProduct, context) => {
      // Rollback on error
      utils.products.list.setData(undefined, context.previousProducts);
    },

    onSuccess: (data) => {
      // Navigate to new product
      navigate({ to: '/products/$id', params: { id: data.id } });
    },

    onSettled: () => {
      // Always refetch after mutation
      utils.products.list.invalidate();
    },
  });

  return (
    <form onSubmit={handleSubmit(createMutation.mutate)}>
      {/* Form fields */}
    </form>
  );
}
```

## 🔧 Development Workflow

### Feature Scaffolding with CLI
```bash
# 1. Define schema in Prisma
# prisma/schema.prisma
model Product {
  id    String @id @default(cuid())
  name  String
  price Float
}

# 2. Apply to database
npx prisma db push

# 3. Scaffold feature with Igniter CLI
npx @igniter-js/cli generate feature products --schema prisma:Product

# 4. Register controller in router
# src/igniter.router.ts
import { productsController } from '@/features/products';

export const AppRouter = igniter.router({
  controllers: {
    products: productsController,
  }
});

# 5. Create route files for UI
# src/routes/products/index.tsx - List page
# src/routes/products/$id.tsx - Detail page
# src/routes/products/new.tsx - Create form
```

### Development Server
```bash
# Start dev server with HMR
npm run dev

# Vite dashboard shows:
# - Frontend: http://localhost:5173
# - API: http://localhost:5173/api/v1
# - Igniter Studio: http://localhost:5173/api/v1/docs
```

## 🎨 Component Patterns

### Layout Routes
```typescript
/**
 * @description Nested layouts with TanStack Router
 * @file src/routes/_dashboard.tsx
 */
export const Route = createFileRoute('/_dashboard')({
  beforeLoad: async ({ context }) => {
    // Authentication check
    const auth = await context.auth.getSession();
    if (!auth) throw redirect({ to: '/login' });
    return { auth };
  },

  component: DashboardLayout,
});

function DashboardLayout() {
  const { auth } = Route.useRouteContext();

  return (
    <div className="dashboard">
      <Sidebar user={auth.user} />
      <main>
        <Outlet /> {/* Child routes render here */}
      </main>
    </div>
  );
}

// Child route inherits layout
// src/routes/_dashboard/products.tsx
export const Route = createFileRoute('/_dashboard/products')({
  component: ProductsPage,
});
```

### Pending UI States
```typescript
/**
 * @description Loading states with TanStack Router
 */
export const Route = createFileRoute('/products/')({
  pendingComponent: ProductsSkeleton,
  errorComponent: ProductsError,

  loader: async () => {
    // Slow query
    await new Promise(r => setTimeout(r, 1000));
    return api.products.list.query();
  },

  component: ProductsPage,
});

function ProductsSkeleton() {
  return (
    <div className="animate-pulse">
      {[...Array(5)].map((_, i) => (
        <div key={i} className="h-20 bg-gray-200 rounded mb-4" />
      ))}
    </div>
  );
}
```

## 🚀 Production Build

### Build Configuration
```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import { tanstackStartVite } from '@tanstack/start/vite';
import tsConfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [
    tanstackStartVite(),
    tsConfigPaths(),
  ],

  build: {
    target: 'esnext',
    minify: 'esbuild',
    sourcemap: true,
  },

  ssr: {
    noExternal: ['@igniter-js/core'],
  },
});
```

### Production Deployment
```bash
# Build for production
npm run build

# Output structure
.output/
├── server/
│   └── index.mjs      # Server entry point
└── client/
    └── assets/        # Static assets

# Start production server
npm run start
```

## 🎯 AI Agent Patterns (Lia)

### Spec-Driven Development Workflow
```typescript
/**
 * @description AI agent workflow for feature development
 */

// 1. Requirements Gathering
// .github/specs/{feature_name}/requirements.md
interface RequirementsDoc {
  introduction: string;
  requirements: Array<{
    userStory: string;
    acceptanceCriteria: string[];
  }>;
}

// 2. Design Document
// .github/specs/{feature_name}/design.md
interface DesignDoc {
  overview: string;
  architecture: string;
  components: ComponentInterface[];
  dataModels: DataModel[];
  errorHandling: ErrorStrategy;
  testingStrategy: TestPlan;
}

// 3. Task List
// .github/specs/{feature_name}/tasks.md
interface TaskList {
  tasks: Array<{
    id: string;
    description: string;
    requirements: string[];
    dependencies: string[];
  }>;
}
```

### Autonomous Testing Pattern
```typescript
/**
 * @description Lia's autonomous endpoint testing
 */
async function testNewFeature(feature: string) {
  // 1. Locate OpenAPI spec
  const openApiPath = await readConfig('src/igniter.ts', 'docs.openapi');
  const spec = await readJson(openApiPath);

  // 2. Extract new endpoints
  const endpoints = extractEndpoints(spec, feature);

  // 3. Execute curl tests
  for (const endpoint of endpoints) {
    const result = await execCurl(endpoint);
    console.log(`✅ ${endpoint.method} ${endpoint.path}: ${result.status}`);
  }

  // 4. Generate documentation
  await createDocs(`src/features/${feature}/DOCS.md`, {
    endpoints,
    testResults,
  });
}
```

## 🚨 TanStack Start Anti-Patterns

### ❌ API Logic in Route Files
```typescript
// WRONG: Business logic in route file
export const Route = createFileRoute('/api/products')({
  loader: async () => {
    // Don't implement API logic here
    const products = await database.product.findMany();
    return products;
  },
});

// CORRECT: Delegate to Igniter.js
export const Route = createFileRoute('/api/v1/$')({
  loader: async ({ request }) => {
    return await AppRouter.handler(request);
  },
});
```

### ❌ Manual Type Definitions
```typescript
// WRONG: Manually defining API types
interface Product {
  id: string;
  name: string;
}

// CORRECT: Use auto-generated types
import { api } from '@/igniter.client';
type Product = Awaited<ReturnType<typeof api.products.get.query>>;
```

### ❌ Client-Side Data Fetching in SSR
```typescript
// WRONG: useQuery in loader
export const Route = createFileRoute('/products/')({
  loader: async () => {
    // This won't work on server
    const { data } = api.products.list.useQuery();
    return data;
  },
});

// CORRECT: Direct API call in loader
export const Route = createFileRoute('/products/')({
  loader: async () => {
    return await api.products.list.query();
  },
});
```

## 📋 TanStack Start Checklist

### Setup
- [ ] Configure TanStack Router with file-based routing
- [ ] Set up API catch-all route at `/api/v1/$`
- [ ] Configure IgniterProvider in root layout
- [ ] Set up route context with auth and queryClient

### Development
- [ ] Use loaders for server-side data fetching
- [ ] Implement search params with validation
- [ ] Add pending and error components
- [ ] Use optimistic updates for mutations

### Testing
- [ ] Test route loaders with different params
- [ ] Verify error boundaries work correctly
- [ ] Test navigation and search param updates
- [ ] Validate SSR data fetching

### Production
- [ ] Configure Vite for production build
- [ ] Optimize bundle splitting
- [ ] Set up proper error logging
- [ ] Configure CDN for static assets

---

**Remember**: TanStack Start combines the best of modern web development - file-based routing, server-side rendering, and type-safe APIs. Let Igniter.js handle the API layer while TanStack Router manages the UI routing for a truly full-stack TypeScript experience.