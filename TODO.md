# TODO

## P0 — Launch blockers (must ship)

> **P00**: Add test cases for each task upon completion

### 1. Routing & Route Guards

- [x] **P0-1** Restructure routes: `/admin/*` and `/contributors/*` with stable ID-based canonical URLs
  - DoD: stable ID-based route, canonical URL, consistent params, share-safe
  - ✅ Created `/admin` layout with nested `/admin/` (index) route
  - ✅ Created `/contributors` layout with nested `/contributors/governance` route
  - ✅ Old routes redirect to new structure (`/governance` → `/contributors/governance`)
  - ✅ Updated Header navigation links to use new routes
- [x] **P0-2** Route guards + Supabase RLS alignment (UI access == DB access)
  - DoD: unauth/role violations blocked client + server
  - DoD: `/admin/*` + private contributor pages are `noindex`, public pages indexable
  - ✅ Route guards implemented at layout level using `ensureAdmin` and `ensureContributor`
  - ✅ SEO meta tags updated with `noindex` for `/admin` and `/contributors/governance`
  - ✅ Route guards align with Supabase RPC role checks (`is_admin`, `is_contributor`)

## 3. Sharing UX

**P0-6** Unified share UX: copy link + toast feedback, permission-aware (disabled with explanation when not allowed)

### Covers
- RFC proposals
- Individual votes
- Full scores
- User's own scores (opt-in public sharing)

### Goals
We want users to have a dedicated **result page** for content they've submitted, including:

- Their own submitted **scorecard** / vote for a target
- Their own submitted **proposed target**
- Contributor's various submitted **RFCs** / **Targets**

### Desired Submission + Share Flow
1. Right after submitting → show a clean **results page** for what was just submitted
2. On this page, give the user the option to **share it publicly** immediately

### Specific Submission Result Pages We Need
- **Target votes** result page
- **Target submissions** (proposed new targets) result page  
  → after submitting a new target proposal, show results page with share option
- **RFC submissions** result page  
  → after submitting an RFC proposal, show results page with share option

### Additional Notes
- These items are **not yet "submitted"** in a final sense (still editable/revokable) and should also appear on the **My Submissions** page:
  - Target metric votes (editable / revokable)
  - RFC submissions (editable / revokable)
- Already handled inline:
  - RFC votes (inline editable)
  - RFC notes (inline editable)

### Mockup Reference
![Share Score / Metric Vote UX](docs/share-score-metric-vote.png)
![Twitter Open Graph](docs/twitter-open-graph.png)


- [ ] **P0-3** Meta/OpenGraph/Twitter tags for all shareable pages (homepage, scorecard, RFC, votes)
- [ ] **P0-4** URL slug format: `[Case ID]-Target Name+[Primary Source Name]` — generated on target entry
- [ ] **P0-5** Robots/indexing policy (public vs auth vs contributor vs admin)

### 4. UI Consistency

- [ ] **P0-7** Unify Audit + Scorecard into single source of truth (remove duplicate)
- [ ] **P0-8** Fix ScoringSidebar: "Scorecard not available" message + content consistency on public routes
  - ![ScoringSidebar](docs/795b39f8-9fbe-44eb-b8d6-d037c0e0e2c6.jpg)
- [ ] **P0-9** Full scores as first view on landing page; scroll-sticky score element
  - <img   alt="image" src="docs/32d2f13c-a28b-4beb-91af-a7567600e81c.png" style="max-width: 100%;" />
- [ ] **P0-10** Rename "Total FVS Score" to clarify scope (session-based for public, user-based for logged-in)
- [x] **P0-11-A** Landing page tab navigation: "VIEW TARGET" button should switch to Consensus tab (not redirect to audit route)
  - DoD: Tab-based UX, no full page navigation, seamless engagement
  - DoD: Keep users on landing page for reduced friction
  - ✅ Updated CurrentTargetsView to navigate to `/global-consensus` route
  - ✅ Tab-based navigation supported via TanStack Router with `/audit-target`, `/global-consensus` routes
  - ✅ Renamed "Global Intel" to "Consensus" throughout the app
  - ✅ Renamed "Execute Audit" to "Audit Target" in navigation
  - ✅ Route URL updated to `/global-consensus` with proper SEO meta tags and Open Graph/Twitter Cards
  - ✅ Route URL updated: `/audit` → `/execute-audit` → `/audit-target` with proper SEO meta tags
  - ✅ Component renamed from GlobalIntelView to ConsensusView
  - ✅ Removed `/submit-audit/:slug` route (no longer needed)
  - ✅ All routes now use `createHeadConfig` with Open Graph and Twitter Card meta tags for social sharing
