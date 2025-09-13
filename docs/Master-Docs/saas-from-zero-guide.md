# Building a SaaS Application from Zero with Igniter.js

**Version**: 0.2.68+
**Difficulty**: Intermediate to Advanced
**Duration**: 8-12 hours
**Last Updated**: September 13, 2025

## 🎯 What You'll Build

A complete multi-tenant SaaS application with:
- 🔐 **User Authentication & Authorization** (JWT, OAuth)
- 🏢 **Multi-tenant Architecture** (Organization-based)
- 💳 **Subscription Management** (Stripe integration)
- 📊 **Analytics Dashboard** (Real-time metrics)
- 📧 **Email System** (Transactional emails)
- 🔄 **Real-time Features** (WebSocket/SSE)
- 🎨 **Modern UI** (React/Next.js with TailwindCSS)
- 🚀 **Production Deployment** (Docker + Cloud)

## 📋 Prerequisites

### Required Knowledge
- **JavaScript/TypeScript**: Intermediate level
- **React/Next.js**: Basic to intermediate
- **Database Concepts**: SQL and ORMs
- **API Development**: REST and real-time APIs

### Development Environment
- **Node.js**: v18+ or Bun v1.0+
- **Database**: PostgreSQL 14+
- **Redis**: For caching and sessions
- **Git**: Version control
- **Docker**: For deployment (optional)

### External Services
- **Stripe Account**: Payment processing
- **Email Service**: SendGrid, Mailgun, or similar
- **Cloud Provider**: AWS, Vercel, or Railway

## 🚀 Project Setup

### 1. Create New Project
```bash
# Create new Igniter.js project
npx create-igniter-app@latest my-saas --template saas

# Navigate to project
cd my-saas

# Install dependencies
npm install
```

### 2. Environment Configuration
```bash
# .env.local
DATABASE_URL="postgresql://user:password@localhost:5432/my_saas"
REDIS_URL="redis://localhost:6379"
JWT_SECRET="your-super-secret-jwt-key-here"
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
EMAIL_API_KEY="your-email-service-api-key"
NEXTAUTH_SECRET="your-nextauth-secret"
NEXTAUTH_URL="http://localhost:3000"
```

### 3. Database Setup
```bash
# Generate Prisma client and run migrations
npx prisma generate
npx prisma db push

# Seed initial data
npx prisma db seed
```

## 🏗️ Architecture Overview

### Project Structure
```
my-saas/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/            # Authentication pages
│   │   ├── (dashboard)/       # Main application
│   │   ├── api/               # API routes
│   │   └── globals.css
│   ├── features/              # Business logic
│   │   ├── auth/              # Authentication
│   │   ├── organizations/     # Multi-tenancy
│   │   ├── subscriptions/     # Billing
│   │   ├── analytics/         # Metrics
│   │   └── shared/            # Shared utilities
│   ├── components/            # React components
│   ├── lib/                   # Utilities
│   └── igniter/               # Igniter.js setup
├── prisma/                    # Database schema
├── public/                    # Static assets
└── docs/                      # Project documentation
```

### Core Technologies Stack
```typescript
// Technology decisions
const techStack = {
  framework: 'Igniter.js 0.2.68+',
  frontend: 'Next.js 14 + React 18',
  styling: 'TailwindCSS + HeadlessUI',
  database: 'PostgreSQL + Prisma',
  cache: 'Redis',
  auth: 'NextAuth.js + JWT',
  payments: 'Stripe',
  email: 'React Email + SendGrid',
  realtime: 'Server-Sent Events',
  deployment: 'Docker + Cloud Provider'
};
```

## 🔧 Core Framework Setup

### 1. Igniter.js Configuration
```typescript
// src/igniter/igniter.ts
import { Igniter } from '@igniter-js/core';
import { PrismaAdapter } from '@igniter-js/adapter-prisma';
import { RedisAdapter } from '@igniter-js/adapter-redis';
import { NextJSAdapter } from '@igniter-js/adapter-nextjs';

export const igniter = Igniter
  .adapter(NextJSAdapter, {
    appDir: true,
    experimental: {
      serverComponentsExternalPackages: ['@prisma/client']
    }
  })
  .database(PrismaAdapter, {
    url: process.env.DATABASE_URL!
  })
  .cache(RedisAdapter, {
    url: process.env.REDIS_URL!,
    ttl: 3600 // 1 hour default
  })
  .auth({
    jwt: {
      secret: process.env.JWT_SECRET!,
      expiresIn: '7d'
    },
    sessions: {
      strategy: 'database',
      maxAge: 30 * 24 * 60 * 60 // 30 days
    }
  })
  .features({
    multiTenant: true,
    realtime: true,
    analytics: true,
    subscriptions: true
  })
  .telemetry({
    enabled: process.env.NODE_ENV === 'production',
    service: 'my-saas-api'
  })
  .create();
```

