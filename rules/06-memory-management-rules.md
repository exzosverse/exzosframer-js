# Memory Management Rules - Igniter.js Framework

## 💾 Persistent Memory & Knowledge Management System

### Core Memory Principles
- **Context preservation** - Maintain knowledge across sessions
- **Pattern recognition** - Identify and store reusable patterns
- **Relationship mapping** - Connect related concepts
- **Continuous learning** - Update knowledge from experience
- **Proactive retrieval** - Access relevant memories before tasks

## 📚 Memory Types & Classification

### Memory Type Hierarchy
```typescript
enum MemoryType {
  // User-specific memories
  USER_PREFERENCE = 'user_preference',           // Communication style, preferences
  USER_CONTEXT = 'user_context',                 // Project context, goals

  // Technical memories
  ARCHITECTURAL_DECISION = 'architectural_decision', // Design choices, rationales
  CODE_PATTERN = 'code_pattern',                    // Reusable code structures
  BUG_PATTERN = 'bug_pattern',                      // Common errors, solutions
  PERFORMANCE_INSIGHT = 'performance_insight',       // Optimizations, metrics

  // Learning memories
  INSIGHT = 'insight',                              // General learnings
  RELATIONSHIP_MAP = 'relationship_map',            // Concept connections
  WORKFLOW_PATTERN = 'workflow_pattern',            // Successful processes
}
```

### Memory Structure
```typescript
interface Memory {
  id: string;
  type: MemoryType;
  content: string;
  tags: string[];
  confidence: number;        // 0.0 to 1.0
  metadata: {
    created: Date;
    lastAccessed: Date;
    accessCount: number;
    source: 'user' | 'discovery' | 'inference';
    project?: string;
    relatedMemories?: string[];
  };
}
```

## 🎯 Memory Storage Strategy

### When to Store Memories

#### Explicit Storage Triggers
```typescript
// ✅ CORRECT: User explicitly requests storage
const explicitTriggers = [
  "remember this",
  "next time",
  "always do",
  "don't forget",
  "for future reference",
  "keep in mind"
];

// Store with high confidence when user is explicit
if (userMessage.includes(explicitTriggers)) {
  await storeMemory({
    type: MemoryType.USER_PREFERENCE,
    content: extractPreference(userMessage),
    confidence: 0.95,
    tags: ['explicit', 'user-requested'],
    source: 'user'
  });
}
```

#### Implicit Storage Triggers
```typescript
// ✅ CORRECT: Automatic pattern detection
const implicitTriggers = {
  // Successful solution patterns
  solutionSuccess: async (solution: Solution) => {
    if (solution.worked && solution.isNovel) {
      await storeMemory({
        type: MemoryType.CODE_PATTERN,
        content: solution.description,
        confidence: 0.8,
        tags: ['solution', solution.technology],
        source: 'discovery'
      });
    }
  },

  // Error patterns
  errorPattern: async (error: Error, solution: Solution) => {
    if (error.frequency > 2) {
      await storeMemory({
        type: MemoryType.BUG_PATTERN,
        content: `Error: ${error.message}\nSolution: ${solution.description}`,
        confidence: 0.85,
        tags: ['error', error.type],
        source: 'discovery'
      });
    }
  },

  // Performance improvements
  performanceGain: async (optimization: Optimization) => {
    if (optimization.improvement > 20) {
      await storeMemory({
        type: MemoryType.PERFORMANCE_INSIGHT,
        content: optimization.description,
        confidence: 0.9,
        tags: ['performance', optimization.area],
        source: 'discovery'
      });
    }
  }
};
```

## 🔍 Memory Retrieval Protocol

