/**
 * useUserDisplay Hook
 *
 * Centralizes all logic for displaying user identity based on privacy settings.
 * Handles three display contexts: public, private (user's own view), and admin.
 *
 * Usage:
 * const { displayName, contributorId, isAnonymous, isVerified } = useUserDisplay(profile, 'public');
 */

import { useMemo } from 'react';

/**
 * Display context determines what information can be shown
 * - public: What other users see (respects privacy settings)
 * - private: User viewing their own profile (shows real data)
 * - admin: Admin viewing user data (shows everything)
 */
export type DisplayContext = 'public' | 'private' | 'admin';

/**
 * User profile data (subset of user_profiles table)
 */
export interface UserProfile {
  user_id: string;
  contributor_id: string;
  pseudonym: string;
  full_name?: string | null;
  email?: string | null;
  anonymous?: boolean | null;
  oauth_provider?: string | null;
  oauth_handle?: string | null;
  oauth_verified?: boolean | null;
  oauth_verified_at?: string | null;
  oauth_profile_url?: string | null;
  bio?: string | null;
  avatar_url?: string | null;
  allow_public_profile?: boolean | null;
  role?: string;
}

/**
 * Return type from useUserDisplay hook
 */
export interface UserDisplayData {
  displayName: string;
  contributorId: string;
  isAnonymous: boolean;
  isVerified: boolean;
  avatarUrl?: string | null;
  bio?: string | null;
  realName?: string | null;
  email?: string | null;
  oauthProvider?: string | null;
  oauthHandle?: string | null;
  oauthProfileUrl?: string | null;
  verifiedAt?: string | null;
}

/**
 * Hook to get user display information based on context and privacy settings
 *
 * @param profile - User profile data from database
 * @param context - Display context (public/private/admin)
 * @returns UserDisplayData with appropriate fields based on context
 *
 * @example
 * // Public scorecard view
 * const { displayName, isVerified } = useUserDisplay(profile, 'public');
 * return <span>{displayName} {isVerified && <VerifiedBadge />}</span>;
 *
 * @example
 * // User's own profile page
 * const { displayName, realName, email } = useUserDisplay(profile, 'private');
 * return <div>Public: {displayName} / Private: {realName}</div>;
 *
 * @example
 * // Admin panel
 * const { displayName, email, oauthHandle } = useUserDisplay(profile, 'admin');
 * return <div>{displayName} ({email}) - OAuth: {oauthHandle}</div>;
 */