### 2. Database Schema Design
```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// User Management
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  avatar    String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  memberships OrganizationMember[]
  sessions    Session[]
  accounts    Account[]

  @@map("users")
}

// Multi-tenant Organizations
model Organization {
  id          String            @id @default(cuid())
  name        String
  slug        String            @unique
  domain      String?           @unique
  logo        String?
  plan        SubscriptionPlan  @default(FREE)
  status      OrganizationStatus @default(ACTIVE)
  createdAt   DateTime          @default(now())
  updatedAt   DateTime          @updatedAt

  // Relations
  members      OrganizationMember[]
  subscription Subscription?
  analytics    AnalyticsEvent[]

  @@map("organizations")
}

// Organization Membership
model OrganizationMember {
  id     String           @id @default(cuid())
  role   OrganizationRole @default(MEMBER)
  userId String
  orgId  String

  // Relations
  user         User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  organization Organization @relation(fields: [orgId], references: [id], onDelete: Cascade)

  @@unique([userId, orgId])
  @@map("organization_members")
}

// Subscription Management
model Subscription {
  id                String           @id @default(cuid())
  stripeCustomerId  String           @unique
  stripeSubscriptionId String        @unique
  plan              SubscriptionPlan
  status            SubscriptionStatus
  currentPeriodStart DateTime
  currentPeriodEnd   DateTime
  cancelAtPeriodEnd  Boolean         @default(false)
  createdAt         DateTime         @default(now())
  updatedAt         DateTime         @updatedAt

  // Relations
  organizationId String       @unique
  organization   Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)

  @@map("subscriptions")
}

// Analytics Events
model AnalyticsEvent {
  id         String   @id @default(cuid())
  event      String
  properties Json?
  userId     String?
  orgId      String
  timestamp  DateTime @default(now())

  // Relations
  organization Organization @relation(fields: [orgId], references: [id], onDelete: Cascade)

  @@index([orgId, timestamp])
  @@map("analytics_events")
}

// Enums
enum OrganizationRole {
  OWNER
  ADMIN
  MEMBER
}

enum OrganizationStatus {
  ACTIVE
  SUSPENDED
  DELETED
}

enum SubscriptionPlan {
  FREE
  STARTER
  PRO
  ENTERPRISE
}

enum SubscriptionStatus {
  ACTIVE
  PAST_DUE
  CANCELED
  INCOMPLETE
  TRIALING
}
```

## 🔐 Authentication System

### 1. Authentication Controller
```typescript
// src/features/auth/auth.controller.ts
import { z } from 'zod';
import { igniter } from '@/igniter/igniter';
import { authService } from './auth.service';

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6)
});

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  name: z.string().min(2),
  organizationName: z.string().min(2)
});

export const authController = igniter.controller({
  name: 'auth',
  description: 'User authentication and registration',
  actions: {
    // User Login
    login: igniter.mutation({
      name: 'Login',
      description: 'Authenticate user and create session',
      input: loginSchema,
      output: z.object({
        user: z.object({
          id: z.string(),
          email: z.string(),
          name: z.string().nullable()
        }),
        token: z.string(),
        organization: z.object({
          id: z.string(),
          name: z.string(),
          slug: z.string()
        })
      }),
      handler: async ({ input, ctx }) => {
        const { email, password } = input;

        const result = await authService.authenticate({
          email,
          password
        });

        if (!result.success) {
          throw new Error('Invalid credentials');
        }

        // Create session
        const session = await authService.createSession({
          userId: result.user.id,
          userAgent: ctx.request.headers['user-agent'],
          ip: ctx.request.ip
        });

        return {
          user: result.user,
          token: session.token,
          organization: result.organization
        };
      }
    }),

    // User Registration
    register: igniter.mutation({
      name: 'Register',
      description: 'Create new user account and organization',
      input: registerSchema,
      output: z.object({
        user: z.object({
          id: z.string(),
          email: z.string(),
          name: z.string()
        }),
        token: z.string(),
        organization: z.object({
          id: z.string(),
          name: z.string(),
          slug: z.string()
        })
      }),
      handler: async ({ input, ctx }) => {
        const { email, password, name, organizationName } = input;

        // Check if user already exists
        const existingUser = await authService.findUserByEmail(email);
        if (existingUser) {
          throw new Error('User already exists');
        }

        // Create user and organization
        const result = await authService.createUserWithOrganization({
          email,
          password,
          name,
          organizationName
        });

        // Create session
        const session = await authService.createSession({
          userId: result.user.id,
          userAgent: ctx.request.headers['user-agent'],
          ip: ctx.request.ip
        });

        return {
          user: result.user,
          token: session.token,
          organization: result.organization
        };
      }
    }),

    // Session Validation
    me: igniter.query({
      name: 'Current User',
      description: 'Get current authenticated user',
      output: z.object({
        user: z.object({
          id: z.string(),
          email: z.string(),
          name: z.string().nullable(),
          avatar: z.string().nullable()
        }),
        organization: z.object({
          id: z.string(),
          name: z.string(),
          slug: z.string(),
          role: z.enum(['OWNER', 'ADMIN', 'MEMBER'])
        })
      }),
      middleware: [authService.requireAuth()],
      handler: async ({ ctx }) => {
        const { user, organization } = ctx.auth;
        return { user, organization };
      }
    }),

    // Logout
    logout: igniter.mutation({
      name: 'Logout',
      description: 'Invalidate user session',
      output: z.object({ success: z.boolean() }),
      middleware: [authService.requireAuth()],
      handler: async ({ ctx }) => {
        await authService.invalidateSession(ctx.auth.sessionId);
        return { success: true };
      }
    })
  }
});
```