### Pre-Task Memory Search
```typescript
// ✅ CORRECT: Comprehensive memory search before tasks
const preTaskMemorySearch = async (task: Task) => {
  // 1. Search by direct keywords
  const keywordMemories = await searchMemories({
    keywords: extractKeywords(task),
    minConfidence: 0.7
  });

  // 2. Search by type
  const typeMemories = await searchMemoriesByType([
    MemoryType.ARCHITECTURAL_DECISION,
    MemoryType.CODE_PATTERN
  ]);

  // 3. Search related memories
  const relatedMemories = await searchRelatedMemories(
    keywordMemories.map(m => m.id)
  );

  // 4. Search user preferences
  const preferences = await searchMemoriesByType([
    MemoryType.USER_PREFERENCE
  ]);

  // 5. Combine and rank by relevance
  return rankMemoriesByRelevance([
    ...keywordMemories,
    ...typeMemories,
    ...relatedMemories,
    ...preferences
  ], task);
};
```

### Search Patterns
```typescript
// ✅ CORRECT: Multi-strategy search
const searchStrategies = {
  // Broad to narrow search
  broadToNarrow: async (query: string) => {
    const broad = await searchMemories({ keywords: [query] });
    const narrow = await searchMemories({
      keywords: query.split(' '),
      operator: 'AND'
    });
    return combineResults(broad, narrow);
  },

  // Type-specific search
  byType: async (type: MemoryType) => {
    return await searchMemoriesByType([type]);
  },

  // Tag combination search
  byTags: async (tags: string[], operator: 'AND' | 'OR' = 'AND') => {
    return await searchMemoriesByTags(tags, operator);
  },

  // Confidence-filtered search
  byConfidence: async (minConfidence: number = 0.7) => {
    const memories = await getAllMemories();
    return memories.filter(m => m.confidence >= minConfidence);
  }
};
```

## 🔗 Knowledge Graph & Relationships

### Relationship Types
```typescript
enum RelationshipType {
  IMPLEMENTS = 'implements',        // Pattern implements concept
  USES = 'uses',                   // Component uses another
  EXTENDS = 'extends',             // Builds upon existing
  CONTRADICTS = 'contradicts',     // Conflicts with
  SIMILAR_TO = 'similar_to',       // Related pattern
  DEPENDS_ON = 'depends_on',       // Requires another
  SUPERSEDES = 'supersedes',       // Replaces older approach
  DERIVED_FROM = 'derived_from'    // Based on another concept
}
```

### Building Knowledge Graphs
```typescript
// ✅ CORRECT: Creating memory relationships
const createMemoryRelationships = async (newMemory: Memory) => {
  // 1. Find related memories
  const related = await findRelatedMemories(newMemory);

  for (const relatedMemory of related) {
    // 2. Determine relationship type
    const relationshipType = determineRelationship(newMemory, relatedMemory);

    // 3. Create bidirectional relationship
    await relateMemories({
      sourceId: newMemory.id,
      targetId: relatedMemory.id,
      type: relationshipType,
      confidence: calculateRelationshipConfidence(newMemory, relatedMemory)
    });
  }

  // 4. Update knowledge graph
  await updateKnowledgeGraph(newMemory);

  // 5. Visualize if complex
  if (related.length > 5) {
    await visualizeMemoryGraph({
      centralNode: newMemory.id,
      depth: 2
    });
  }
};
```

### Knowledge Evolution
```typescript
// ✅ CORRECT: Evolving knowledge over time
const evolveKnowledge = async () => {
  // Update confidence based on usage
  const updateConfidence = async (memory: Memory) => {
    if (memory.metadata.accessCount > 10) {
      memory.confidence = Math.min(1.0, memory.confidence + 0.05);
    }
    if (memory.metadata.lastAccessed < thirtyDaysAgo) {
      memory.confidence = Math.max(0.5, memory.confidence - 0.1);
    }
  };

  // Supersede old patterns
  const supersedOldPatterns = async () => {
    const patterns = await searchMemoriesByType([MemoryType.CODE_PATTERN]);

    for (const pattern of patterns) {
      const newer = patterns.filter(p =>
        p.tags.some(tag => pattern.tags.includes(tag)) &&
        p.metadata.created > pattern.metadata.created &&
        p.confidence > pattern.confidence
      );

      if (newer.length > 0) {
        await relateMemories({
          sourceId: newer[0].id,
          targetId: pattern.id,
          type: RelationshipType.SUPERSEDES
        });
        pattern.confidence *= 0.8; // Reduce old pattern confidence
      }
    }
  };

  // Connect isolated memories
  const connectIsolatedMemories = async () => {
    const isolated = await findIsolatedMemories();

    for (const memory of isolated) {
      const similar = await findSimilarMemories(memory);
      if (similar.length > 0) {
        await relateMemories({
          sourceId: memory.id,
          targetId: similar[0].id,
          type: RelationshipType.SIMILAR_TO
        });
      }
    }
  };
};
```