- [x] **P0-11-B** Enhance Consensus tab with immediate visual inspiration
  - DoD: Hero section with value prop + key visualizations
  - DoD: Recharts radar/bar charts for top-scored targets
  - DoD: Visual hierarchy: KPI cards → charts → drill-downs
  - DoD: Color intensity mapping (green-low to orange-high scores)
  - DoD: Responsive grid layout (Tailwind breakpoints)
  - DoD: Fetch data from Supabase (no static data, bundle queries)
  - ✅ Implemented real-time data fetching using `useTargetsWithScores` hook
  - ✅ Added dynamic KPI cards: Global Avg Score, Total Audits, Dominant Classification
  - ✅ Added Recharts BarChart for top 8 scored targets (horizontal layout)
  - ✅ Added Recharts RadarChart for classification distribution
  - ✅ Color intensity mapping based on score ranges (cyan/yellow/orange/red)
  - ✅ Responsive grid layout (mobile-first with Tailwind breakpoints)
  - ✅ Recent targets grid showing last 6 targets
  - ✅ Loading and error states with proper UX feedback
  - ✅ Hover effects and interactive charts (click to navigate to target)
- [ ] **P00-11-C** Add test cases for tab navigation and Global Intel data loading

### 5. Data Integrity

- [ ] **P0-12** No static data in core flows — all data from Supabase (static allowed only for display logic)
- [ ] **P0-13** Avoid N+1 fetch patterns on score pages (bundle queries, sensible caching/refetch)

### 6. Error States & UX Polish
- [ ] **P0-14** Consistent loading states (skeletons) + empty states ("no votes yet", "no targets yet")
- [ ] **P0-15** Graceful handling of missing/invalid IDs on shareable pages (404 / not found / permissions)

---

## P1 — Next up (strongly recommended)

### Supabase ops & CI

- [ ] **(P1)** Create `.github/workflows/backup-supabase.yml` for automated prod dumps
- [ ] **(P1)** Add secrets: `SUPABASE_DB_URL`, `SUPABASE_ACCESS_TOKEN`
- [ ] **(P1)** Implement migration CI check workflow
- [ ] **(P1)** Enable Supabase Branching for preview environments
- [ ] **(P1)** (Optional) Set up staging Supabase project + Netlify preview URL mapping

### Governance vs community voting separation

- [x] **(P1)** Simplify governance voting UX — removed heavy KEEP/ENDORSE/DROP pattern
  - ✅ Replaced dropdown with **Low/Medium/High confidence buttons** (one-click voting)
  - ✅ Made notes truly optional (expandable "+ Add note" button, not always visible)
  - ✅ Removed redundant "KEEP (Endorse)" verbose language
  - ✅ Reduced cognitive load: contributors can vote quickly without chore-level effort
  - ✅ Updated MetricTable governance mode with simplified UI
  - ✅ Updated governance route to handle confidence-based voting
- [ ] **(P1)** Scorecards (Contributors) are for *governance of metrics*, not communal voting
- [ ] <img  alt="image" src="docs/d4f7abc6-216c-40a8-84ce-75764eb0f0ab.png" style="max-width: 100%;" />
- [ ] <img   alt="image" src="docs/ca9a6962-a07f-4155-8fa9-bdffce727402.png" style="max-width: 100%;" />
- [ ] <img   alt="image" src="docs/8283de72-330c-43a1-840d-9c20e7c6a6d2.png" style="max-width: 100%;" />
- DoD: governance UI surfaces metric RFC/decisions; community voting UI separate

### Data visualization / UX polish (P1)
Note CURRENT TARGETS view in proposal view
.claude/proposed-ui/ScoreCardVewPublicGlobalAudtCards.html
- [ ] <img  alt="image" src="docs/CURRENT_TARGETS.png" style="max-width: 100%;" />
file:///Users/dijkstra/Documents/GitHub/fvs-scoring-system-ts/.claude/proposed-ui/ScoreCardVewPublicGlobalAudtCards.html

Add each of the following contexts to the database with lowercase `slug` values (snake_case shown below). Use the Title Case version for the human-facing label; keep the note in parentheses as the description/context.