### 2. Authentication Service
```typescript
// src/features/auth/auth.service.ts
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { createSlug } from '@/lib/utils';

const prisma = new PrismaClient();

export class AuthService {
  // Authenticate user
  async authenticate({ email, password }: { email: string; password: string }) {
    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        memberships: {
          include: {
            organization: true
          },
          orderBy: { role: 'asc' }
        }
      }
    });

    if (!user || !user.password) {
      return { success: false };
    }

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return { success: false };
    }

    const primaryMembership = user.memberships[0];
    if (!primaryMembership) {
      throw new Error('User has no organization membership');
    }

    return {
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      },
      organization: {
        id: primaryMembership.organization.id,
        name: primaryMembership.organization.name,
        slug: primaryMembership.organization.slug,
        role: primaryMembership.role
      }
    };
  }

  // Create user with organization
  async createUserWithOrganization({
    email,
    password,
    name,
    organizationName
  }: {
    email: string;
    password: string;
    name: string;
    organizationName: string;
  }) {
    const hashedPassword = await bcrypt.hash(password, 12);
    const orgSlug = createSlug(organizationName);

    const result = await prisma.$transaction(async (tx) => {
      // Create user
      const user = await tx.user.create({
        data: {
          email,
          password: hashedPassword,
          name
        }
      });

      // Create organization
      const organization = await tx.organization.create({
        data: {
          name: organizationName,
          slug: orgSlug,
          plan: 'FREE',
          status: 'ACTIVE'
        }
      });

      // Create membership
      await tx.organizationMember.create({
        data: {
          userId: user.id,
          orgId: organization.id,
          role: 'OWNER'
        }
      });

      return { user, organization };
    });

    return {
      user: {
        id: result.user.id,
        email: result.user.email,
        name: result.user.name
      },
      organization: {
        id: result.organization.id,
        name: result.organization.name,
        slug: result.organization.slug,
        role: 'OWNER' as const
      }
    };
  }

  // Create session
  async createSession({
    userId,
    userAgent,
    ip
  }: {
    userId: string;
    userAgent?: string;
    ip?: string;
  }) {
    const session = await prisma.session.create({
      data: {
        userId,
        userAgent,
        ip,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
      }
    });

    const token = jwt.sign(
      {
        sessionId: session.id,
        userId
      },
      process.env.JWT_SECRET!,
      { expiresIn: '30d' }
    );

    return { token, sessionId: session.id };
  }

  // Authentication middleware
  requireAuth() {
    return igniter.middleware({
      name: 'require-auth',
      handler: async ({ ctx, next }) => {
        const authHeader = ctx.request.headers.authorization;
        if (!authHeader?.startsWith('Bearer ')) {
          throw new Error('Authentication required');
        }

        const token = authHeader.substring(7);

        try {
          const payload = jwt.verify(token, process.env.JWT_SECRET!) as any;

          const session = await prisma.session.findFirst({
            where: {
              id: payload.sessionId,
              userId: payload.userId,
              expiresAt: { gt: new Date() }
            },
            include: {
              user: {
                include: {
                  memberships: {
                    include: {
                      organization: true
                    }
                  }
                }
              }
            }
          });

          if (!session) {
            throw new Error('Invalid session');
          }

          const primaryMembership = session.user.memberships[0];

          ctx.auth = {
            sessionId: session.id,
            user: {
              id: session.user.id,
              email: session.user.email,
              name: session.user.name,
              avatar: session.user.avatar
            },
            organization: {
              id: primaryMembership.organization.id,
              name: primaryMembership.organization.name,
              slug: primaryMembership.organization.slug,
              role: primaryMembership.role
            }
          };

          return next();
        } catch (error) {
          throw new Error('Invalid token');
        }
      }
    });
  }
}

export const authService = new AuthService();
```

## 💳 Subscription Management

