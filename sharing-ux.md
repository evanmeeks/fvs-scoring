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
