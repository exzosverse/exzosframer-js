# Client-Side Rules - Igniter.js Framework

## 🎨 IgniterProvider Rules

### Provider Configuration
```typescript
// ✅ CORRECT: Provider setup with all features
import { IgniterProvider } from '@igniter-js/core/client';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <IgniterProvider
      client={api}
      baseURL={process.env.NEXT_PUBLIC_API_URL}
      basePath="/api"
      enableRealtime={true}
      getScopesIds={() => {
        'use server'
        const session = getSession();
        return session ? [`user:${session.user.id}`] : [];
      }}
      onError={(error) => {
        console.error('API Error:', error);
      }}
      queryConfig={{
        staleTime: 5 * 60 * 1000, // 5 minutes
        cacheTime: 10 * 60 * 1000, // 10 minutes
      }}
    >
      {children}
    </IgniterProvider>
  );
}
```

### Provider Rules
- **ALWAYS** wrap app with IgniterProvider
- **NEVER** use hooks outside provider
- **ALWAYS** configure scopes for realtime
- **PREFER** server-side scope resolution

## 📡 API Client Rules

### Client Import Pattern
```typescript
// ✅ CORRECT: Import from generated client
import { api } from '@/igniter.client';

// ❌ WRONG: Manual API construction
const api = new IgniterClient(); // Never do this!
```

### Server vs Client Usage
```typescript
// ✅ Server Component (RSC)
export default async function Page() {
  const { posts } = await api.posts.list.query();
  return <PostList posts={posts} />;
}

// ✅ Client Component
'use client';
export function PostList() {
  const { data, isLoading } = api.posts.list.useQuery();
  // ...
}

// ❌ WRONG: Mixing patterns
'use client';
const data = await api.posts.list.query(); // Can't await in client!
```

## 🔍 useQuery Hook Rules

### Basic Usage Pattern
```typescript
// ✅ CORRECT: Complete query handling
function PostsList() {
  const postsQuery = api.posts.list.useQuery();

  // Always handle loading state
  if (postsQuery.isLoading) {
    return <Skeleton />;
  }

  // Always handle error state
  if (postsQuery.isError) {
    return <ErrorMessage error={postsQuery.error} />;
  }

  // Safe data access
  return (
    <ul>
      {postsQuery.data?.posts.map(post => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

### Query Parameters
```typescript
// ✅ CORRECT: Type-safe parameters
const query = api.posts.list.useQuery({
  query: {
    page: 2,
    limit: 10,
    search: 'typescript'
  },
  params: {
    categoryId: '123' // For dynamic routes
  }
});

