import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../../context/AuthContext';
import { supabase } from '../../utils/supabase';
import Icon from '../Icon';
import type { DbUserProfile } from '../../types/database';

/**
 * Profile Settings Component
 * Manage pseudonym, bio, and avatar
 */
export default function ProfileSettings() {
  const { user } = useAuth();
  const [profile, setProfile] = useState<DbUserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Form state
  const [pseudonym, setPseudonym] = useState('');
  const [avatarUrl, setAvatarUrl] = useState('');

  // Pseudonym change cooldown tracking
  const [canChangePseudonym, setCanChangePseudonym] = useState(true);
  const [daysUntilChange, setDaysUntilChange] = useState(0);

  const fetchProfile = useCallback(async () => {
    if (!user) return;

    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', user.id)
        .single();

      if (error) throw error;

      setProfile(data);
      setPseudonym(data.pseudonym || '');

      setAvatarUrl(data.avatar_url || '');

      // Check if pseudonym can be changed (30-day cooldown)
      if (data.last_pseudonym_change) {
        const lastChange = new Date(data.last_pseudonym_change);
        const now = new Date();
        const daysSinceChange = Math.floor(
          (now.getTime() - lastChange.getTime()) / (1000 * 60 * 60 * 24)
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
      console.error('Error fetching profile:', err);
      setError('Failed to load profile data');
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
    if (!user || !profile) return;

    try {
      setSaving(true);
      setError(null);
      setSuccess(null);

      const updates: Partial<DbUserProfile> = {

        avatar_url: avatarUrl.trim() || null,
      };

      // Only update pseudonym if it's changed and allowed
      if (pseudonym !== profile.pseudonym) {
        if (!canChangePseudonym) {
          setError(
            `You can change your pseudonym again in ${daysUntilChange} days`
          );
          return;
        }

        // Check if pseudonym is available using RPC function
        const { data: isAvailable, error: checkError } = await supabase.rpc(
          'check_pseudonym_available',
          { p_pseudonym: pseudonym.trim() }
        );

        if (checkError) {
          console.error('Error checking pseudonym:', checkError);
          setError('Failed to check pseudonym availability');
          return;
        }

        if (!isAvailable) {
          setError('This pseudonym is already taken. Please choose another.');
          return;
        }

        // Use the update_pseudonym RPC function to enforce cooldown
        const { error: updateError } = await supabase.rpc('update_pseudonym', {
          p_new_pseudonym: pseudonym.trim(),
        });

        if (updateError) {
          console.error('Error updating pseudonym:', updateError);
          setError(updateError.message || 'Failed to update pseudonym');
          return;
        }
      }

      // Update other fields
      const { error: updateError } = await supabase
        .from('user_profiles')
        .update(updates)
        .eq('user_id', user.id);

      if (updateError) throw updateError;

      setSuccess('Profile updated successfully!');

      // Refresh profile data
      await fetchProfile();

      // Clear success message after 3 seconds
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      console.error('Error saving profile:', err);
      setError('Failed to save profile changes');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="py-12 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p className="mt-4 text-muted">Loading profile...</p>
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

      {/* Contributor ID (Read-only) */}
      <div>
        <label htmlFor="contributor-id" className="block text-sm font-medium mb-2">
          Contributor ID
        </label>
        <input
          id="contributor-id"
          type="text"
          value={profile.contributor_id || 'Not assigned'}
          disabled
          className="w-full px-4 py-2 bg-surface border border-border rounded font-mono text-primary opacity-75 cursor-not-allowed"
        />
        <p className="text-xs text-muted mt-1">
          Your unique contributor identifier (cannot be changed)
        </p>
      </div>

      {/* Pseudonym */}
      <div>
        <label htmlFor="pseudonym" className="block text-sm font-medium mb-2">
          Display Name (Pseudonym)
        </label>
        <input
          id="pseudonym"
          type="text"
          value={pseudonym}
          onChange={(e) => setPseudonym(e.target.value)}
          disabled={!canChangePseudonym}
          maxLength={50}
          className={`w-full px-4 py-2 bg-surface border border-border rounded focus:outline-none focus:border-primary transition-colors ${!canChangePseudonym ? 'opacity-50 cursor-not-allowed' : ''
            }`}
          placeholder="SwiftObserver042"
        />
        {canChangePseudonym ? (
          <p className="text-xs text-muted mt-1">
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
        <label htmlFor="avatar-url" className="block text-sm font-medium mb-2">
          Avatar URL
          <span className="text-muted font-normal ml-2">(Optional)</span>
        </label>
        <input
          id="avatar-url"
          type="url"
          value={avatarUrl}
          onChange={(e) => setAvatarUrl(e.target.value)}
          className="w-full px-4 py-2 bg-surface border border-border rounded focus:outline-none focus:border-primary transition-colors"
          placeholder="https://example.com/avatar.jpg"
        />
        <p className="text-xs text-muted mt-1">
          Leave empty to use auto-generated identicon based on your Contributor
          ID
        </p>
        {avatarUrl && (
          <div className="mt-3">
            <p className="text-xs text-muted mb-2">Preview:</p>
            <img
              src={avatarUrl}
              alt="Avatar preview"
              className="w-16 h-16 rounded-full object-cover border border-border"
              onError={(e) => {
                (e.target as HTMLImageElement).src =
                  `https://api.dicebear.com/7.x/shapes/svg?seed=${profile.contributor_id}`;
              }}
            />
          </div>
        )}
      </div>

      {/* Save Button */}
      <div className="pt-4 border-t border-border">
        <button
          onClick={handleSave}
          disabled={saving}
          className="px-6 py-3 bg-primary text-black font-bold rounded hover:bg-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {saving ? 'Saving...' : 'Save Changes'}
        </button>
      </div>
    </div>
  );
}
