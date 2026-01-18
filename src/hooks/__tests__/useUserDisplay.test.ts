/**
 * Tests for useUserDisplay hook
 *
 * Verifies that user identity is displayed correctly based on:
 * - Privacy mode (anonymous/verified/public)
 * - Context (public/private/admin)
 * - OAuth verification status
 */

import { renderHook } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useUserDisplay, type UserProfile } from '../useUserDisplay';

describe('useUserDisplay', () => {
  const mockProfile: UserProfile = {
    user_id: 'abc-123',
    contributor_id: 'FVS-00001',
    pseudonym: 'SwiftAnalyst042',
    full_name: 'John Doe',
    email: 'john@example.com',
    anonymous: true,
    oauth_provider: 'github',
    oauth_handle: 'johndoe',
    oauth_verified: false,
    oauth_verified_at: null,
    oauth_profile_url: 'https://github.com/johndoe',
    bio: 'FVS analyst',
    avatar_url: 'https://example.com/avatar.jpg',
    allow_public_profile: true,
    role: 'contributor',
  };

  describe('Public Context', () => {
    it('shows pseudonym when in anonymous mode', () => {
      const { result } = renderHook(() =>
        useUserDisplay(mockProfile, 'public')
      );

      expect(result.current.displayName).toBe('SwiftAnalyst042');
      expect(result.current.contributorId).toBe('FVS-00001');
      expect(result.current.isAnonymous).toBe(true);
      expect(result.current.isVerified).toBe(false);
    });

    it('shows OAuth handle when verified and not anonymous', () => {
      const verifiedProfile: UserProfile = {
        ...mockProfile,
        anonymous: false,
        oauth_verified: true,
        oauth_verified_at: '2024-01-15T10:00:00Z',
      };

      const { result } = renderHook(() =>
        useUserDisplay(verifiedProfile, 'public')
      );

      expect(result.current.displayName).toBe('@johndoe');
      expect(result.current.isAnonymous).toBe(false);
      expect(result.current.isVerified).toBe(true);
      expect(result.current.oauthHandle).toBe('johndoe');
      expect(result.current.oauthProvider).toBe('github');
    });

    it('shows full name when in public mode (not anonymous, not verified)', () => {
      const publicProfile: UserProfile = {
        ...mockProfile,
        anonymous: false,
        oauth_verified: false,
      };

      const { result } = renderHook(() =>
        useUserDisplay(publicProfile, 'public')
      );

      expect(result.current.displayName).toBe('John Doe');
      expect(result.current.isAnonymous).toBe(false);
      expect(result.current.isVerified).toBe(false);
      expect(result.current.realName).toBe('John Doe');
    });

    it('hides bio/avatar when public profile not allowed', () => {
      const privateProfile: UserProfile = {
        ...mockProfile,
        allow_public_profile: false,
      };

      const { result } = renderHook(() =>
        useUserDisplay(privateProfile, 'public')
      );

      expect(result.current.bio).toBeNull();
      expect(result.current.avatarUrl).toBeNull();
    });

    it('shows bio/avatar when public profile allowed', () => {
      const { result } = renderHook(() =>
        useUserDisplay(mockProfile, 'public')
      );

      expect(result.current.bio).toBe('FVS analyst');
      expect(result.current.avatarUrl).toBe('https://example.com/avatar.jpg');
    });

    it('handles null/undefined profile gracefully', () => {
      const { result: nullResult } = renderHook(() =>
        useUserDisplay(null, 'public')
      );

      expect(nullResult.current.displayName).toBe('Anonymous');
      expect(nullResult.current.contributorId).toBe('FVS-00000');
      expect(nullResult.current.isAnonymous).toBe(true);

      const { result: undefinedResult } = renderHook(() =>
        useUserDisplay(undefined, 'public')
      );

      expect(undefinedResult.current.displayName).toBe('Anonymous');
    });
  });

  describe('Private Context', () => {
    it('shows pseudonym as display name but includes real data', () => {
      const { result } = renderHook(() =>
        useUserDisplay(mockProfile, 'private')
      );

      expect(result.current.displayName).toBe('SwiftAnalyst042');
      expect(result.current.realName).toBe('John Doe');
      expect(result.current.email).toBe('john@example.com');
      expect(result.current.oauthHandle).toBe('johndoe');
    });

    it('shows verification status and OAuth data', () => {
      const verifiedProfile: UserProfile = {
        ...mockProfile,
        oauth_verified: true,
        oauth_verified_at: '2024-01-15T10:00:00Z',
      };

      const { result } = renderHook(() =>
        useUserDisplay(verifiedProfile, 'private')
      );

      expect(result.current.isVerified).toBe(true);
      expect(result.current.verifiedAt).toBe('2024-01-15T10:00:00Z');
      expect(result.current.oauthProvider).toBe('github');
    });

    it('always shows bio and avatar (private view)', () => {
      const restrictedProfile: UserProfile = {
        ...mockProfile,
        allow_public_profile: false,
      };

      const { result } = renderHook(() =>
        useUserDisplay(restrictedProfile, 'private')
      );

      // Private context shows bio/avatar regardless of public setting
      expect(result.current.bio).toBe('FVS analyst');
      expect(result.current.avatarUrl).toBe('https://example.com/avatar.jpg');
    });
  });

  describe('Admin Context', () => {
    it('shows full name as display name with all data visible', () => {
      const { result } = renderHook(() =>
        useUserDisplay(mockProfile, 'admin')
      );

      expect(result.current.displayName).toBe('John Doe');
      expect(result.current.contributorId).toBe('FVS-00001');
      expect(result.current.realName).toBe('John Doe');
      expect(result.current.email).toBe('john@example.com');
      expect(result.current.oauthHandle).toBe('johndoe');
      expect(result.current.oauthProvider).toBe('github');
    });

    it('falls back to OAuth handle if no full name', () => {
      const noNameProfile: UserProfile = {
        ...mockProfile,
        full_name: null,
      };

      const { result } = renderHook(() =>
        useUserDisplay(noNameProfile, 'admin')
      );

      expect(result.current.displayName).toBe('johndoe');
    });

    it('falls back to email if no full name or OAuth handle', () => {
      const minimalProfile: UserProfile = {
        ...mockProfile,
        full_name: null,
        oauth_handle: null,
      };

      const { result } = renderHook(() =>
        useUserDisplay(minimalProfile, 'admin')
      );

      expect(result.current.displayName).toBe('john@example.com');
    });

    it('falls back to pseudonym if nothing else available', () => {
      const bareProfile: UserProfile = {
        ...mockProfile,
        full_name: null,
        oauth_handle: null,
        email: null,
      };

      const { result } = renderHook(() =>
        useUserDisplay(bareProfile, 'admin')
      );

      expect(result.current.displayName).toBe('SwiftAnalyst042');
    });

    it('always shows all data regardless of privacy settings', () => {
      const restrictedProfile: UserProfile = {
        ...mockProfile,
        anonymous: true,
        oauth_verified: false,
        allow_public_profile: false,
      };

      const { result } = renderHook(() =>
        useUserDisplay(restrictedProfile, 'admin')
      );

      // Admin sees everything
      expect(result.current.realName).toBe('John Doe');
      expect(result.current.email).toBe('john@example.com');
      expect(result.current.oauthHandle).toBe('johndoe');
      expect(result.current.bio).toBe('FVS analyst');
      expect(result.current.avatarUrl).toBe('https://example.com/avatar.jpg');
    });
  });

  describe('Edge Cases', () => {
    it('handles missing pseudonym gracefully', () => {
      const noPseudonymProfile: UserProfile = {
        ...mockProfile,
        pseudonym: '',
      };

      const { result } = renderHook(() =>
        useUserDisplay(noPseudonymProfile, 'public')
      );

      // Should still work, even if empty string
      expect(result.current.displayName).toBe('');
    });

    it('treats null anonymous as true (anonymous by default)', () => {
      const nullAnonymousProfile: UserProfile = {
        ...mockProfile,
        anonymous: null,
      };

      const { result } = renderHook(() =>
        useUserDisplay(nullAnonymousProfile, 'public')
      );

      expect(result.current.isAnonymous).toBe(true);
    });

    it('treats undefined anonymous as true (backwards compatibility)', () => {
      const { anonymous: _anonymous, ...profileWithoutAnonymous } = mockProfile;

      const { result } = renderHook(() =>
        useUserDisplay(profileWithoutAnonymous as UserProfile, 'public')
      );

      expect(result.current.isAnonymous).toBe(true);
    });

    it('requires both anonymous=false AND oauth_verified=true for verified display', () => {
      const almostVerifiedProfile: UserProfile = {
        ...mockProfile,
        anonymous: false,
        oauth_verified: false, // Not verified yet
      };

      const { result } = renderHook(() =>
        useUserDisplay(almostVerifiedProfile, 'public')
      );

      // Should show full name, not OAuth handle
      expect(result.current.displayName).toBe('John Doe');
      expect(result.current.isVerified).toBe(false);
    });
  });

  describe('Default Context Parameter', () => {
    it('defaults to public context when not specified', () => {
      const { result } = renderHook(() => useUserDisplay(mockProfile));

      // Should behave like public context
      expect(result.current.displayName).toBe('SwiftAnalyst042');
      expect(result.current.isAnonymous).toBe(true);
      expect(result.current.email).toBeUndefined();
    });
  });
});