### 1. Subscription Controller
```typescript
// src/features/subscriptions/subscriptions.controller.ts
import { z } from 'zod';
import { igniter } from '@/igniter/igniter';
import { authService } from '@/features/auth/auth.service';
import { subscriptionService } from './subscriptions.service';

export const subscriptionsController = igniter.controller({
  name: 'subscriptions',
  description: 'Subscription and billing management',
  middleware: [authService.requireAuth()],
  actions: {
    // Get current subscription
    current: igniter.query({
      name: 'Current Subscription',
      description: 'Get organization subscription details',
      output: z.object({
        subscription: z.object({
          id: z.string(),
          plan: z.enum(['FREE', 'STARTER', 'PRO', 'ENTERPRISE']),
          status: z.string(),
          currentPeriodEnd: z.date(),
          cancelAtPeriodEnd: z.boolean()
        }).nullable(),
        usage: z.object({
          users: z.number(),
          projects: z.number(),
          apiCalls: z.number()
        })
      }),
      handler: async ({ ctx }) => {
        const { organization } = ctx.auth;

        const subscription = await subscriptionService.getSubscription(organization.id);
        const usage = await subscriptionService.getUsage(organization.id);

        return { subscription, usage };
      }
    }),

    // Create checkout session
    createCheckout: igniter.mutation({
      name: 'Create Checkout Session',
      description: 'Create Stripe checkout session for subscription',
      input: z.object({
        plan: z.enum(['STARTER', 'PRO', 'ENTERPRISE']),
        billingCycle: z.enum(['monthly', 'yearly']).default('monthly')
      }),
      output: z.object({
        checkoutUrl: z.string()
      }),
      handler: async ({ input, ctx }) => {
        const { plan, billingCycle } = input;
        const { organization, user } = ctx.auth;

        const checkoutSession = await subscriptionService.createCheckoutSession({
          organizationId: organization.id,
          userEmail: user.email,
          plan,
          billingCycle
        });

        return { checkoutUrl: checkoutSession.url };
      }
    }),

    // Create customer portal session
    createPortal: igniter.mutation({
      name: 'Create Customer Portal Session',
      description: 'Create Stripe customer portal session',
      output: z.object({
        portalUrl: z.string()
      }),
      handler: async ({ ctx }) => {
        const { organization } = ctx.auth;

        const portalSession = await subscriptionService.createPortalSession(organization.id);

        return { portalUrl: portalSession.url };
      }
    }),

    // Handle webhooks
    webhook: igniter.mutation({
      name: 'Stripe Webhook',
      description: 'Handle Stripe webhook events',
      input: z.object({
        signature: z.string(),
        payload: z.string()
      }),
      output: z.object({ received: z.boolean() }),
      handler: async ({ input }) => {
        const { signature, payload } = input;

        await subscriptionService.handleWebhook(signature, payload);

        return { received: true };
      }
    })
  }
});
```

