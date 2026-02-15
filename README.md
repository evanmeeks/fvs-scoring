# FVS Scoring System

A collaborative platform for forecast verification and evaluation of media claims using key quality metrics.

**Live:** [forecastaudit.pro](https://forecastaudit.pro)

## Demo Access

| Role  | Email                    | Password   |
|-------|--------------------------|------------|
| Admin | `demo@forecastaudit.pro` | `demo1234` |

## Tech Stack

- **Framework:** Next.js 15 (App Router, Turbopack)
- **Database:** Supabase (PostgreSQL, Row-Level Security)
- **Styling:** Tailwind CSS
- **Auth:** Supabase Auth (Google OAuth + email)
- **Deployment:** Netlify (SSR via @netlify/plugin-nextjs)
- **Type Safety:** TypeScript with t3-env validation

## FVS Protocol Metrics

The system evaluates forecasts across 10 standardized metrics in three categories:

**Core** - Forecast Specificity, Time Horizon Clarity, Probability Calibration, Source Credibility, Data Quality

**Integrity** - Resolution Criteria, Base Rate Awareness, Track Record

**Impact** - Methodology Transparency, Information Value

## Local Development

```bash
npm install
npx supabase start
npm run dev
```

## Database

```bash
npx supabase db reset    # Reset with migrations
npx supabase db push     # Push migrations to remote
npx supabase gen types typescript --local > src/types/supabase.ts
```