## 🧠 Context-Aware Decision Making

### Memory-Informed Decisions
```typescript
// ✅ CORRECT: Use memories to inform decisions
const makeInformedDecision = async (decision: Decision) => {
  // 1. Retrieve relevant memories
  const memories = await preTaskMemorySearch(decision);

  // 2. Extract patterns from memories
  const patterns = memories
    .filter(m => m.type === MemoryType.CODE_PATTERN)
    .map(m => m.content);

  // 3. Check for contradictions
  const contradictions = memories
    .filter(m => m.type === MemoryType.ARCHITECTURAL_DECISION)
    .filter(m => conflictsWith(m, decision));

  if (contradictions.length > 0) {
    return {
      decision: 'needs_review',
      reason: 'Conflicts with architectural decisions',
      conflicts: contradictions
    };
  }

  // 4. Apply user preferences
  const preferences = memories
    .filter(m => m.type === MemoryType.USER_PREFERENCE);

  const adjustedDecision = applyPreferences(decision, preferences);

  // 5. Use successful patterns
  const approach = selectBestPattern(patterns, adjustedDecision);

  return {
    decision: adjustedDecision,
    approach,
    confidence: calculateConfidence(memories),
    basedOn: memories.map(m => m.id)
  };
};
```

## 📊 Memory Quality Management

### High-Quality Memory Criteria
```typescript
interface MemoryQuality {
  hasCleanContent: boolean;      // Clear, actionable content
  hasRelevantTags: boolean;      // Appropriate tags for discovery
  hasHighConfidence: boolean;    // Confidence >= 0.8
  hasContext: boolean;           // When/why it applies
  hasExamples: boolean;          // Specific implementations
  isVerifiable: boolean;         // Can be tested/validated
}

// ✅ CORRECT: Quality assessment before storage
const assessMemoryQuality = (memory: Memory): MemoryQuality => {
  return {
    hasCleanContent: memory.content.length > 50 && memory.content.length < 1000,
    hasRelevantTags: memory.tags.length >= 3 && memory.tags.length <= 10,
    hasHighConfidence: memory.confidence >= 0.8,
    hasContext: memory.content.includes('when') || memory.content.includes('context'),
    hasExamples: memory.content.includes('example') || memory.content.includes('```'),
    isVerifiable: memory.type !== MemoryType.INSIGHT // Most types are verifiable
  };
};
```

### Tag Management
```typescript
// ✅ CORRECT: Consistent tag strategy
const tagStrategy = {
  // Technical tags
  technical: ['typescript', 'igniter-js', 'react', 'nextjs', 'api'],

  // Contextual tags
  contextual: ['frontend', 'backend', 'database', 'authentication'],

  // Quality tags
  quality: ['tested', 'verified', 'experimental', 'deprecated'],

  // Project tags
  project: (projectName: string) => [`project:${projectName}`],

  // Feature tags
  feature: (featureName: string) => [`feature:${featureName}`],

  // Generate tags for memory
  generateTags: (memory: Memory): string[] => {
    const tags = new Set<string>();

    // Add type-based tags
    tags.add(memory.type);

    // Add technical tags from content
    tagStrategy.technical.forEach(tag => {
      if (memory.content.toLowerCase().includes(tag)) {
        tags.add(tag);
      }
    });

    // Add contextual tags
    tagStrategy.contextual.forEach(tag => {
      if (memory.content.toLowerCase().includes(tag)) {
        tags.add(tag);
      }
    });

    return Array.from(tags);
  }
};
```

## 🔄 Proactive Memory Management

### Memory Lifecycle
```typescript
// ✅ CORRECT: Complete memory lifecycle management
class MemoryLifecycle {
  // Creation phase
  async create(content: string, type: MemoryType): Promise<Memory> {
    const memory = {
      id: generateId(),
      type,
      content,
      tags: tagStrategy.generateTags({ content, type } as Memory),
      confidence: 0.7, // Start with moderate confidence
      metadata: {
        created: new Date(),
        lastAccessed: new Date(),
        accessCount: 0,
        source: 'discovery' as const
      }
    };

    await this.validate(memory);
    await this.store(memory);
    await this.createRelationships(memory);

    return memory;
  }