### 2. Subscription Service with Stripe
```typescript
// src/features/subscriptions/subscriptions.service.ts
import Stripe from 'stripe';
import { PrismaClient } from '@prisma/client';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16'
});

const prisma = new PrismaClient();

export class SubscriptionService {
  // Price mapping
  private readonly PRICE_MAP = {
    STARTER: {
      monthly: 'price_starter_monthly_id',
      yearly: 'price_starter_yearly_id'
    },
    PRO: {
      monthly: 'price_pro_monthly_id',
      yearly: 'price_pro_yearly_id'
    },
    ENTERPRISE: {
      monthly: 'price_enterprise_monthly_id',
      yearly: 'price_enterprise_yearly_id'
    }
  };

  // Get subscription details
  async getSubscription(organizationId: string) {
    const subscription = await prisma.subscription.findFirst({
      where: { organizationId }
    });

    return subscription ? {
      id: subscription.id,
      plan: subscription.plan,
      status: subscription.status,
      currentPeriodEnd: subscription.currentPeriodEnd,
      cancelAtPeriodEnd: subscription.cancelAtPeriodEnd
    } : null;
  }

  // Get usage metrics
  async getUsage(organizationId: string) {
    const [users, projects, apiCalls] = await Promise.all([
      prisma.organizationMember.count({
        where: { orgId: organizationId }
      }),
      prisma.project.count({
        where: { organizationId }
      }),
      prisma.analyticsEvent.count({
        where: {
          orgId: organizationId,
          timestamp: {
            gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
          }
        }
      })
    ]);

    return { users, projects, apiCalls };
  }

  // Create checkout session
  async createCheckoutSession({
    organizationId,
    userEmail,
    plan,
    billingCycle
  }: {
    organizationId: string;
    userEmail: string;
    plan: 'STARTER' | 'PRO' | 'ENTERPRISE';
    billingCycle: 'monthly' | 'yearly';
  }) {
    const priceId = this.PRICE_MAP[plan][billingCycle];

    // Get or create Stripe customer
    let customer = await stripe.customers.list({
      email: userEmail,
      limit: 1
    });

    let customerId: string;
    if (customer.data.length === 0) {
      const newCustomer = await stripe.customers.create({
        email: userEmail,
        metadata: {
          organizationId
        }
      });
      customerId = newCustomer.id;
    } else {
      customerId = customer.data[0].id;
    }

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [
        {
          price: priceId,
          quantity: 1
        }
      ],
      success_url: `${process.env.NEXTAUTH_URL}/dashboard/billing?success=true`,
      cancel_url: `${process.env.NEXTAUTH_URL}/dashboard/billing?canceled=true`,
      metadata: {
        organizationId,
        plan
      }
    });

    return session;
  }

  // Create customer portal session
  async createPortalSession(organizationId: string) {
    const subscription = await prisma.subscription.findFirst({
      where: { organizationId }
    });

    if (!subscription) {
      throw new Error('No subscription found');
    }

    const session = await stripe.billingPortal.sessions.create({
      customer: subscription.stripeCustomerId,
      return_url: `${process.env.NEXTAUTH_URL}/dashboard/billing`
    });

    return session;
  }

  // Handle Stripe webhooks
  async handleWebhook(signature: string, payload: string) {
    const event = stripe.webhooks.constructEvent(
      payload,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );

    switch (event.type) {
      case 'checkout.session.completed':
        await this.handleCheckoutCompleted(event.data.object as Stripe.Checkout.Session);
        break;

      case 'customer.subscription.updated':
        await this.handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;

      case 'customer.subscription.deleted':
        await this.handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;

      case 'invoice.payment_succeeded':
        await this.handlePaymentSucceeded(event.data.object as Stripe.Invoice);
        break;

      case 'invoice.payment_failed':
        await this.handlePaymentFailed(event.data.object as Stripe.Invoice);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }
  }

  // Handle successful checkout
  private async handleCheckoutCompleted(session: Stripe.Checkout.Session) {
    const { organizationId, plan } = session.metadata!;

    const stripeSubscription = await stripe.subscriptions.retrieve(
      session.subscription as string
    );

    await prisma.subscription.upsert({
      where: { organizationId },
      create: {
        organizationId,
        stripeCustomerId: session.customer as string,
        stripeSubscriptionId: session.subscription as string,
        plan: plan as any,
        status: stripeSubscription.status.toUpperCase() as any,
        currentPeriodStart: new Date(stripeSubscription.current_period_start * 1000),
        currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000)
      },
      update: {
        stripeSubscriptionId: session.subscription as string,
        plan: plan as any,
        status: stripeSubscription.status.toUpperCase() as any,
        currentPeriodStart: new Date(stripeSubscription.current_period_start * 1000),
        currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000),
        cancelAtPeriodEnd: false
      }
    });

    // Update organization plan
    await prisma.organization.update({
      where: { id: organizationId },
      data: { plan: plan as any }
    });
  }

  // Handle subscription updates
  private async handleSubscriptionUpdated(subscription: Stripe.Subscription) {
    await prisma.subscription.update({
      where: { stripeSubscriptionId: subscription.id },
      data: {
        status: subscription.status.toUpperCase() as any,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        cancelAtPeriodEnd: subscription.cancel_at_period_end
      }
    });
  }

  // Handle subscription deletion
  private async handleSubscriptionDeleted(subscription: Stripe.Subscription) {
    const dbSubscription = await prisma.subscription.findFirst({
      where: { stripeSubscriptionId: subscription.id },
      include: { organization: true }
    });

    if (dbSubscription) {
      // Update subscription status
      await prisma.subscription.update({
        where: { id: dbSubscription.id },
        data: { status: 'CANCELED' }
      });

      // Downgrade organization to FREE plan
      await prisma.organization.update({
        where: { id: dbSubscription.organizationId },
        data: { plan: 'FREE' }
      });
    }
  }
}

export const subscriptionService = new SubscriptionService();
```

## 📊 Analytics Dashboard