- academic_symposium (existing: e.g., conferences like Sol Foundation)
- scientific_paper (peer-reviewed publications or journal articles analyzing data)
- academic_thesis (graduate-level research or dissertations on related topics)
- research_grant_proposal (funding requests outlining studies on phenomena)
- media_broadcast (existing: e.g., TV interviews like David Grusch on NewsNation)
- public_statement (existing: e.g., official announcements or project updates)
- documentary_film (long-form videos or series exploring evidence)
- podcast_episode (audio interviews or discussions, e.g., with whistleblowers)
- press_conference (live events by officials or organizations)
- book_publication (non-fiction books detailing accounts or investigations)
- government_report (existing: e.g., AARO Historical Report)
- classified_proceeding (existing: e.g., internal briefings or SCIF sessions)
- declassified_document (released memos, files, or archives)
- congressional_hearing (testimony before legislative bodies)
- press_release (official statements from agencies like DoD or NASA)
- international_agreement (treaties or joint statements between countries)
- legal_filing (court documents, lawsuits, or FOIA requests/responses)
- witness_testimony (existing: e.g., interviews like Kiran Ilyumzhinov)
- whistleblower_account (insider revelations from government or military personnel)
- eyewitness_sketch (drawings or descriptions from direct observers)
- legal_deposition (sworn statements in legal proceedings)
- visual_evidence (existing: e.g., UAP videos like Jellyfish)
- forensic_claim (existing: e.g., Nazca Mummies analysis)
- material_sample (physical artifacts tested for composition)
- archaeological_find (historical artifacts linked to phenomena)
- viral_narrative (existing: e.g., social media incidents like Miami Mall)
- social_media_post (individual or threaded posts amplifying claims)
- forum_discussion (online community threads, e.g., Reddit or specialized sites)
- leaked_media (hacked or anonymously released files – note: focus on analysis, not acquisition)
- hacked_and_leaked (hacked or anonymously released files – note: focus on analysis, not acquisition)
- anonymous_forum_leak (anonymous postings on imageboards like 4chan, often involving unverified insider claims, images, or documents about UAPs or NHI)
- 4chan_leak (anonymous postings on imageboards like 4chan, often involving unverified insider claims, images, or documents about UAPs or NHI)
- patent_application (inventions related to tech derived from phenomena)

### Data visualization / UX polish (P2)

- [ ] **(P1)** Enhance data visualization to match HTML style guides
- [ ] <img alt="image" src="docs/d9f9c86b-a184-439f-b400-f478c130ee78.png" style="max-width: 100%;" />
- [ ] <img alt="image" src="docs/e38589e7-c742-4ae2-86b6-beb0bc4ebb4f.png" style="max-width: 100%;" />
- [ ] <img alt="image" src="docs/1f299f64-84f4-4efb-a178-b04377930336.png" style="max-width: 100%;" />
- [ ] <img alt="image" src="docs/d4f7abc6-216c-40a8-84ce-75764eb0f0ab.png" style="max-width: 100%;" />
- [ ] <img alt="image" src="docs/8283de72-330c-43a1-840d-9c20e7c6a6d2.png" style="max-width: 100%;" />
- [ ] **(P1)** Explore visualization spreads (layout variants / density / responsive behavior)

### Observability / auditability
- [ ] **(P1)** Lightweight audit log (vote submit, approval actions, rejections)
  - DoD: minimal event table + actor + timestamp + target ids
- [ ] **(P1)** Basic telemetry hooks for failures (vote submit errors, load errors)

### Performance / quality gates
- [ ] **(P1)** Lighthouse sanity pass targets (perf/accessibility/SEO) on key public routes

## P2 — Discovery / product experiments (nice to have)

### Logged-in incentives / experience
- [ ] **(P2)** Investigate logged-in incentive routes (targets, comparisons, deeper views)
- [ ] **(P2)** Explore: allow logged-in users to submit Target Entries
- [ ] **(P2)** Explore: allow logged-in users to see detailed / consensus views / extra visualizations
- [ ] **(P2)** Explore: compare scoring (self vs consensus, deltas, trends)

### Anonymous voting (with safeguards + moderation flow)
- [ ] **(P2)** Add anonymous vote submission (rate limits + throttling to reduce DoS/spam)
- [ ] **(P2)** Add moderation queue: anonymous votes are “pending” until Contributors approve
  - DoD: pending → approved/rejected + reviewer actions recorded
- [ ] **(P2)** Optional safety toggles: CAPTCHA / stricter throttles during attack windows