export function useUserDisplay(
  profile: UserProfile | null | undefined,
  context: DisplayContext = 'public'
): UserDisplayData {
  return useMemo(() => {
    // Default fallback for null/undefined profile
    if (!profile) {
      return {
        displayName: 'Anonymous',
        contributorId: 'FVS-00000',
        isAnonymous: true,
        isVerified: false,
      };
    }

    const {
      contributor_id,
      pseudonym,
      full_name,
      email,
      anonymous,
      oauth_provider,
      oauth_handle,
      oauth_verified,
      oauth_verified_at,
      oauth_profile_url,
      bio,
      avatar_url,
      allow_public_profile,
    } = profile;

    // Normalize boolean (handle null as true for backwards compatibility)
    const isAnonymousMode = anonymous !== false;
    const isOAuthVerified = oauth_verified === true;

    // =====================================================
    // ADMIN CONTEXT: Full transparency
    // =====================================================
    if (context === 'admin') {
      return {
        displayName: full_name || oauth_handle || email || pseudonym,
        contributorId: contributor_id,
        isAnonymous: isAnonymousMode,
        isVerified: isOAuthVerified,
        realName: full_name,
        email: email,
        oauthProvider: oauth_provider,
        oauthHandle: oauth_handle,
        oauthProfileUrl: oauth_profile_url,
        verifiedAt: oauth_verified_at,
        bio: bio,
        avatarUrl: avatar_url,
      };
    }

    // =====================================================
    // PRIVATE CONTEXT: User viewing their own profile
    // =====================================================
    if (context === 'private') {
      // User sees their own data but knows what public sees
      return {
        displayName: pseudonym,
        contributorId: contributor_id,
        isAnonymous: isAnonymousMode,
        isVerified: isOAuthVerified,
        realName: full_name,
        email: email,
        oauthProvider: oauth_provider,
        oauthHandle: oauth_handle,
        oauthProfileUrl: oauth_profile_url,
        verifiedAt: oauth_verified_at,
        bio: bio,
        avatarUrl: avatar_url,
      };
    }

    // =====================================================
    // PUBLIC CONTEXT: Respect privacy settings
    // =====================================================

    // Anonymous mode (default): Show only pseudonym
    if (isAnonymousMode) {
      return {
        displayName: pseudonym,
        contributorId: contributor_id,
        isAnonymous: true,
        isVerified: false,
        // Bio/avatar only if public profile allowed
        bio: allow_public_profile ? bio : null,
        avatarUrl: allow_public_profile ? avatar_url : null,
      };
    }

    // Verified mode: Show OAuth handle (if verified)
    if (isOAuthVerified && oauth_handle) {
      return {
        displayName: `@${oauth_handle}`,
        contributorId: contributor_id,
        isAnonymous: false,
        isVerified: true,
        oauthProvider: oauth_provider,
        oauthHandle: oauth_handle,
        oauthProfileUrl: oauth_profile_url,
        verifiedAt: oauth_verified_at,
        bio: allow_public_profile ? bio : null,
        avatarUrl: allow_public_profile ? avatar_url : null,
      };
    }

    // Public mode (rare): Show full name if provided
    if (full_name && !isAnonymousMode) {
      return {
        displayName: full_name,
        contributorId: contributor_id,
        isAnonymous: false,
        isVerified: false,
        realName: full_name,
        bio: allow_public_profile ? bio : null,
        avatarUrl: allow_public_profile ? avatar_url : null,
      };
    }

    // Fallback: Show pseudonym even if not in anonymous mode
    return {
      displayName: pseudonym,
      contributorId: contributor_id,
      isAnonymous: false,
      isVerified: false,
      bio: allow_public_profile ? bio : null,
      avatarUrl: allow_public_profile ? avatar_url : null,
    };
  }, [profile, context]);
}

/**
 * Helper function to format contributor ID with optional link
 */
export function formatContributorId(contributorId: string, linked: boolean = false): string {
  if (!linked) return contributorId;
  return `[${contributorId}](/user/${contributorId})`;
}

/**
 * Helper function to get display mode label
 */
export function getDisplayModeLabel(isAnonymous: boolean, isVerified: boolean): string {
  if (isAnonymous) return 'Anonymous';
  if (isVerified) return 'Verified';
  return 'Public';
}

/**
 * Helper function to generate identicon URL based on contributor ID
 * Uses DiceBear API for consistent, deterministic avatars
 */
export function generateIdenticonUrl(contributorId: string): string {
  // Use DiceBear Avatars (free, no API key required)
  // Style: "shapes" for geometric patterns
  return `https://api.dicebear.com/7.x/shapes/svg?seed=${encodeURIComponent(contributorId)}&backgroundColor=transparent`;
}

/**
 * Hook variant that includes generated avatar fallback
 */
export function useUserDisplayWithAvatar(
  profile: UserProfile | null | undefined,
  context: DisplayContext = 'public'
): UserDisplayData & { effectiveAvatarUrl: string } {
  const displayData = useUserDisplay(profile, context);

  const effectiveAvatarUrl = useMemo(() => {
    // Use custom avatar if set
    if (displayData.avatarUrl) {
      return displayData.avatarUrl;
    }

    // Use OAuth avatar if verified (in non-anonymous mode)
    if (!displayData.isAnonymous && displayData.oauthProvider) {
      // Could fetch OAuth avatar here if stored separately
      // For now, generate identicon
    }

    // Generate identicon from contributor ID
    return generateIdenticonUrl(displayData.contributorId);
  }, [displayData]);

  return {
    ...displayData,
    effectiveAvatarUrl,
  };
}