  // Access phase
  async access(id: string): Promise<Memory> {
    const memory = await this.retrieve(id);
    memory.metadata.lastAccessed = new Date();
    memory.metadata.accessCount++;

    // Boost confidence for frequently accessed
    if (memory.metadata.accessCount % 5 === 0) {
      memory.confidence = Math.min(1.0, memory.confidence + 0.02);
    }

    await this.update(memory);
    return memory;
  }

  // Evolution phase
  async evolve(id: string, feedback: Feedback): Promise<void> {
    const memory = await this.retrieve(id);

    if (feedback.type === 'positive') {
      memory.confidence = Math.min(1.0, memory.confidence + 0.1);
    } else if (feedback.type === 'negative') {
      memory.confidence = Math.max(0.3, memory.confidence - 0.15);
    }

    if (feedback.correction) {
      memory.content = feedback.correction;
      memory.metadata.source = 'user';
    }

    await this.update(memory);
  }

  // Deprecation phase
  async deprecate(id: string, replacementId?: string): Promise<void> {
    const memory = await this.retrieve(id);
    memory.tags.push('deprecated');
    memory.confidence *= 0.5;

    if (replacementId) {
      await relateMemories({
        sourceId: replacementId,
        targetId: id,
        type: RelationshipType.SUPERSEDES
      });
    }

    await this.update(memory);
  }

  // Cleanup phase
  async cleanup(): Promise<void> {
    // Remove very low confidence memories
    const lowConfidence = await searchMemories({
      maxConfidence: 0.3
    });

    for (const memory of lowConfidence) {
      if (memory.metadata.accessCount < 2) {
        await this.delete(memory.id);
      }
    }

    // Archive old, unused memories
    const oldUnused = await searchMemories({
      lastAccessedBefore: sixMonthsAgo,
      maxAccessCount: 5
    });

    for (const memory of oldUnused) {
      await this.archive(memory);
    }
  }
}
```

## 📋 Memory Management Checklist

### Before Storing Memory
- [ ] Verify content quality and clarity
- [ ] Assign appropriate type
- [ ] Generate relevant tags
- [ ] Set initial confidence level
- [ ] Check for duplicates

### During Retrieval
- [ ] Search multiple strategies
- [ ] Filter by confidence
- [ ] Consider recency
- [ ] Check relationships
- [ ] Update access metadata

### After Using Memory
- [ ] Update access count
- [ ] Adjust confidence if needed
- [ ] Store new insights
- [ ] Create new relationships
- [ ] Document usage outcome

### Periodic Maintenance
- [ ] Review low-confidence memories
- [ ] Connect isolated memories
- [ ] Update deprecated patterns
- [ ] Archive unused memories
- [ ] Optimize tag consistency

---

**Remember**: Memory is not just storage, it's active knowledge that evolves with use. Every interaction should inform future decisions, every pattern should be captured, and every insight should be connected to the growing knowledge graph.