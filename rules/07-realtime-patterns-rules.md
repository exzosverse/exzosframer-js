# Realtime Patterns Rules - Igniter.js Framework

## 🚀 Server-Sent Events (SSE) Architecture

### Core Realtime Principles
- **Unidirectional flow** - Server to client only
- **Event-driven** - Push updates on data changes
- **Channel-based** - Organize streams by topic
- **Automatic reconnection** - Built-in resilience
- **Scoped delivery** - Target specific users/groups

## 📡 Realtime Implementation Patterns

### Stream-Enabled Queries
```typescript
/**
 * @action list
 * @stream true
 * @description Live-updating list with automatic revalidation
 */
list: igniter.query({
  name: 'List Messages',
  path: '/' as const,
  stream: true, // ✅ CRITICAL: Enable streaming
  handler: async ({ context, response }) => {
    // Business Logic: Fetch initial data
    const messages = await context.database.message.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50
    });

    // Response: Initial data sent immediately
    return response.success({ messages });
  }
})
```

### Automatic Revalidation Pattern
```typescript
/**
 * @action create
 * @description Creates message and triggers live updates
 * @revalidates messages.list
 */
create: igniter.mutation({
  name: 'Send Message',
  path: '/' as const,
  body: MessageSchema,
  handler: async ({ request, context, response }) => {
    // Business Logic: Create message
    const message = await context.database.message.create({
      data: {
        ...request.body,
        userId: context.user.id,
        roomId: context.room.id
      }
    });

    // ✅ CRITICAL: Trigger automatic UI updates
    return response.created(message)
      .revalidate(['messages.list']); // All connected clients update
  }
})
```

## 🎯 Scoped Revalidation

### User-Specific Updates
```typescript
/**
 * @action updateProfile
 * @description Updates user profile with scoped revalidation
 */
updateProfile: igniter.mutation({
  use: [authProcedure()],
  handler: async ({ request, context, response }) => {
    const updated = await context.database.user.update({
      where: { id: context.user.id },
      data: request.body
    });

    // ✅ CORRECT: Only revalidate for specific user
    return response.success(updated)
      .revalidate(
        ['user.profile'],
        (ctx) => [`user:${ctx.user.id}`] // Scope function
      );
  }
})
```

### Room-Based Broadcasting
```typescript
/**
 * @action sendToRoom
 * @description Broadcasts to specific chat room
 */
sendToRoom: igniter.mutation({
  handler: async ({ request, context, response }) => {
    const { roomId, message } = request.body;

    // Business Logic: Save and broadcast
    const saved = await context.database.message.create({
      data: { roomId, content: message, userId: context.user.id }
    });

    // ✅ CORRECT: Scoped to room participants
    return response.created(saved)
      .revalidate(
        ['room.messages'],
        (ctx) => [`room:${roomId}`]
      );
  }
})
```

## 💬 Chat-Specific Patterns

### Typing Indicators
```typescript
/**
 * @stream typing
 * @description Real-time typing indicators
 */
typing: igniter.query({
  path: '/typing/:roomId' as const,
  stream: true,
  handler: async ({ request, context, realtime }) => {
    const { roomId } = request.params;

    // Subscribe to typing events
    const subscription = context.store.subscribe(
      `room:${roomId}:typing`,
      (data) => {
        realtime.send({
          event: 'typing',
          data
        });
      }
    );

    // Clean up on disconnect
    realtime.onDisconnect(() => {
      subscription.unsubscribe();
      // Notify others user stopped typing
      context.store.publish(`room:${roomId}:typing`, {
        userId: context.user.id,
        isTyping: false
      });
    });

    return realtime;
  }
})

// Publish typing status
startTyping: igniter.mutation({
  handler: async ({ request, context, response }) => {
    await context.store.publish(`room:${request.body.roomId}:typing`, {
      userId: context.user.id,
      userName: context.user.name,
      isTyping: true
    });

    return response.noContent();
  }
})
```

