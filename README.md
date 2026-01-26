# FVS Scoring System [![Netlify Status](https://api.netlify.com/api/v1/badges/af19edd2-521d-4308-a327-bf2c77603433/deploy-status)](https://app.netlify.com/projects/fvs-metrics/deploys)

A collaborative platform for forecast verification and evaluation of media claims using key quality metrics.

## Features

- **10 Metrics**: Specificity, Causal Direction, Actionability, Information Novelty, Attribution Integrity, Risk Assumed, Resistance to Myth, Power Targeting, Timing Coherence, Intel. Discipline
- **1-5 Scoring Scale**: Discrete scoring with detailed criteria for each level
- **Community Consensus**: Real-time vote aggregation and statistical analysis
- **User Authentication**: Secure OAuth login (Google, GitHub, Apple, Azure)
- **Role-Based Access**: Admin, Contributor, and User roles
- **Target Submissions**: Community-driven target proposal and review system
- **RFC Governance**: Propose and vote on metric changes
- **Real-time Updates**: Live collaboration and activity tracking

## Tech Stack

- **Frontend**: React 19 + TypeScript + TanStack Router + Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Charts**: Recharts
- **Icons**: Lucide React
- **Build Tool**: Vite

## Quick Start

### 1. Prerequisites

- Node.js 20+
- Bun (recommended) or npm
- Supabase account

### 2. Install Dependencies

```bash
bun install
# or
npm install
```

### 3. Set Up Supabase

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key
3. Run migrations:

```bash
supabase link --project-ref your-project-ref
supabase db push
```

### 4. Configure Environment

Create a `.env.local` file:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_KEY=your-anon-key
VITE_SITE_URL=http://localhost:5173
```

For production, set `VITE_SITE_URL` to your deployed URL.

### 5. Run Development Server

```bash
bun run dev
# or
npm run dev
```

The app will be available at `http://localhost:5173`

## Project Structure

```
src/
├── components/
│   ├── layout/          # Header, Sidebar, Layout
│   ├── shared/          # Reusable UI components
│   ├── views/           # Main application views
│   │   └── landing/     # Audit, Consensus, Governance views
│   ├── AdminReviewPanel.tsx
│   ├── AuthModal.tsx
│   └── ...
├── contexts/
│   └── AppContext.tsx   # Global application state
├── hooks/
│   └── useSupabase.ts   # Supabase client hooks
├── routes/              # TanStack Router routes
├── types/
│   └── supabase.ts      # Generated database types
├── utils/
│   ├── database.ts      # Database type mappings
│   └── supabase.ts      # Supabase client setup
└── App.tsx
```

## The 10 Metrics

1. **Specificity of Claims** - Are concrete entities named?
2. **Causal Direction** - Does it explain HOW information advances understanding?
3. **Actionability** - Can investigators act on this?
4. **Information Novelty** - Is this meaningfully new intelligence?
5. **Attribution Integrity** - Are sources acknowledged?
6. **Risk Assumed** - Does the claim impose risk on the speaker?
7. **Resistance to Myth** - Is information grounded or mythologized?
8. **Power Targeting** - Does it challenge real power structures?
9. **Timing Coherence** - Does timing serve truth, not hype cycles?
10. **Intel. Discipline** - Is operational literacy demonstrated?

Each metric has a 1-5 scoring scale with detailed criteria.

## Key Features

### Target Submission & Review
- Users can submit new targets for evaluation
- Admin review and approval workflow
- Case ID tracking system

### Community Voting
- Vote on targets across all metrics
- Confidence levels and rationale
- Real-time consensus calculation

### RFC Governance
- Propose changes to metrics
- Community voting on proposals
- Version tracking

### Admin Panel
- Review and approve target submissions
- Manage user roles
- Monitor system activity

## Development

### Database Migrations

```bash
# Create a new migration
supabase migration new migration_name

# Apply migrations locally
supabase db reset

# Push to production
supabase db push --linked
```

### Type Generation

Database types are auto-generated from Supabase schema:

```bash
bun run db:types
```

### Build for Production

```bash
bun run build
# or
npm run build
```

### Lint

```bash
bun run lint
# or
npm run lint
```

## Deployment

The project includes GitHub Actions workflows for:
- **Migrations Check**: Validates migration file naming
- **Deploy**: Pushes migrations and generates types
- **Version & Tag**: Automated versioning

### Environment Variables (Production)

Set these in your deployment platform:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_KEY=your-anon-key
VITE_SITE_URL=https://your-production-domain.com
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT

---

Built with ❤️ for transparent forecast evaluation