### 1. Analytics Controller
```typescript
// src/features/analytics/analytics.controller.ts
import { z } from 'zod';
import { igniter } from '@/igniter/igniter';
import { authService } from '@/features/auth/auth.service';
import { analyticsService } from './analytics.service';

export const analyticsController = igniter.controller({
  name: 'analytics',
  description: 'Analytics and metrics tracking',
  middleware: [authService.requireAuth()],
  actions: {
    // Track event
    track: igniter.mutation({
      name: 'Track Event',
      description: 'Record analytics event',
      input: z.object({
        event: z.string(),
        properties: z.record(z.unknown()).optional(),
        userId: z.string().optional()
      }),
      output: z.object({ success: z.boolean() }),
      handler: async ({ input, ctx }) => {
        const { event, properties, userId } = input;
        const { organization } = ctx.auth;

        await analyticsService.track({
          event,
          properties,
          userId: userId || ctx.auth.user.id,
          organizationId: organization.id
        });

        return { success: true };
      }
    }),

    // Get dashboard metrics
    dashboard: igniter.query({
      name: 'Dashboard Metrics',
      description: 'Get organization dashboard metrics',
      input: z.object({
        period: z.enum(['7d', '30d', '90d']).default('30d')
      }),
      output: z.object({
        overview: z.object({
          totalUsers: z.number(),
          activeUsers: z.number(),
          totalSessions: z.number(),
          totalEvents: z.number()
        }),
        charts: z.object({
          userGrowth: z.array(z.object({
            date: z.string(),
            users: z.number()
          })),
          eventVolume: z.array(z.object({
            date: z.string(),
            events: z.number()
          })),
          topEvents: z.array(z.object({
            event: z.string(),
            count: z.number()
          }))
        })
      }),
      handler: async ({ input, ctx }) => {
        const { period } = input;
        const { organization } = ctx.auth;

        const metrics = await analyticsService.getDashboardMetrics({
          organizationId: organization.id,
          period
        });

        return metrics;
      }
    }),

    // Real-time metrics stream
    realtime: igniter.stream({
      name: 'Real-time Metrics',
      description: 'Stream real-time analytics data',
      input: z.object({
        metrics: z.array(z.string()).default(['events', 'users', 'sessions'])
      }),
      handler: async function* ({ input, ctx }) {
        const { metrics } = input;
        const { organization } = ctx.auth;

        // Stream real-time metrics every 5 seconds
        const interval = setInterval(async () => {
          const data = await analyticsService.getRealTimeMetrics({
            organizationId: organization.id,
            metrics
          });

          yield {
            event: 'metrics-update',
            data
          };
        }, 5000);

        // Clean up on disconnect
        ctx.onDisconnect(() => {
          clearInterval(interval);
        });
      }
    })
  }
});
```

### 2. Real-time Analytics with SSE
```typescript
// src/features/analytics/analytics.service.ts
import { PrismaClient } from '@prisma/client';
import { RedisClientType, createClient } from 'redis';

const prisma = new PrismaClient();
const redis = createClient({ url: process.env.REDIS_URL });

export class AnalyticsService {
  constructor() {
    redis.connect();
  }

  // Track analytics event
  async track({
    event,
    properties,
    userId,
    organizationId
  }: {
    event: string;
    properties?: Record<string, unknown>;
    userId: string;
    organizationId: string;
  }) {
    // Store event in database
    await prisma.analyticsEvent.create({
      data: {
        event,
        properties,
        userId,
        orgId: organizationId,
        timestamp: new Date()
      }
    });

    // Update real-time cache
    const cacheKey = `analytics:${organizationId}:realtime`;
    await redis.hIncrBy(cacheKey, `event:${event}`, 1);
    await redis.hIncrBy(cacheKey, 'total_events', 1);
    await redis.expire(cacheKey, 300); // 5 minutes

    // Track unique users
    const userKey = `analytics:${organizationId}:users:${new Date().toISOString().split('T')[0]}`;
    await redis.sAdd(userKey, userId);
    await redis.expire(userKey, 86400 * 7); // 7 days
  }

  // Get dashboard metrics
  async getDashboardMetrics({
    organizationId,
    period
  }: {
    organizationId: string;
    period: '7d' | '30d' | '90d';
  }) {
    const days = period === '7d' ? 7 : period === '30d' ? 30 : 90;
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    // Overview metrics
    const [totalUsers, activeUsers, totalSessions, totalEvents] = await Promise.all([
      prisma.organizationMember.count({
        where: { orgId: organizationId }
      }),
      prisma.analyticsEvent.groupBy({
        by: ['userId'],
        where: {
          orgId: organizationId,
          timestamp: { gte: startDate },
          userId: { not: null }
        }
      }).then(result => result.length),
      prisma.analyticsEvent.count({
        where: {
          orgId: organizationId,
          event: 'session_start',
          timestamp: { gte: startDate }
        }
      }),
      prisma.analyticsEvent.count({
        where: {
          orgId: organizationId,
          timestamp: { gte: startDate }
        }
      })
    ]);

    // Chart data
    const userGrowthData = await this.getUserGrowthData(organizationId, days);
    const eventVolumeData = await this.getEventVolumeData(organizationId, days);
    const topEventsData = await this.getTopEventsData(organizationId, days);

    return {
      overview: {
        totalUsers,
        activeUsers,
        totalSessions,
        totalEvents
      },
      charts: {
        userGrowth: userGrowthData,
        eventVolume: eventVolumeData,
        topEvents: topEventsData
      }
    };
  }

  // Real-time metrics from Redis
  async getRealTimeMetrics({
    organizationId,
    metrics
  }: {
    organizationId: string;
    metrics: string[];
  }) {
    const cacheKey = `analytics:${organizationId}:realtime`;
    const data = await redis.hGetAll(cacheKey);

    const result: Record<string, number> = {};

    for (const metric of metrics) {
      switch (metric) {
        case 'events':
          result.totalEvents = parseInt(data.total_events || '0');
          break;
        case 'users':
          const userKey = `analytics:${organizationId}:users:${new Date().toISOString().split('T')[0]}`;
          result.activeUsersToday = await redis.sCard(userKey);
          break;
        case 'sessions':
          result.activeSessions = await this.getActiveSessionsCount(organizationId);
          break;
      }
    }

    return result;
  }

  // Helper methods
  private async getUserGrowthData(organizationId: string, days: number) {
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const growth = await prisma.$queryRaw`
      SELECT DATE(created_at) as date, COUNT(*) as users
      FROM organization_members
      WHERE org_id = ${organizationId}
        AND created_at >= ${startDate}
      GROUP BY DATE(created_at)
      ORDER BY date
    ` as Array<{ date: string; users: bigint }>;

    return growth.map(item => ({
      date: item.date,
      users: Number(item.users)
    }));
  }

  private async getEventVolumeData(organizationId: string, days: number) {
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const volume = await prisma.$queryRaw`
      SELECT DATE(timestamp) as date, COUNT(*) as events
      FROM analytics_events
      WHERE org_id = ${organizationId}
        AND timestamp >= ${startDate}
      GROUP BY DATE(timestamp)
      ORDER BY date
    ` as Array<{ date: string; events: bigint }>;

    return volume.map(item => ({
      date: item.date,
      events: Number(item.events)
    }));
  }

  private async getTopEventsData(organizationId: string, days: number) {
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const events = await prisma.analyticsEvent.groupBy({
      by: ['event'],
      where: {
        orgId: organizationId,
        timestamp: { gte: startDate }
      },
      _count: { event: true },
      orderBy: { _count: { event: 'desc' } },
      take: 10
    });

    return events.map(item => ({
      event: item.event,
      count: item._count.event
    }));
  }

  private async getActiveSessionsCount(organizationId: string): Promise<number> {
    return prisma.session.count({
      where: {
        user: {
          memberships: {
            some: { orgId: organizationId }
          }
        },
        expiresAt: { gt: new Date() }
      }
    });
  }
}

export const analyticsService = new AnalyticsService();
```