### Presence Management
```typescript
/**
 * @stream presence
 * @description Track online users in real-time
 */
presence: igniter.query({
  path: '/presence/:roomId' as const,
  stream: true,
  handler: async ({ request, context, realtime }) => {
    const { roomId } = request.params;
    const presenceKey = `room:${roomId}:presence`;

    // Add user to presence set
    await context.store.sadd(presenceKey, context.user.id);

    // Get current online users
    const onlineUsers = await context.store.smembers(presenceKey);

    // Send initial presence
    realtime.send({
      event: 'presence',
      data: { onlineUsers }
    });

    // Subscribe to presence changes
    const subscription = context.store.subscribe(
      `${presenceKey}:changes`,
      (data) => {
        realtime.send({
          event: 'presence_update',
          data
        });
      }
    );

    // Clean up on disconnect
    realtime.onDisconnect(async () => {
      await context.store.srem(presenceKey, context.user.id);
      await context.store.publish(`${presenceKey}:changes`, {
        type: 'user_left',
        userId: context.user.id
      });
      subscription.unsubscribe();
    });

    return realtime;
  }
})
```

### Message Status Updates
```typescript
/**
 * @action markAsRead
 * @description Updates message read status with live feedback
 */
markAsRead: igniter.mutation({
  handler: async ({ request, context, response }) => {
    const { messageIds, roomId } = request.body;

    // Business Logic: Update read status
    await context.database.messageStatus.createMany({
      data: messageIds.map(id => ({
        messageId: id,
        userId: context.user.id,
        status: 'read',
        readAt: new Date()
      }))
    });

    // Notify sender their message was read
    const messages = await context.database.message.findMany({
      where: { id: { in: messageIds } },
      select: { senderId: true }
    });

    const senderIds = [...new Set(messages.map(m => m.senderId))];

    // ✅ CORRECT: Scoped to message senders
    return response.success({ marked: messageIds.length })
      .revalidate(
        ['messages.status'],
        () => senderIds.map(id => `user:${id}`)
      );
  }
})
```

## 🔄 Custom Data Streams

### Notification Stream
```typescript
/**
 * @stream notifications
 * @description Personal notification stream
 */
notifications: igniter.query({
  path: '/notifications' as const,
  stream: true,
  use: [authProcedure()],
  handler: async ({ context, realtime }) => {
    const userId = context.user.id;

    // Send initial notifications
    const initial = await context.database.notification.findMany({
      where: { userId, read: false },
      orderBy: { createdAt: 'desc' },
      take: 10
    });

    realtime.send({
      event: 'initial',
      data: { notifications: initial }
    });

    // Subscribe to personal notification channel
    const subscription = context.store.subscribe(
      `user:${userId}:notifications`,
      (notification) => {
        realtime.send({
          event: 'notification',
          data: notification
        });
      }
    );

    // Clean up
    realtime.onDisconnect(() => {
      subscription.unsubscribe();
    });

    return realtime;
  }
})

// Send notification from anywhere
const sendNotification = async (userId: string, notification: Notification) => {
  // Save to database
  await context.database.notification.create({
    data: { userId, ...notification }
  });

  // Push to stream
  await context.store.publish(
    `user:${userId}:notifications`,
    notification
  );
};
```

## 🎮 Client-Side Integration

### React Hook Usage
```tsx
'use client';

function ChatRoom({ roomId }: { roomId: string }) {
  // Auto-updating messages list
  const messagesQuery = api.messages.list.useQuery({
    query: { roomId }
  });

  // Send message mutation
  const sendMutation = api.messages.create.useMutation({
    onSuccess: () => {
      // Messages auto-update via revalidation
      // No manual refetch needed!
    }
  });

  // Custom stream for typing indicators
  const typing = api.chat.typing.useRealtime({
    params: { roomId },
    onMessage: (data) => {
      // Handle typing updates
    }
  });

  return (
    <div>
      {/* Messages auto-update when new ones arrive */}
      {messagesQuery.data?.messages.map(msg => (
        <Message key={msg.id} {...msg} />
      ))}

      {/* Typing indicators */}
      {typing.data?.map(user => (
        <TypingIndicator key={user.id} user={user} />
      ))}
    </div>
  );
}
```

