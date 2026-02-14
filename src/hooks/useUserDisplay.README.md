# useUserDisplay Hook

Centralizes all logic for displaying user identity based on privacy settings and context.

## Quick Start

```typescript
import { useUserDisplay } from '@/hooks/useUserDisplay';

function UserCard({ userId }) {
  const { profile } = useUserProfile(userId);
  const { displayName, isVerified, contributorId } = useUserDisplay(profile, 'public');

  return (
    <div>
      <span>{displayName}</span>
      {isVerified && <VerifiedBadge />}
      <span className="text-muted">{contributorId}</span>
    </div>
  );
}
```

---

## Display Contexts

### `public` - What other users see

Respects privacy settings:
- **Anonymous mode**: Shows pseudonym only
- **Verified mode**: Shows OAuth handle with verified badge
- **Public mode**: Shows full name (rare)

```typescript
const { displayName } = useUserDisplay(profile, 'public');
// Anonymous: "SwiftAnalyst042"
// Verified: "@github-handle"
// Public: "John Doe"
```

### `private` - User viewing their own profile

Shows real data but pseudonym as display:
```typescript
const { displayName, realName, email } = useUserDisplay(profile, 'private');
// displayName: "SwiftAnalyst042"
// realName: "John Doe"
// email: "john@example.com"
```

### `admin` - Admin panel view

Full transparency, all data visible:
```typescript
const { displayName, email, oauthHandle } = useUserDisplay(profile, 'admin');
// displayName: "John Doe" (or email if no name)
// email: "john@example.com"
// oauthHandle: "github-username"
```

---

## Return Values

```typescript
interface UserDisplayData {
  displayName: string;          // Primary name to show
  contributorId: string;         // FVS-00001 format
  isAnonymous: boolean;          // Privacy mode
  isVerified: boolean;           // OAuth verified?

  // Conditional fields (based on context)
  avatarUrl?: string | null;
  bio?: string | null;
  realName?: string | null;
  email?: string | null;
  oauthProvider?: string | null;
  oauthHandle?: string | null;
  oauthProfileUrl?: string | null;
  verifiedAt?: string | null;
}
```

---

## Common Use Cases

### 1. Public Scorecard Attribution

```typescript
function ScorecardHeader({ userId }) {
  const { profile } = useUserProfile(userId);
  const { displayName, isVerified, contributorId } = useUserDisplay(profile, 'public');

  return (
    <div>
      <h3>{displayName}</h3>
      {isVerified && <VerifiedBadge />}
      <span className="text-muted">{contributorId}</span>
    </div>
  );
}
```

### 2. User's Own Profile Page

```typescript
function MyProfile() {
  const { user } = useAuth();
  const { profile } = useUserProfile(user.id);
  const { displayName, realName, email, isAnonymous } = useUserDisplay(profile, 'private');

  return (
    <div>
      <h1>Your Profile</h1>
      <p>Public display: <strong>{displayName}</strong></p>
      <p>Real name: {realName}</p>
      <p>Email: {email}</p>
      <p>Privacy mode: {isAnonymous ? 'Anonymous' : 'Verified'}</p>
    </div>
  );
}
```

### 3. Admin User Management

```typescript
function AdminUserRow({ userId }) {
  const { profile } = useUserProfile(userId);
  const { displayName, email, oauthHandle, contributorId } = useUserDisplay(profile, 'admin');

  return (
    <tr>
      <td>{contributorId}</td>
      <td>{displayName}</td>
      <td>{email}</td>
      <td>{oauthHandle || 'Not verified'}</td>
    </tr>
  );
}
```

### 4. Activity Feed

```typescript
function ActivityItem({ activity }) {
  const { profile } = useUserProfile(activity.user_id);
  const { displayName, contributorId } = useUserDisplay(profile, 'public');

  return (
    <div>
      <span className="font-mono text-primary">{contributorId}</span>
      <span className="ml-2">{displayName}</span>
      <span className="text-muted ml-2">{activity.action}</span>
    </div>
  );
}
```

---

## Privacy Logic Flow

```
User Profile
    ↓
Is context "admin"? → YES → Show everything
    ↓ NO
Is context "private"? → YES → Show user's own data
    ↓ NO
Is anonymous = true? → YES → Show pseudonym only
    ↓ NO
Is oauth_verified = true? → YES → Show @handle ✓
    ↓ NO
Has full_name? → YES → Show full name
    ↓ NO
Fallback → Show pseudonym
```

---

## Helper Functions

### `formatContributorId(contributorId, linked)`

Format contributor ID with optional markdown link:
```typescript
formatContributorId('FVS-00001', false);
// "FVS-00001"

formatContributorId('FVS-00001', true);
// "[FVS-00001](/user/FVS-00001)"
```

### `getDisplayModeLabel(isAnonymous, isVerified)`

Get human-readable mode label:
```typescript
getDisplayModeLabel(true, false);   // "Anonymous"
getDisplayModeLabel(false, true);   // "Verified"
getDisplayModeLabel(false, false);  // "Public"
```

### `generateIdenticonUrl(contributorId)`

Generate deterministic avatar URL:
```typescript
generateIdenticonUrl('FVS-00001');
// "https://api.dicebear.com/7.x/shapes/svg?seed=FVS-00001&..."
```

---

## Advanced: With Avatar Fallback

```typescript
import { useUserDisplayWithAvatar } from '@/hooks/useUserDisplay';

function UserAvatar({ userId }) {
  const { profile } = useUserProfile(userId);
  const { displayName, effectiveAvatarUrl } = useUserDisplayWithAvatar(profile, 'public');

  return (
    <div>
      <img src={effectiveAvatarUrl} alt={displayName} />
      <span>{displayName}</span>
    </div>
  );
}
```

The `effectiveAvatarUrl` will:
1. Use custom `avatar_url` if set
2. Fall back to generated identicon based on `contributor_id`

---

## Testing

Run tests:
```bash
bun test src/hooks/__tests__/useUserDisplay.test.ts
```

The test suite covers:
- All three contexts (public/private/admin)
- All privacy modes (anonymous/verified/public)
- Edge cases (null profiles, missing data)
- Backwards compatibility

---

## Migration Notes

When migrating existing components:

**Before:**
```typescript
const userName = userProfile?.full_name || 'Anonymous User';
```

**After:**
```typescript
const { displayName } = useUserDisplay(userProfile, 'public');
```

This ensures consistent privacy handling across the entire app.

---

## Common Mistakes

❌ **Don't** hardcode display logic
```typescript
// BAD
const displayName = user.oauth_verified ? user.oauth_handle : user.pseudonym;
```

✅ **Do** use the hook
```typescript
// GOOD
const { displayName } = useUserDisplay(profile, 'public');
```

❌ **Don't** expose sensitive data in public context
```typescript
// BAD
const { email } = useUserDisplay(profile, 'public');
// email will be undefined - use 'private' or 'admin' context
```

✅ **Do** choose the right context
```typescript
// GOOD
const { email } = useUserDisplay(profile, 'private');
```

---

## See Also

- [CONTRIBUTOR_VERIFICATION.md](../../../CONTRIBUTOR_VERIFICATION.md) - Verification policy
- [PHASED_ROLLOUT_PLAN.md](../../../PHASED_ROLLOUT_PLAN.md) - Rollout strategy
- `VerifiedBadge` component - Visual badge for verified users