## 🎨 Frontend Implementation

### 1. Next.js App Structure
```typescript
// src/app/layout.tsx
import { Inter } from 'next/font/google';
import { Providers } from '@/components/providers';
import { AuthProvider } from '@/features/auth/auth-provider';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: 'My SaaS Application',
  description: 'Built with Igniter.js',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>
          <AuthProvider>
            {children}
          </AuthProvider>
        </Providers>
      </body>
    </html>
  );
}
```

### 2. Dashboard with Real-time Analytics
```typescript
// src/app/(dashboard)/dashboard/page.tsx
'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/features/auth/use-auth';
import { useIgniterQuery, useIgniterStream } from '@/lib/igniter-client';
import { AnalyticsDashboard } from '@/components/analytics-dashboard';
import { MetricsCards } from '@/components/metrics-cards';

export default function DashboardPage() {
  const { user, organization } = useAuth();
  const [period, setPeriod] = useState<'7d' | '30d' | '90d'>('30d');

  // Get dashboard metrics
  const { data: metrics, isLoading } = useIgniterQuery({
    controller: 'analytics',
    action: 'dashboard',
    input: { period }
  });

  // Real-time metrics stream
  const { data: realtimeMetrics } = useIgniterStream({
    controller: 'analytics',
    action: 'realtime',
    input: { metrics: ['events', 'users', 'sessions'] }
  });

  if (isLoading) {
    return <DashboardSkeleton />;
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Welcome back, {user?.name}!
          </h1>
          <p className="text-muted-foreground">
            Here's what's happening with {organization?.name}
          </p>
        </div>

        {/* Period selector */}
        <select
          value={period}
          onChange={(e) => setPeriod(e.target.value as any)}
          className="rounded-md border border-input bg-background px-3 py-2"
        >
          <option value="7d">Last 7 days</option>
          <option value="30d">Last 30 days</option>
          <option value="90d">Last 90 days</option>
        </select>
      </div>

      {/* Metrics cards */}
      <MetricsCards
        metrics={metrics?.overview}
        realtimeMetrics={realtimeMetrics}
      />

      {/* Analytics dashboard */}
      <AnalyticsDashboard
        data={metrics?.charts}
        period={period}
      />
    </div>
  );
}
```