## 📊 Performance Optimization

### Debounced Updates
```typescript
// ✅ CORRECT: Debounce high-frequency updates
const debouncedRevalidate = debounce(
  (queryKeys: string[]) => {
    return response.success(data).revalidate(queryKeys);
  },
  100 // 100ms debounce
);
```

### Progressive Loading
```typescript
/**
 * @stream messages
 * @description Progressive message loading with pagination
 */
messages: igniter.query({
  path: '/messages/:roomId' as const,
  stream: true,
  query: z.object({
    limit: z.number().default(50),
    before: z.string().optional(),
  }),
  handler: async ({ request, context, realtime }) => {
    const { roomId } = request.params;
    const { limit, before } = request.query;

    // Initial load with pagination
    const messages = await context.database.message.findMany({
      where: {
        roomId,
        ...(before && { createdAt: { lt: new Date(before) } })
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: {
        author: true,
        reactions: true,
        readStatus: {
          where: { userId: context.user.id }
        }
      }
    });

    // Send initial batch
    realtime.send({
      event: 'messages',
      data: messages
    });

    // Subscribe to new messages only
    const subscription = context.store.subscribe(
      `room:${roomId}:messages:new`,
      (message) => {
        realtime.send({
          event: 'new_message',
          data: message
        });
      }
    );

    realtime.onDisconnect(() => {
      subscription.unsubscribe();
    });

    return realtime;
  }
})
```

### Batch Processing
```typescript
// ✅ CORRECT: Batch multiple updates
const batchUpdate = async (updates: Update[]) => {
  // Process all updates
  const results = await Promise.all(
    updates.map(u => processUpdate(u))
  );

  // Single revalidation for all
  return response.success(results)
    .revalidate(['messages.list']);
};
```

### Connection Management
```typescript
// ✅ CORRECT: Implement connection pooling
const connectionPool = new Map<string, SSEConnection>();

const getOrCreateConnection = (userId: string) => {
  if (!connectionPool.has(userId)) {
    connectionPool.set(userId, createSSEConnection(userId));
  }
  return connectionPool.get(userId);
};

// Connection health monitoring
const monitorConnections = () => {
  setInterval(() => {
    connectionPool.forEach((connection, userId) => {
      if (!connection.isAlive()) {
        connectionPool.delete(userId);
        connection.close();
      }
    });
  }, 30000); // Check every 30 seconds
};
```

### Rate Limiting
```typescript
/**
 * @middleware rateLimit
 * @description Protect realtime endpoints from abuse
 */
const realtimeRateLimit = igniter.middleware({
  handler: async ({ context, next }) => {
    const userId = context.user?.id || context.ip;
    const key = `rate:realtime:${userId}`;

    // Track connections per minute
    const count = await context.store.incr(key);
    if (count === 1) {
      await context.store.expire(key, 60);
    }

    if (count > 10) { // Max 10 connections per minute
      throw new Error('Rate limit exceeded');
    }

    return next();
  }
});
```

## 🚨 Realtime Anti-Patterns

### ❌ Forgetting stream: true
```typescript
// WRONG: Query won't receive live updates
list: igniter.query({
  path: '/',
  // Missing stream: true
  handler: async () => { ... }
})
```

### ❌ Missing revalidation
```typescript
// WRONG: UI won't update
create: igniter.mutation({
  handler: async ({ response }) => {
    return response.created(data);
    // Missing .revalidate()
  }
})
```

### ❌ Broadcasting to all
```typescript
// WRONG: No scoping, everyone gets update
return response.success(data)
  .revalidate(['sensitive.data']);
  // Should use scope function
```

### ❌ Memory leaks
```typescript
// WRONG: Subscription not cleaned up
handler: async ({ realtime }) => {
  context.store.subscribe('channel', handler);
  // Missing unsubscribe on disconnect!
}
```

## 📋 Realtime Checklist