// ❌ WRONG: Untyped parameters
const query = api.posts.list.useQuery({
  query: {
    wrongParam: 'value' // TypeScript will catch this!
  }
});
```

### Query Options
```typescript
// ✅ CORRECT: Query configuration
const query = api.posts.list.useQuery({
  enabled: isAuthenticated, // Conditional fetching
  staleTime: 5 * 60 * 1000, // 5 minutes
  cacheTime: 10 * 60 * 1000, // 10 minutes
  refetchInterval: 30000, // Polling every 30s
  refetchOnWindowFocus: true,
  refetchOnMount: true,
  refetchOnReconnect: true,
  retry: 3,
  retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
  onSuccess: (data) => {
    console.log('Data fetched:', data);
  },
  onError: (error) => {
    toast.error('Failed to fetch data');
  }
});
```

### Dependent Queries
```typescript
// ✅ CORRECT: Sequential data fetching
function UserProfile({ userId }: { userId: string }) {
  // First query
  const userQuery = api.users.get.useQuery({
    params: { userId }
  });

  // Second query depends on first
  const postsQuery = api.posts.byUser.useQuery({
    params: { userId },
    enabled: !!userQuery.data // Only run when user is loaded
  });

  if (userQuery.isLoading) return <Loading />;
  if (userQuery.isError) return <Error />;

  return (
    <div>
      <UserInfo user={userQuery.data} />
      {postsQuery.isLoading ? (
        <PostsSkeleton />
      ) : (
        <PostsList posts={postsQuery.data} />
      )}
    </div>
  );
}
```

## ✏️ useMutation Hook Rules

### Basic Mutation Pattern
```typescript
// ✅ CORRECT: Complete mutation handling
function CreatePost() {
  const createMutation = api.posts.create.useMutation({
    onSuccess: (data) => {
      toast.success('Post created!');
      router.push(`/posts/${data.id}`);
    },
    onError: (error) => {
      toast.error(error.message);
    }
  });

  const handleSubmit = async (values: FormValues) => {
    await createMutation.mutate({
      body: values
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
      <button
        type="submit"
        disabled={createMutation.isLoading}
      >
        {createMutation.isLoading ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  );
}
```

### Optimistic Updates
```typescript
// ✅ CORRECT: Optimistic UI updates
function TodoItem({ todo }: { todo: Todo }) {
  const queryClient = useQueryClient();

  const updateMutation = api.todos.update.useMutation({
    onMutate: async (newTodo) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries(['todos.list']);

      // Snapshot previous value
      const previousTodos = queryClient.getQueryData(['todos.list']);

      // Optimistically update
      queryClient.setQueryData(['todos.list'], (old) => {
        return {
          ...old,
          todos: old.todos.map(t =>
            t.id === todo.id ? { ...t, ...newTodo } : t
          )
        };
      });

      return { previousTodos };
    },
    onError: (err, newTodo, context) => {
      // Rollback on error
      queryClient.setQueryData(['todos.list'], context.previousTodos);
    },
    onSettled: () => {
      // Always refetch after error or success
      queryClient.invalidateQueries(['todos.list']);
    }
  });

  return (
    <div>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={(e) => updateMutation.mutate({
          params: { id: todo.id },
          body: { completed: e.target.checked }
        })}
      />
      {todo.title}
    </div>
  );
}
```

### Mutation with File Upload
```typescript
// ✅ CORRECT: File upload handling
function ImageUpload() {
  const uploadMutation = api.files.upload.useMutation();

  const handleFileSelect = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);
    formData.append('type', 'image');

    await uploadMutation.mutate({
      body: formData,
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
  };

  return (
    <input
      type="file"
      onChange={handleFileSelect}
      disabled={uploadMutation.isLoading}
    />
  );
}
```

## 🔄 useRealtime Hook Rules

### Basic Realtime Subscription
```typescript
// ✅ CORRECT: Realtime data streaming
function NotificationsFeed() {
  const realtimeNotifications = api.notifications.stream.useRealtime({
    onMessage: (notification) => {
      toast.info(`New: ${notification.title}`);
    },
    onError: (error) => {
      console.error('Stream error:', error);
    },
    onReconnect: () => {
      console.log('Reconnected to stream');
    }
  });

  return (
    <div>
      {realtimeNotifications.isConnected ? (
        <span>🟢 Live</span>
      ) : (
        <span>🔴 Disconnected</span>
      )}

      <ul>
        {realtimeNotifications.data?.map(notification => (
          <li key={notification.id}>{notification.message}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Custom Event Handling
```typescript
// ✅ CORRECT: Handle different event types
const stream = api.events.stream.useRealtime({
  onMessage: (message) => {
    switch (message.event) {
      case 'user-joined':
        addUser(message.data);
        break;
      case 'user-left':
        removeUser(message.data);
        break;
      case 'message':
        addMessage(message.data);
        break;
    }
  }
});
```

## 🔄 Cache Management Rules

### Query Invalidation
```typescript
// ✅ CORRECT: Manual cache invalidation
import { useIgniterContext } from '@/igniter.client';

function DeleteButton({ postId }: { postId: string }) {
  const igniter = useIgniterContext();

  const deleteMutation = api.posts.delete.useMutation({
    onSuccess: () => {
      // Invalidate and refetch
      igniter.invalidate(['posts.list']);

      // Or invalidate multiple
      igniter.invalidate([
        'posts.list',
        'posts.count',
        ['posts.get', { params: { id: postId } }]
      ]);
    }
  });

  return (
    <button onClick={() => deleteMutation.mutate({ params: { postId } })}>
      Delete
    </button>
  );
}
```

### Prefetching
```typescript
// ✅ CORRECT: Prefetch on hover
function PostLink({ postId }: { postId: string }) {
  const igniter = useIgniterContext();

  const handleMouseEnter = () => {
    igniter.prefetch(['posts.get', { params: { id: postId } }]);
  };

  return (
    <Link
      href={`/posts/${postId}`}
      onMouseEnter={handleMouseEnter}
    >
      View Post
    </Link>
  );
}
```

## 🎭 Loading States Rules

### Skeleton Loading
```typescript
// ✅ CORRECT: Proper loading states
function PostsList() {
  const query = api.posts.list.useQuery();

  if (query.isLoading) {
    return <PostsListSkeleton />;
  }

  if (query.isFetching && !query.isLoading) {
    return (
      <>
        <RefreshIndicator />
        <PostsList posts={query.data} />
      </>
    );
  }

  return <PostsList posts={query.data} />;
}
```

### Progressive Enhancement
```typescript
// ✅ CORRECT: Progressive data loading
function Dashboard() {
  // Critical data
  const userQuery = api.user.current.useQuery();

  // Non-critical data (don't block render)
  const statsQuery = api.stats.overview.useQuery({
    enabled: !!userQuery.data
  });

  const notificationsQuery = api.notifications.recent.useQuery({
    enabled: !!userQuery.data
  });

  if (userQuery.isLoading) return <FullPageLoader />;
  if (userQuery.isError) return <ErrorPage />;

  return (
    <div>
      <UserInfo user={userQuery.data} />

      {statsQuery.data ? (
        <StatsWidget stats={statsQuery.data} />
      ) : (
        <StatsWidgetSkeleton />
      )}

      {notificationsQuery.data ? (
        <NotificationsList items={notificationsQuery.data} />
      ) : (
        <NotificationsListSkeleton />
      )}
    </div>
  );
}
```

## 🚨 Client-Side Anti-Patterns

### ❌ Await in Client Component
```typescript
'use client';
// WRONG: Can't use await in client components
const data = await api.posts.list.query();
```

### ❌ Hook Outside Provider
```typescript
// WRONG: Must be inside IgniterProvider
function App() {
  const query = api.posts.list.useQuery();

  return (
    <IgniterProvider>
      {/* Too late! */}
    </IgniterProvider>
  );
}
```

### ❌ Missing Error Handling
```typescript
// WRONG: No error handling
function Posts() {
  const query = api.posts.list.useQuery();
  return <div>{query.data.posts}</div>; // Will crash if error!
}
```

### ❌ Infinite Loop
```typescript
// WRONG: Causes infinite re-fetching
function Posts() {
  const [params, setParams] = useState({});

  const query = api.posts.list.useQuery({
    query: { ...params } // New object every render!
  });
}
```

## 📋 Client-Side Checklist

- [ ] IgniterProvider wraps entire app
- [ ] Scopes configured for realtime
- [ ] All queries handle loading state
- [ ] All queries handle error state
- [ ] Mutations have success/error handlers
- [ ] Optimistic updates where appropriate
- [ ] Cache invalidation after mutations
- [ ] Dependent queries use `enabled`
- [ ] No await in client components
- [ ] Stable query parameters
- [ ] Prefetching for better UX
- [ ] Progressive data loading
- [ ] Proper TypeScript types throughout

---

**Remember**: The client-side is fully type-safe end-to-end. Leverage TypeScript for autocomplete and error prevention. Always handle loading and error states for robust UX.