### 3. Real-time Components
```typescript
// src/components/metrics-cards.tsx
'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Users, Activity, BarChart3, Zap } from 'lucide-react';

interface MetricsCardsProps {
  metrics?: {
    totalUsers: number;
    activeUsers: number;
    totalSessions: number;
    totalEvents: number;
  };
  realtimeMetrics?: {
    totalEvents?: number;
    activeUsersToday?: number;
    activeSessions?: number;
  };
}

export function MetricsCards({ metrics, realtimeMetrics }: MetricsCardsProps) {
  const cards = [
    {
      title: 'Total Users',
      value: metrics?.totalUsers || 0,
      icon: Users,
      description: 'All registered users'
    },
    {
      title: 'Active Users',
      value: realtimeMetrics?.activeUsersToday || metrics?.activeUsers || 0,
      icon: Activity,
      description: 'Users active today',
      realtime: true
    },
    {
      title: 'Active Sessions',
      value: realtimeMetrics?.activeSessions || 0,
      icon: Zap,
      description: 'Currently online',
      realtime: true
    },
    {
      title: 'Total Events',
      value: realtimeMetrics?.totalEvents || metrics?.totalEvents || 0,
      icon: BarChart3,
      description: 'Events tracked today',
      realtime: true
    }
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {cards.map((card) => {
        const Icon = card.icon;
        return (
          <Card key={card.title} className={card.realtime ? 'border-green-200' : ''}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {card.title}
                {card.realtime && (
                  <span className="ml-2 inline-flex h-2 w-2 rounded-full bg-green-500 animate-pulse" />
                )}
              </CardTitle>
              <Icon className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {card.value.toLocaleString()}
              </div>
              <p className="text-xs text-muted-foreground">
                {card.description}
              </p>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
```

## 🚀 Production Deployment

### 1. Docker Configuration
```dockerfile
# Dockerfile
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=base /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/prisma ./prisma

# Generate Prisma client
RUN npx prisma generate

EXPOSE 3000
CMD ["npm", "start"]
```

### 2. Docker Compose for Development
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/my_saas
      - REDIS_URL=redis://redis:6379
      - NEXTAUTH_SECRET=your-secret-here
      - NEXTAUTH_URL=http://localhost:3000
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run dev

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=my_saas
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### 3. Production Deployment Script
```bash
#!/bin/bash
# scripts/deploy.sh

echo "🚀 Starting production deployment..."

# Build and push Docker image
echo "📦 Building Docker image..."
docker build -t my-saas:latest .

# Tag and push to registry
echo "📤 Pushing to registry..."
docker tag my-saas:latest your-registry/my-saas:latest
docker push your-registry/my-saas:latest

# Deploy to production
echo "🌍 Deploying to production..."
kubectl apply -f k8s/

# Run database migrations
echo "🗄️ Running database migrations..."
kubectl exec -it deployment/my-saas -- npx prisma migrate deploy

# Health check
echo "🏥 Running health check..."
sleep 30
kubectl get pods -l app=my-saas

echo "✅ Deployment complete!"
```

## 🎓 Learning Outcomes

By completing this tutorial, you've learned:

### ✅ **Technical Skills**
- **Full-stack TypeScript development** with type-safe APIs
- **Multi-tenant SaaS architecture** design and implementation
- **Subscription billing** integration with Stripe
- **Real-time features** using Server-Sent Events
- **Authentication and authorization** patterns
- **Database design** for scalable applications
- **Performance optimization** strategies
- **Production deployment** with Docker

### ✅ **Igniter.js Mastery**
- **Framework configuration** and advanced features
- **Controller and service patterns**
- **Middleware system** for authentication and validation
- **Real-time capabilities** with streaming APIs
- **Database integration** with Prisma and Redis
- **AI integration** capabilities
- **Testing and quality assurance**

### ✅ **Business Knowledge**
- **SaaS business model** implementation
- **Multi-tenancy** strategies and trade-offs
- **Subscription management** best practices
- **Analytics and metrics** tracking
- **User experience** design for SaaS applications
- **Scalability considerations**

## 🔗 Next Steps

### Extend Your Application
1. **Advanced Features**: Add team collaboration, file uploads, notifications
2. **Mobile App**: Build React Native or Flutter mobile client
3. **API Integrations**: Connect with third-party services
4. **Advanced Analytics**: ML-powered insights and predictions
5. **Multi-region**: Deploy across multiple regions for performance

### Production Optimizations
1. **Performance**: Implement caching strategies, CDN, database optimization
2. **Security**: Add rate limiting, CSRF protection, security headers
3. **Monitoring**: Set up logging, metrics, alerting, and error tracking
4. **Testing**: Add comprehensive test coverage and CI/CD pipeline
5. **Scaling**: Implement horizontal scaling and load balancing

### Community and Support
- **Documentation**: Contribute to Igniter.js documentation
- **Open Source**: Share components and patterns with community
- **Learning**: Join Discord, follow development updates
- **Contributing**: Report bugs, request features, submit PRs

---

*Congratulations! You've built a complete SaaS application with Igniter.js. This foundation can be extended and customized for virtually any SaaS use case.*