### Implementation
- [ ] Enable `stream: true` on live queries
- [ ] Add `.revalidate()` to mutations
- [ ] Implement scoping for targeted updates
- [ ] Set up subscription cleanup
- [ ] Handle reconnection logic

### Testing
- [ ] Test with multiple concurrent users
- [ ] Verify scoped updates work correctly
- [ ] Check memory usage over time
- [ ] Test reconnection scenarios
- [ ] Validate presence tracking

### Performance
- [ ] Debounce high-frequency updates
- [ ] Batch related operations
- [ ] Monitor connection count
- [ ] Implement connection pooling
- [ ] Add rate limiting

### Security
- [ ] Validate user scope access
- [ ] Sanitize broadcast data
- [ ] Implement rate limiting
- [ ] Add connection authentication
- [ ] Monitor for abuse patterns

## 🎯 Advanced Realtime Patterns

### Optimistic Updates
```typescript
/**
 * @action sendMessage
 * @description Optimistic message sending with rollback
 */
const sendMessage = api.messages.create.useMutation({
  onMutate: async (newMessage) => {
    // Cancel outgoing refetches
    await queryClient.cancelQueries(['messages', roomId]);

    // Snapshot previous value
    const previousMessages = queryClient.getQueryData(['messages', roomId]);

    // Optimistically update
    queryClient.setQueryData(['messages', roomId], (old) => [
      ...old,
      { ...newMessage, id: 'temp-' + Date.now(), pending: true }
    ]);

    return { previousMessages };
  },
  onError: (err, newMessage, context) => {
    // Rollback on error
    queryClient.setQueryData(['messages', roomId], context.previousMessages);
  },
  onSettled: () => {
    // Always refetch after mutation
    queryClient.invalidateQueries(['messages', roomId]);
  }
});
```

### Conflict Resolution
```typescript
/**
 * @stream collaborative
 * @description Handle collaborative editing with conflict resolution
 */
collab: igniter.query({
  path: '/collab/:docId' as const,
  stream: true,
  handler: async ({ request, context, realtime }) => {
    const { docId } = request.params;
    const userId = context.user.id;

    // Track document version
    let currentVersion = await context.store.get(`doc:${docId}:version`) || 0;

    // Subscribe to document changes
    const subscription = context.store.subscribe(
      `doc:${docId}:changes`,
      async (change) => {
        // Handle version conflicts
        if (change.baseVersion < currentVersion) {
          // Send conflict notification
          realtime.send({
            event: 'conflict',
            data: {
              currentVersion,
              change,
              resolution: 'manual' // or 'auto-merge'
            }
          });
        } else {
          // Apply change
          currentVersion = change.version;
          realtime.send({
            event: 'change',
            data: change
          });
        }
      }
    );

    realtime.onDisconnect(() => {
      subscription.unsubscribe();
    });

    return realtime;
  }
})
```

### Reconnection Strategy
```typescript
/**
 * Client-side reconnection with exponential backoff
 */
const useRealtimeConnection = (endpoint: string) => {
  const [retryCount, setRetryCount] = useState(0);
  const maxRetries = 5;

  const connect = useCallback(() => {
    const eventSource = new EventSource(endpoint);

    eventSource.onopen = () => {
      setRetryCount(0); // Reset on successful connection
    };

    eventSource.onerror = () => {
      eventSource.close();

      if (retryCount < maxRetries) {
        const delay = Math.min(1000 * Math.pow(2, retryCount), 30000);
        setTimeout(() => {
          setRetryCount(prev => prev + 1);
          connect();
        }, delay);
      }
    };

    return eventSource;
  }, [endpoint, retryCount]);

  useEffect(() => {
    const connection = connect();
    return () => connection.close();
  }, [connect]);
};
```

---

**Remember**: Realtime features should enhance user experience without overwhelming the system. Always scope updates appropriately, clean up resources, and test with realistic concurrent user loads.

## 📚 Related Documentation
- [Core Concepts](./01-core-concepts-rules.md)
- [Client Usage](./03-client-usage-rules.md)
- [Advanced Features](./04-advanced-features-rules.md)
- [Memory Management](./06-memory-management-rules.md)