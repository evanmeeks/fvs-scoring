import { useState, useEffect, useCallback } from "react";
import { useAuth } from "../../context/AuthContext";
import { supabase } from "../../utils/supabase";
import Icon from "../Icon";
import { VerifiedBadge } from "../shared/VerifiedBadge";
import type { DbUserProfile } from "../../types/database";

/**
 * Privacy Settings Component
 * Manage anonymity, verification, and data visibility
 */
export default function PrivacySettings() {
  const { user } = useAuth();
  const [profile, setProfile] = useState<DbUserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Form state
  const [anonymous, setAnonymous] = useState(true);
  const [allowPublicProfile, setAllowPublicProfile] = useState(false);

  const fetchProfile = useCallback(async () => {
    if (!user) return;

    try {
      setLoading(true);
      const { data, error } = await supabase
        .from("user_profiles")
        .select("*")
        .eq("user_id", user.id)
        .single();

      if (error) throw error;

      setProfile(data);
      setAnonymous(data.anonymous ?? true);
      setAllowPublicProfile(data.allow_public_profile ?? false);
    } catch (err) {
      console.error("Error fetching profile:", err);
      setError("Failed to load profile data");
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    if (user) {
      fetchProfile();
    }
  }, [user, fetchProfile]);

  const handleSave = async () => {
    if (!user) return;

    try {
      setSaving(true);
      setError(null);
      setSuccess(null);

      const updates: Partial<DbUserProfile> = {
        anonymous,
        allow_public_profile: allowPublicProfile,
      };

      const { error: updateError } = await supabase
        .from("user_profiles")
        .update(updates)
        .eq("user_id", user.id);

      if (updateError) throw updateError;

      setSuccess("Privacy settings updated successfully!");

      // Refresh profile data
      await fetchProfile();

      // Clear success message after 3 seconds
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      console.error("Error saving privacy settings:", err);
      setError("Failed to save privacy settings");
    } finally {
      setSaving(false);
    }
  };

  const handleVerifyOAuth = async (
    provider: "github" | "twitter" | "discord",
  ) => {
    try {
      setError(null);

      // Trigger OAuth flow
      const { error } = await supabase.auth.signInWithOAuth({
        provider,
        options: {
          redirectTo: `${window.location.origin}/profile/privacy`,
          scopes: provider === "github" ? "read:user" : undefined,
        },
      });

      if (error) throw error;
    } catch (err) {
      console.error(`Error verifying ${provider}:`, err);
      setError(`Failed to initiate ${provider} verification`);
    }
  };

  const handleUnlinkOAuth = async () => {
    if (!user || !profile) return;

    const confirmed = window.confirm(
      "Are you sure you want to unlink your OAuth account? This will remove your verified status.",
    );

    if (!confirmed) return;

    try {
      setSaving(true);
      setError(null);

      // Use RPC function to unlink OAuth
      const { error } = await supabase.rpc("unlink_oauth_handle");

      if (error) throw error;

      setSuccess("OAuth account unlinked successfully");
      await fetchProfile();

      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      console.error("Error unlinking OAuth:", err);
      setError("Failed to unlink OAuth account");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="py-12 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p className="mt-4 text-muted">Loading privacy settings...</p>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="text-center py-12">
        <Icon name="error" className="text-4xl text-red-500 mb-4" />
        <p className="text-red-500">Failed to load profile</p>
      </div>
    );
  }

  const isVerified = profile.oauth_verified ?? false;
  const currentMode = isVerified
    ? "verified"
    : anonymous
      ? "anonymous"
      : "public";
  const currentModeLabel =
    currentMode === "anonymous"
      ? "Anonymous (Default)"
      : currentMode === "verified"
        ? "Verified"
        : "Public";

  return (
    <div className="space-y-6">
      {/* Error/Success Messages */}
      {error && (
        <div className="bg-red-500/10 border border-red-500/30 p-4 rounded text-red-500">
          {error}
        </div>
      )}
      {success && (
        <div className="bg-green-500/10 border border-green-500/30 p-4 rounded text-green-500">
          {success}
        </div>
      )}

      {/* Current Privacy Mode */}
      <div className="bg-primary/10 border border-primary/30 rounded-lg p-4">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-lg">Current Profile</h3>
            <p className="text-sm text-muted">
              {currentMode === "anonymous" &&
                "You appear as your pseudonym to all users (default)"}
              {currentMode === "verified" &&
                "You appear as your verified OAuth handle"}
              {currentMode === "public" &&
                "You appear with your real name (not recommended)"}
            </p>
          </div>
          <div className="text-right">
            <span className="inline-flex items-center px-3 py-1 rounded-full bg-surface border border-border font-mono text-sm">
              {currentMode === "verified" && (
                <>
                  <VerifiedBadge
                    verifiedAt={profile.oauth_verified_at}
                    size="sm"
                    showTooltip={false}
                    className="mr-2"
                  />
                </>
              )}
              {currentModeLabel}
            </span>
          </div>
        </div>
      </div>

      {/* OAuth Verification Section */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">OAuth Verification</h3>
        <p className="text-sm text-muted">
          Link your social account to get a verified badge and optionally show
          your handle publicly.
        </p>

        {isVerified ? (
          <div className="bg-green-500/10 border border-green-500/30 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <VerifiedBadge
                  verifiedAt={profile.oauth_verified_at}
                  size="md"
                />
                <div>
                  <p className="font-semibold">Verified Account</p>
                  <p className="text-sm text-muted">
                    {profile.oauth_provider &&
                      `Connected via ${profile.oauth_provider}`}
                    {profile.oauth_handle && ` (@${profile.oauth_handle})`}
                  </p>
                  {profile.oauth_verified_at && (
                    <p className="text-xs text-muted mt-1">
                      Verified on{" "}
                      {new Date(profile.oauth_verified_at).toLocaleDateString()}
                    </p>
                  )}
                </div>
              </div>
              <button
                onClick={handleUnlinkOAuth}
                disabled={saving}
                className="px-4 py-2 bg-red-500/10 text-red-500 border border-red-500/30 rounded hover:bg-red-500/20 transition-colors text-sm font-semibold disabled:opacity-50"
              >
                Unlink
              </button>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button
              onClick={() => handleVerifyOAuth("github")}
              className="flex items-center gap-3 p-4 bg-surface border border-border rounded hover:border-primary/50 transition-colors"
            >
              <Icon name="code" className="text-2xl" />
              <div className="text-left">
                <p className="font-semibold">GitHub</p>
                <p className="text-xs text-muted">Verify with GitHub</p>
              </div>
            </button>

            <button
              onClick={() => handleVerifyOAuth("twitter")}
              className="flex items-center gap-3 p-4 bg-surface border border-border rounded hover:border-primary/50 transition-colors"
            >
              <Icon name="tag" className="text-2xl" />
              <div className="text-left">
                <p className="font-semibold">Twitter/X</p>
                <p className="text-xs text-muted">Verify with X</p>
              </div>
            </button>

            <button
              onClick={() => handleVerifyOAuth("discord")}
              className="flex items-center gap-3 p-4 bg-surface border border-border rounded hover:border-primary/50 transition-colors"
            >
              <Icon name="forum" className="text-2xl" />
              <div className="text-left">
                <p className="font-semibold">Discord</p>
                <p className="text-xs text-muted">Verify with Discord</p>
              </div>
            </button>
          </div>
        )}
      </div>

      {/* Anonymity Toggle */}
      {!isVerified && (
        <div className="space-y-4">
          <h3 className="text-lg font-semibold">Display Preferences</h3>

          <label
            htmlFor="anonymous-mode"
            aria-label="Anonymous Mode"
            className="flex items-center justify-between p-4 bg-surface border border-border rounded cursor-pointer hover:border-primary/50 transition-colors"
          >
            <div>
              <p className="font-semibold">Anonymous</p>
              <p className="text-sm text-muted">
                Show pseudonym instead of real name (recommended)
              </p>
            </div>
            <input
              id="anonymous-mode"
              type="checkbox"
              checked={anonymous}
              onChange={(e) => setAnonymous(e.target.checked)}
              className="w-5 h-5 accent-primary"
            />
          </label>
        </div>
      )}

      {/* Public Profile Toggle */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Visibility</h3>

        <label
          htmlFor="allow-public-profile"
          aria-label="Allow Public Profile"
          className="flex items-center justify-between p-4 bg-surface border border-border rounded cursor-pointer hover:border-primary/50 transition-colors"
        >
          <div>
            <p className="font-semibold">Publish Profile</p>
            <p className="text-sm text-muted">
              Show your profile on public leaderboards and contributor lists
            </p>
          </div>
          <input
            id="allow-public-profile"
            type="checkbox"
            checked={allowPublicProfile}
            onChange={(e) => setAllowPublicProfile(e.target.checked)}
            className="w-5 h-5 accent-primary"
          />
        </label>
      </div>

      {/* Privacy Explanation */}
      <div className="bg-surface border border-border rounded-lg p-4">
        <h3 className="text-sm font-semibold mb-3 flex items-center gap-2">
          <Icon name="info" className="text-lg" />
          Profile Modes Explained
        </h3>
        <ul className="text-sm space-y-2 text-muted">
          <li>
            <strong className="text-white">Anonymous:</strong> Others see only
            your pseudonym (e.g., "SwiftObserver042")
          </li>
          <li>
            <strong className="text-white">Verified:</strong> Link OAuth account
            to show verified badge. Others see "@yourhandle"
          </li>
        </ul>
      </div>

      {/* Save Button */}
      <div className="pt-4 border-t border-border">
        <button
          onClick={handleSave}
          disabled={saving}
          className="px-6 py-3 bg-primary text-black font-bold rounded hover:bg-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {saving ? "Saving..." : "Save Privacy Settings"}
        </button>
      </div>
    </div>
  );
}
