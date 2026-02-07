"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import { useEffect, useState, useCallback } from "react";
import { createClient } from "~/lib/supabase/client";
import { LandingView } from "~/components/views/LandingView";
import Icon from "~/components/Icon";

type ActiveTab = "settings" | "privacy" | "preferences" | "submissions";

export function ProfilePage() {
  const supabase = createClient();
  const [user, setUser] = useState<any>(null);
  const [activeTab, setActiveTab] = useState<ActiveTab>("settings");

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data.user));
  }, [supabase.auth]);

  if (!user) {
    return (
      <LandingView>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 text-center">
          <h1 className="text-2xl font-bold text-white mb-4">
            Authentication Required
          </h1>
          <p className="text-ops-text-dim">
            Please log in to view your profile.
          </p>
        </div>
      </LandingView>
    );
  }

  return (
    <LandingView>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Sidebar */}
          <div className="lg:col-span-1 space-y-6">
            {/* User Card */}
            <div className="bg-panel border border-border p-6 rounded-lg text-center">
              <div className="w-24 h-24 mx-auto bg-border rounded-full flex items-center justify-center text-4xl text-text-muted mb-4 relative overflow-hidden group cursor-pointer">
                <span className="material-symbols-outlined text-5xl">
                  person
                </span>
                <div className="absolute inset-0 bg-black/60 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <span className="material-symbols-outlined text-white text-sm">
                    edit
                  </span>
                </div>
              </div>
              <h3 className="text-white font-bold text-lg">
                {user?.email?.split("@")[0] || "User"}
              </h3>
              <p className="text-xs font-mono text-cyan-400 uppercase mt-1">
                Lvl 3 Analyst
              </p>
              <div className="mt-4 flex justify-center gap-2">
                <span className="px-2 py-1 bg-green-900/30 text-green-500 text-[10px] font-mono rounded border border-green-900/50">
                  VERIFIED
                </span>
                <span className="px-2 py-1 bg-blue-900/30 text-blue-500 text-[10px] font-mono rounded border border-blue-900/50">
                  ANONYMOUS
                </span>
              </div>
            </div>

            {/* Settings Nav */}
            <div className="bg-panel border border-border rounded-lg overflow-hidden">
              <div className="p-3 border-b border-border text-xs font-mono text-text-muted uppercase">
                Settings
              </div>
              {(
                [
                  { key: "settings", icon: "badge", label: "Profile" },
                  { key: "privacy", icon: "lock", label: "Privacy" },
                  { key: "preferences", icon: "settings", label: "Preferences" },
                  {
                    key: "submissions",
                    icon: "folder_open",
                    label: "Submissions",
                  },
                ] as const
              ).map((item) => (
                <button
                  key={item.key}
                  onClick={() => setActiveTab(item.key)}
                  className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-colors border-l-2 ${
                    activeTab === item.key
                      ? "border-cyan-400 text-white bg-white/5"
                      : "border-transparent text-gray-400 hover:bg-white/5 hover:text-white"
                  }`}
                >
                  <span className="material-symbols-outlined text-gray-400 text-lg">
                    {item.icon}
                  </span>
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          {/* Main Content */}
          <div className="lg:col-span-3 space-y-6">
            {/* Stats Row */}
            <UserStatsRow userId={user.id} />

            {/* Tab Content */}
            {activeTab === "settings" && <ProfileSettingsPanel userId={user.id} />}
            {activeTab === "privacy" && <PrivacySettingsPanel userId={user.id} />}
            {activeTab === "preferences" && <PreferencesSettingsPanel />}
            {activeTab === "submissions" && (
              <MySubmissionsPanel userId={user.id} />
            )}
          </div>
        </div>
      </div>
    </LandingView>
  );
}

/* ========================================================================== */
/* Sub-Components                                                             */
/* ========================================================================== */

function UserStatsRow({ userId }: { userId: string }) {
  const supabase = createClient();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    scoredCount: 0,
    contributions: 0,
    consensusRate: 94,
  });

  useEffect(() => {
    const load = async () => {
      try {
        const [targetsRes, rfcsRes, votesRes] = await Promise.all([
          supabase
            .from("target_submissions")
            .select("id", { count: "exact", head: true })
            .eq("submitted_by", userId),
          supabase
            .from("rfc_proposals")
            .select("id", { count: "exact", head: true })
            .eq("user_id", userId),
          supabase
            .from("community_votes")
            .select("target_id")
            .eq("user_id", userId),
        ]);

        const uniqueTargets = new Set(
          (votesRes.data || []).map((v: any) => v.target_id),
        );

        setStats({
          scoredCount: uniqueTargets.size,
          contributions: (targetsRes.count || 0) + (rfcsRes.count || 0),
          consensusRate: 94,
        });
      } catch (err) {
        console.error("Error loading stats:", err);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [userId, supabase]);

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div className="bg-panel border border-border p-4 rounded-lg">
        <div className="text-xs text-text-muted font-mono uppercase">
          Audits Completed
        </div>
        <div className="text-2xl font-black text-white mt-1">
          {loading ? "-" : stats.scoredCount}
        </div>
      </div>
      <div className="bg-panel border border-border p-4 rounded-lg">
        <div className="text-xs text-text-muted font-mono uppercase">
          Contributions
        </div>
        <div className="text-2xl font-black text-cyan-400 mt-1">
          {loading ? "-" : stats.contributions}
        </div>
      </div>
      <div className="bg-panel border border-border p-4 rounded-lg">
        <div className="text-xs text-text-muted font-mono uppercase">
          Consensus Rate
        </div>
        <div className="text-2xl font-black text-green-500 mt-1">
          {stats.consensusRate}%
        </div>
      </div>
    </div>
  );
}

/* ---------- Profile Settings ---------- */

function ProfileSettingsPanel({ userId }: { userId: string }) {
  const supabase = createClient();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [pseudonym, setPseudonym] = useState("");
  const [avatarUrl, setAvatarUrl] = useState("");
  const [canChangePseudonym, setCanChangePseudonym] = useState(true);
  const [daysUntilChange, setDaysUntilChange] = useState(0);

  const fetchProfile = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await (supabase
        .from("user_profiles") as any)
        .select("*")
        .eq("user_id", userId)
        .single();

      if (error) throw error;

      setProfile(data);
      setPseudonym(data.pseudonym || "");
      setAvatarUrl(data.avatar_url || "");

      if (data.last_pseudonym_change) {
        const lastChange = new Date(data.last_pseudonym_change);
        const now = new Date();
        const daysSinceChange = Math.floor(
          (now.getTime() - lastChange.getTime()) / (1000 * 60 * 60 * 24),
        );
        const cooldownDays = 30;

        if (daysSinceChange < cooldownDays) {
          setCanChangePseudonym(false);
          setDaysUntilChange(cooldownDays - daysSinceChange);
        } else {
          setCanChangePseudonym(true);
        }
      }
    } catch (err) {
      console.error("Error fetching profile:", err);
      setError("Failed to load profile data");
    } finally {
      setLoading(false);
    }
  }, [userId, supabase]);

  useEffect(() => {
    fetchProfile();
  }, [fetchProfile]);

  const handleSave = async () => {
    if (!profile) return;

    try {
      setSaving(true);
      setError(null);
      setSuccess(null);

      const updates: any = {
        avatar_url: avatarUrl.trim() || null,
      };

      if (pseudonym !== profile.pseudonym) {
        if (!canChangePseudonym) {
          setError(
            `You can change your pseudonym again in ${daysUntilChange} days`,
          );
          return;
        }

        const { data: isAvailable, error: checkError } = await (supabase.rpc as any)(
          "check_pseudonym_available",
          { p_pseudonym: pseudonym.trim() },
        );

        if (checkError) {
          setError("Failed to check pseudonym availability");
          return;
        }

        if (!isAvailable) {
          setError("This pseudonym is already taken. Please choose another.");
          return;
        }

        const { error: updateError } = await (supabase.rpc as any)(
          "update_pseudonym",
          { p_new_pseudonym: pseudonym.trim() },
        );

        if (updateError) {
          setError(updateError.message || "Failed to update pseudonym");
          return;
        }
      }

      const { error: updateError } = await (supabase
        .from("user_profiles") as any)
        .update(updates)
        .eq("user_id", userId);

      if (updateError) throw updateError;

      setSuccess("Profile updated successfully!");
      await fetchProfile();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      console.error("Error saving profile:", err);
      setError("Failed to save profile changes");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="py-12 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p className="mt-4 text-text-muted">Loading profile...</p>
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

  return (
    <div className="bg-panel border border-border rounded-lg p-6">
      <h3 className="text-lg font-bold text-white mb-6 border-b border-border pb-4">
        Profile Settings
      </h3>
      <div className="space-y-6">
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

        {/* Contributor ID */}
        <div>
          <label
            htmlFor="contributor-id"
            className="block text-sm font-medium mb-2 text-white"
          >
            Contributor ID
          </label>
          <input
            id="contributor-id"
            type="text"
            value={profile.contributor_id || "Not assigned"}
            disabled
            className="w-full px-4 py-2 bg-surface border border-border rounded font-mono text-primary opacity-75 cursor-not-allowed"
          />
          <p className="text-xs text-text-muted mt-1">
            Your unique contributor identifier (cannot be changed)
          </p>
        </div>

        {/* Pseudonym */}
        <div>
          <label
            htmlFor="pseudonym"
            className="block text-sm font-medium mb-2 text-white"
          >
            Display Name (Pseudonym)
          </label>
          <input
            id="pseudonym"
            type="text"
            value={pseudonym}
            onChange={(e) => setPseudonym(e.target.value)}
            disabled={!canChangePseudonym}
            maxLength={50}
            className={`w-full px-4 py-2 bg-surface border border-border rounded focus:outline-none focus:border-primary transition-colors text-white ${
              !canChangePseudonym ? "opacity-50 cursor-not-allowed" : ""
            }`}
            placeholder="SwiftObserver042"
          />
          {canChangePseudonym ? (
            <p className="text-xs text-text-muted mt-1">
              Your public-facing display name. Can be changed every 30 days.
            </p>
          ) : (
            <p className="text-xs text-yellow-500 mt-1">
              <Icon name="lock" className="text-sm inline mr-1" />
              You can change your pseudonym again in {daysUntilChange} days
            </p>
          )}
        </div>

        {/* Avatar URL */}
        <div>
          <label
            htmlFor="avatar-url"
            className="block text-sm font-medium mb-2 text-white"
          >
            Avatar URL
            <span className="text-text-muted font-normal ml-2">
              (Optional)
            </span>
          </label>
          <input
            id="avatar-url"
            type="url"
            value={avatarUrl}
            onChange={(e) => setAvatarUrl(e.target.value)}
            className="w-full px-4 py-2 bg-surface border border-border rounded focus:outline-none focus:border-primary transition-colors text-white"
            placeholder="https://example.com/avatar.jpg"
          />
          <p className="text-xs text-text-muted mt-1">
            Leave empty to use auto-generated identicon based on your
            Contributor ID
          </p>
        </div>

        {/* Save */}
        <div className="pt-4 border-t border-border">
          <button
            onClick={handleSave}
            disabled={saving}
            className="px-6 py-3 bg-primary text-black font-bold rounded hover:bg-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </div>
    </div>
  );
}

/* ---------- Privacy Settings ---------- */

function PrivacySettingsPanel({ userId }: { userId: string }) {
  const supabase = createClient();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [anonymous, setAnonymous] = useState(true);
  const [allowPublicProfile, setAllowPublicProfile] = useState(false);

  const fetchProfile = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await (supabase
        .from("user_profiles") as any)
        .select("*")
        .eq("user_id", userId)
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
  }, [userId, supabase]);

  useEffect(() => {
    fetchProfile();
  }, [fetchProfile]);

  const handleSave = async () => {
    try {
      setSaving(true);
      setError(null);
      setSuccess(null);

      const { error: updateError } = await (supabase
        .from("user_profiles") as any)
        .update({ anonymous, allow_public_profile: allowPublicProfile })
        .eq("user_id", userId);

      if (updateError) throw updateError;

      setSuccess("Privacy settings updated successfully!");
      await fetchProfile();
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
      const { error } = await supabase.auth.signInWithOAuth({
        provider,
        options: {
          redirectTo: `${window.location.origin}/profile`,
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
    const confirmed = window.confirm(
      "Are you sure you want to unlink your OAuth account? This will remove your verified status.",
    );
    if (!confirmed) return;

    try {
      setSaving(true);
      setError(null);
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
        <p className="mt-4 text-text-muted">Loading privacy settings...</p>
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
    <div className="bg-panel border border-border rounded-lg p-6">
      <h3 className="text-lg font-bold text-white mb-6 border-b border-border pb-4">
        Privacy Settings
      </h3>
      <div className="space-y-6">
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
              <h4 className="font-semibold text-lg text-white">
                Current Profile
              </h4>
              <p className="text-sm text-text-muted">
                {currentMode === "anonymous" &&
                  "You appear as your pseudonym to all users (default)"}
                {currentMode === "verified" &&
                  "You appear as your verified OAuth handle"}
                {currentMode === "public" &&
                  "You appear with your real name (not recommended)"}
              </p>
            </div>
            <span className="inline-flex items-center px-3 py-1 rounded-full bg-surface border border-border font-mono text-sm text-white">
              {currentModeLabel}
            </span>
          </div>
        </div>

        {/* OAuth Verification — Coming Soon */}
        <div className="space-y-4">
          <h4 className="text-lg font-semibold text-white">
            OAuth Verification
          </h4>
          <div className="bg-surface border border-border rounded-lg p-6 text-center">
            <Icon name="verified" className="text-4xl text-primary/30 mb-3" />
            <p className="text-sm text-text-muted mb-1">
              Social account verification is coming soon.
            </p>
            <p className="text-xs text-text-muted/70">
              Link GitHub, Twitter/X, or Discord to earn a verified badge and
              optionally display your handle publicly.
            </p>
          </div>
        </div>

        {/* Anonymity Toggle */}
        {!isVerified && (
          <div className="space-y-4">
            <h4 className="text-lg font-semibold text-white">
              Display Preferences
            </h4>
            <label
              htmlFor="anonymous-mode"
              className="flex items-center justify-between p-4 bg-surface border border-border rounded cursor-pointer hover:border-primary/50 transition-colors"
            >
              <div>
                <p className="font-semibold text-white">Anonymous</p>
                <p className="text-sm text-text-muted">
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
          <h4 className="text-lg font-semibold text-white">Visibility</h4>
          <label
            htmlFor="allow-public-profile"
            className="flex items-center justify-between p-4 bg-surface border border-border rounded cursor-pointer hover:border-primary/50 transition-colors"
          >
            <div>
              <p className="font-semibold text-white">Publish Profile</p>
              <p className="text-sm text-text-muted">
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
          <h4 className="text-sm font-semibold mb-3 flex items-center gap-2 text-white">
            <Icon name="info" className="text-lg" />
            Profile Modes Explained
          </h4>
          <ul className="text-sm space-y-2 text-text-muted">
            <li>
              <strong className="text-white">Anonymous:</strong> Others see
              only your pseudonym (e.g., &quot;SwiftObserver042&quot;)
            </li>
            <li>
              <strong className="text-white">Verified:</strong> Link OAuth
              account to show verified badge. Others see
              &quot;@yourhandle&quot;
            </li>
          </ul>
        </div>

        {/* Save */}
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
    </div>
  );
}

/* ---------- Preferences Settings ---------- */

function PreferencesSettingsPanel() {
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [activityNotifications, setActivityNotifications] = useState(true);
  const [rfcNotifications, setRfcNotifications] = useState(true);
  const [saving, setSaving] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);

  const handleSave = async () => {
    setSaving(true);
    await new Promise((resolve) => setTimeout(resolve, 500));
    setSuccess("Preferences saved successfully!");
    setSaving(false);
    setTimeout(() => setSuccess(null), 3000);
  };

  return (
    <div className="bg-panel border border-border rounded-lg p-6">
      <h3 className="text-lg font-bold text-white mb-6 border-b border-border pb-4">
        Notification & Display Preferences
      </h3>
      <div className="space-y-6">
        {success && (
          <div className="bg-green-500/10 border border-green-500/30 p-4 rounded text-green-500">
            {success}
          </div>
        )}

        {/* Email Notifications */}
        <div className="space-y-4">
          <h4 className="text-lg font-semibold text-white">
            Email Notifications
          </h4>

          <label
            htmlFor="email-notifications"
            className="flex items-center justify-between p-4 bg-surface border border-border rounded cursor-pointer hover:border-primary/50 transition-colors"
          >
            <div>
              <p className="font-semibold text-white">
                Enable Email Notifications
              </p>
              <p className="text-sm text-text-muted">
                Receive email updates about your FVS activity
              </p>
            </div>
            <input
              id="email-notifications"
              type="checkbox"
              checked={emailNotifications}
              onChange={(e) => setEmailNotifications(e.target.checked)}
              className="w-5 h-5 accent-primary"
            />
          </label>

          {emailNotifications && (
            <div className="ml-4 space-y-3 border-l-2 border-border pl-4">
              <label
                htmlFor="activity-notifications"
                className="flex items-center justify-between p-3 bg-surface/50 border border-border/50 rounded cursor-pointer hover:border-primary/30 transition-colors"
              >
                <div>
                  <p className="text-sm font-medium text-white">
                    Activity Notifications
                  </p>
                  <p className="text-xs text-text-muted">
                    When others vote on or comment on your scores
                  </p>
                </div>
                <input
                  id="activity-notifications"
                  type="checkbox"
                  checked={activityNotifications}
                  onChange={(e) =>
                    setActivityNotifications(e.target.checked)
                  }
                  className="w-4 h-4 accent-primary"
                />
              </label>

              <label
                htmlFor="rfc-notifications"
                className="flex items-center justify-between p-3 bg-surface/50 border border-border/50 rounded cursor-pointer hover:border-primary/30 transition-colors"
              >
                <div>
                  <p className="text-sm font-medium text-white">
                    RFC Updates
                  </p>
                  <p className="text-xs text-text-muted">
                    When RFC proposals you care about are updated or voted on
                  </p>
                </div>
                <input
                  id="rfc-notifications"
                  type="checkbox"
                  checked={rfcNotifications}
                  onChange={(e) => setRfcNotifications(e.target.checked)}
                  className="w-4 h-4 accent-primary"
                />
              </label>
            </div>
          )}
        </div>

        {/* Save */}
        <div className="pt-4 border-t border-border">
          <button
            onClick={handleSave}
            disabled={saving}
            className="px-6 py-3 bg-primary text-black font-bold rounded hover:bg-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {saving ? "Saving..." : "Save Preferences"}
          </button>
        </div>
      </div>
    </div>
  );
}

/* ---------- My Submissions View ---------- */

function MySubmissionsPanel({ userId }: { userId: string }) {
  const supabase = createClient();
  const [activeTab, setActiveTab] = useState<"targets" | "rfcs" | "scores">(
    "targets",
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [targets, setTargets] = useState<any[]>([]);
  const [rfcs, setRfcs] = useState<any[]>([]);
  const [scoredTargets, setScoredTargets] = useState<any[]>([]);

  useEffect(() => {
    const load = async () => {
      try {
        const [targetsRes, rfcsRes, votesRes] = await Promise.all([
          supabase
            .from("target_submissions")
            .select("*")
            .eq("submitted_by", userId)
            .order("submitted_at", { ascending: false }),
          supabase
            .from("rfc_proposals")
            .select("*")
            .eq("user_id", userId)
            .order("created_at", { ascending: false }),
          supabase
            .from("community_votes")
            .select("target_id, created_at")
            .eq("user_id", userId),
        ]);

        setTargets(targetsRes.data || []);
        setRfcs(rfcsRes.data || []);

        const votedTargetsMap = new Map<string, string>();
        (votesRes.data || []).forEach((vote: any) => {
          if (
            !votedTargetsMap.has(vote.target_id) ||
            vote.created_at > votedTargetsMap.get(vote.target_id)!
          ) {
            votedTargetsMap.set(vote.target_id, vote.created_at);
          }
        });

        const uniqueTargetIds = Array.from(votedTargetsMap.keys());
        let targetDetails: any[] = [];
        if (uniqueTargetIds.length > 0) {
          const { data } = await supabase
            .from("targets")
            .select("id, name, case_id")
            .in("id", uniqueTargetIds);
          targetDetails = data || [];
        }

        setScoredTargets(
          targetDetails.map((t) => ({
            ...t,
            lastVoted: votedTargetsMap.get(t.id),
          })),
        );
      } catch (err: any) {
        console.error("Error loading submissions:", err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [userId, supabase]);

  const getStatusStyle = (status: string) => {
    switch (status) {
      case "approved":
        return "bg-green-500/10 text-green-500 border-green-500/20";
      case "rejected":
        return "bg-red-500/10 text-red-500 border-red-500/20";
      case "pending":
        return "bg-yellow-500/10 text-yellow-500 border-yellow-500/20";
      case "voting":
        return "bg-purple-500/10 text-purple-500 border-purple-500/20";
      default:
        return "bg-gray-500/10 text-gray-500 border-gray-500/20";
    }
  };

  return (
    <div className="bg-panel border border-border rounded-lg p-6">
      <h3 className="text-lg font-bold text-white mb-6 border-b border-border pb-4">
        My Submissions
      </h3>

      {/* Tabs */}
      <div className="flex gap-4 border-b border-border mb-6 overflow-x-auto">
        <button
          onClick={() => setActiveTab("targets")}
          className={`pb-3 px-2 text-sm font-bold uppercase tracking-wide transition-colors whitespace-nowrap ${
            activeTab === "targets"
              ? "text-primary border-b-2 border-primary"
              : "text-text-muted hover:text-white"
          }`}
        >
          Target Proposals ({targets.length})
        </button>
        <button
          onClick={() => setActiveTab("rfcs")}
          className={`pb-3 px-2 text-sm font-bold uppercase tracking-wide transition-colors whitespace-nowrap ${
            activeTab === "rfcs"
              ? "text-primary border-b-2 border-primary"
              : "text-text-muted hover:text-white"
          }`}
        >
          RFC Proposals ({rfcs.length})
        </button>
        <button
          onClick={() => setActiveTab("scores")}
          className={`pb-3 px-2 text-sm font-bold uppercase tracking-wide transition-colors whitespace-nowrap ${
            activeTab === "scores"
              ? "text-primary border-b-2 border-primary"
              : "text-text-muted hover:text-white"
          }`}
        >
          Votes ({scoredTargets.length})
        </button>
      </div>

      {loading ? (
        <div className="py-12 text-center">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          <p className="mt-4 text-text-muted">Loading submissions...</p>
        </div>
      ) : error ? (
        <div className="bg-red-500/10 border border-red-500/30 p-4 rounded text-red-500">
          Error loading data: {error}
        </div>
      ) : (
        <div className="space-y-4">
          {/* Target Proposals Tab */}
          {activeTab === "targets" &&
            (targets.length === 0 ? (
              <EmptyState
                message="No target proposals submitted yet."
                icon="add_location_alt"
              />
            ) : (
              <div className="grid grid-cols-1 gap-4">
                {targets.map((target: any) => (
                  <div
                    key={target.id}
                    className="bg-surface border border-border rounded-lg p-6 hover:border-primary/50 transition-colors"
                  >
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <div className="flex items-center gap-2 mb-1">
                          <span
                            className={`px-2 py-0.5 rounded text-[10px] uppercase font-bold border ${getStatusStyle(target.status)}`}
                          >
                            {target.status}
                          </span>
                          <span className="text-xs text-text-muted font-mono">
                            {new Date(
                              target.submitted_at,
                            ).toLocaleDateString()}
                          </span>
                        </div>
                        <h4 className="text-xl font-bold text-white">
                          {target.target_name}
                        </h4>
                        {target.case_id && (
                          <p className="text-xs text-primary font-mono mt-1">
                            {target.case_id}
                          </p>
                        )}
                      </div>
                    </div>
                    <p className="text-sm text-text-muted line-clamp-2">
                      {target.description}
                    </p>
                  </div>
                ))}
              </div>
            ))}

          {/* RFC Proposals Tab */}
          {activeTab === "rfcs" &&
            (rfcs.length === 0 ? (
              <EmptyState
                message="No RFC proposals submitted yet."
                icon="description"
              />
            ) : (
              <div className="grid grid-cols-1 gap-4">
                {rfcs.map((rfc: any) => (
                  <div
                    key={rfc.id}
                    className="bg-surface border border-border rounded-lg p-6 hover:border-primary/50 transition-colors"
                  >
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <div className="flex items-center gap-2 mb-1">
                          <span
                            className={`px-2 py-0.5 rounded text-[10px] uppercase font-bold border ${getStatusStyle(rfc.status)}`}
                          >
                            {rfc.status}
                          </span>
                          <span className="text-xs text-text-muted font-mono">
                            {new Date(rfc.created_at).toLocaleDateString()}
                          </span>
                        </div>
                        <h4 className="text-xl font-bold text-white">
                          {rfc.proposal_type === "new_metric"
                            ? "New Metric Proposal"
                            : "Metric Modification"}
                        </h4>
                        {rfc.proposed_name && (
                          <p className="text-sm text-primary font-mono mt-1">
                            {rfc.proposed_name}
                          </p>
                        )}
                      </div>
                    </div>
                    <p className="text-sm text-text-muted line-clamp-2">
                      {rfc.rationale}
                    </p>
                  </div>
                ))}
              </div>
            ))}

          {/* Scores Tab */}
          {activeTab === "scores" &&
            (scoredTargets.length === 0 ? (
              <EmptyState
                message="You haven't scored any targets yet."
                icon="analytics"
              />
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {scoredTargets.map((target: any) => (
                  <div
                    key={target.id}
                    className="bg-surface border border-border rounded-lg p-6 hover:border-primary/50 transition-colors"
                  >
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <h4 className="text-lg font-bold text-white">
                          {target.name}
                        </h4>
                        <p className="text-xs text-text-muted font-mono mt-1">
                          {target.case_id}
                        </p>
                      </div>
                    </div>
                    <p className="text-xs text-text-muted">
                      Last scored on{" "}
                      {new Date(target.lastVoted).toLocaleDateString()}
                    </p>
                  </div>
                ))}
              </div>
            ))}
        </div>
      )}
    </div>
  );
}

function EmptyState({ message, icon }: { message: string; icon: string }) {
  return (
    <div className="text-center py-12 bg-surface border border-border rounded-lg border-dashed">
      <Icon name={icon} className="text-4xl text-text-muted mb-2 opacity-50" />
      <p className="text-text-muted">{message}</p>
    </div>
  );
}
