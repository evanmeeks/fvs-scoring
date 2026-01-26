# Type Conventions & Best Practices

## Overview
This project uses **Supabase-generated types as the single source of truth** for database schema synchronization with TypeScript. This document outlines the type architecture and conventions.

## Architecture

```
PostgreSQL Schema (Supabase)
    ↓ (supabase gen types)
src/types/supabase.ts (GENERATED - never edit manually)
    ↓ (derive from)
src/types/database.ts (Helper utilities)
    ↓ (extend/transform)
src/types/metrics.ts (Domain-specific types)
    ↓ (export all)
src/types/index.ts (Central export point)
```

## File Structure

### `src/types/supabase.ts` (Generated)
- **NEVER edit manually**
- Generated via: `npm run db:types` (local) or `npm run db:types:remote` (production)
- Source of truth for all database tables, columns, enums, and functions
- Committed to version control

### `src/types/database.ts` (Helper Utilities)
Contains utility types for easier access to Supabase types:

```typescript
// Shorthand for table rows
export type Tables<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Row'];

// Shorthand for inserts
export type Inserts<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Insert'];

// Shorthand for updates
export type Updates<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Update'];

// Enum types
export type Enums<T extends keyof Database['public']['Enums']> =
  Database['public']['Enums'][T];
```

### `src/types/metrics.ts` (Domain Types)
Application-specific types for business logic. These should be:
- **Derived from database types** when possible
- **Extended with UI state** when needed for frontend

### `src/types/index.ts` (Central Export)
Single entry point for all type imports.

## Type Patterns

### ✅ Pattern 1: Exact Database Type
Use when you need the exact database representation:

```typescript
import { Tables } from '../types/database';

export type Score = Tables<'scores'>;
export type Target = Tables<'targets'>;
```

**Benefits:**
- Automatic updates when schema changes
- Type safety for database operations
- No manual maintenance

### ✅ Pattern 2: Extended Type
Use when you need database type + UI state:

```typescript
import { Tables } from '../types/database';

type BaseScore = Tables<'scores'>;

export type ScoreWithMetadata = BaseScore & {
  contributor_name?: string;
  isPublished: boolean;  // UI-only property
};
```

### ✅ Pattern 3: Derived/Partial Type
Use when you need only specific fields:

```typescript
import { Tables } from '../types/database';

type Score = Tables<'scores'>;

// For form submissions
export type ScoreSubmission = Pick<Score, 'target_id' | 'metric_id' | 'value' | 'rationale'>;

// For updates
export type ProfileUpdate = Partial<Pick<Tables<'user_profiles'>, 'full_name' | 'website'>>;
```

### ❌ Anti-Pattern: Manual Interfaces
**DON'T** create interfaces that duplicate database structure:

```typescript
// ❌ BAD - will drift from database
export interface Score {
  id: string;
  target_id: string;
  metric_id: string;
  value: number;
  // ... prone to getting out of sync
}

// ✅ GOOD - always in sync
export type Score = Tables<'scores'>;
```

## Syncing Process

### Manual Sync
When you change the database schema:

1. Make schema changes (Supabase Dashboard or migrations)
2. Run `npm run db:types` (local) or `npm run db:types:remote` (production)
3. TypeScript compiler will flag all breaking changes
4. Fix errors → commit updated types file

### Commands
```bash
# Local database
npm run db:types

# Remote (production)
npm run db:types:remote
```

## Reference Data Pattern

For static reference data (like origin types, context types), we use **TypeScript files** with export constants:

```typescript
// src/data/originTypes.ts
export interface OriginType {
  slug: string;
  label: string;
  abbreviation: string;
  description: string;
  sortOrder: number;
}

export const ORIGIN_TYPES: OriginType[] = [
  { slug: "ic_national", label: "US Intelligence Community", ... },
  // ...
];

export const getOriginLabel = (slug?: string | null): string => {
  const originType = ORIGIN_TYPES.find((ot) => ot.slug === slug);
  return originType?.label || slug || "Unknown";
};
```

**Why not tRPC?**
- tRPC requires a Node.js backend server
- Supabase provides equivalent end-to-end type safety
- Direct client-to-database architecture removes the need for middleware
- Use tRPC only if you add a custom API layer in the future

## Type Safety Checklist

- [ ] All database types derived from `Tables<'table_name'>`
- [ ] No manual interfaces duplicating database schema
- [ ] Helper functions typed with database types
- [ ] Component props using derived types
- [ ] Form types using `Pick` or `Omit` from database types
- [ ] API responses typed with database types

## Migration Guide

When converting manual types to database-derived:

1. **Read the generated file**: Check `src/types/supabase.ts` for available tables
2. **Replace interface**: Change manual interface to `type Foo = Tables<'foos'>`
3. **Fix errors**: TypeScript will show where names/types differ
4. **Test**: Ensure runtime behavior unchanged

## Benefits

✅ **Single Source of Truth**: Database schema defines all types
✅ **Breaking Changes Caught Early**: TypeScript errors on schema changes
✅ **No Type Drift**: Generated types can't get out of sync
✅ **Faster Development**: No manual type maintenance
✅ **Better Refactoring**: Rename columns and TypeScript finds all usages

## Future Considerations

- **CI/CD Integration**: Auto-generate types in GitHub Actions after migrations
- **Type Versioning**: Consider versioning types if supporting multiple API versions
- **Reference Tables**: Move static data (origin/context types) to database tables when scalability becomes a concern
