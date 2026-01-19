
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect } from 'react';
import { supabase } from '../utils/supabase';
import type { User } from '../types';

interface UserProfile {
  id: string;
  user_id: string;
  role: 'admin' | 'contributor' | 'user';
  full_name: string | null;
  created_at: string;
  is_verified?: boolean;
  location?: string;
  website?: string;
  bio?: string;
  email?: string;
}

interface UserManagementPanelProps {
  currentUser: User | null;
}



export default function UserManagementPanel({ currentUser }: UserManagementPanelProps) {
  const [profiles, setProfiles] = useState<UserProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [currentUserRole, setCurrentUserRole] = useState<string | null>(null);

  useEffect(() => {
    if (currentUser) {
      checkAdminAndLoadUsers();
    }
  }, [currentUser]);

  const checkAdminAndLoadUsers = async () => {
    setLoading(true);
    setError(null);

    try {
      // Check if current user is admin
      const { data: isAdminData, error: roleError } = await supabase.rpc('is_admin');

      if (roleError) {
        setError('Failed to verify admin status');
        setLoading(false);
        return;
      }

      if (!isAdminData) {
        setError('Access denied: Admin privileges required');
        setLoading(false);
        return;
      }

      // Get current user's role for display
      const { data: roleData } = await supabase.rpc('get_user_role');
      setCurrentUserRole(roleData as unknown as string);

      // Load all user profiles with emails using secure RPC
      const { data: profilesData, error: profilesError } = await supabase
        .rpc('get_admin_user_list' as any);

      if (profilesError) {
        console.error('Error loading profiles:', profilesError);
        if (profilesError.code === 'PGRST202') { // Function not found
          setError('System Update Required: Missing admin functions. Please apply latest database migrations.');
        } else {
          setError('Failed to load user profiles');
        }
        setLoading(false);
        return;
      }

      // Map RPC result fields to UserProfile interface expected by the UI
      // Note: The RPC returns all necessary fields including email
      const mappedProfiles = (profilesData as any[]).map(p => ({
        ...p,
        user_id: p.id, // ID from auth.users (aliased as id in RPC) is the user_id
        // Ensure role is typed correctly
        role: p.role as 'admin' | 'contributor' | 'user'
      }));

      setProfiles(mappedProfiles);

    } catch (err: any) {
      console.error('Error in checkAdminAndLoadUsers:', err);
      setError(err.message || 'An unknown error occurred');
    } finally {
      setLoading(false);
    }
  };

  const handlePromoteToAdmin = async (userId: string) => {
    if (!confirm('Are you sure you want to promote this user to admin?')) {
      return;
    }

    try {
      const { data, error } = await supabase.rpc('promote_user_to_admin', {
        target_user_id: userId,
      });

      if (error) {
        setError(error.message);
        return;
      }

      setSuccessMessage((data as any)?.message || 'User promoted to admin');
      setTimeout(() => setSuccessMessage(null), 3000);

      // Reload users
      await checkAdminAndLoadUsers();
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handlePromoteToContributor = async (userId: string) => {
    if (!confirm('Are you sure you want to promote this user to contributor?')) {
      return;
    }

    try {
      const { data, error } = await supabase.rpc('promote_user_to_contributor', {
        target_user_id: userId,
      });

      if (error) {
        setError(error.message);
        return;
      }

      setSuccessMessage((data as any)?.message || 'User promoted to contributor');
      setTimeout(() => setSuccessMessage(null), 3000);

      // Reload users
      await checkAdminAndLoadUsers();
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleDemoteContributorToUser = async (userId: string) => {
    if (!confirm('Are you sure you want to demote this contributor to regular user?')) {
      return;
    }

    try {
      const { data, error } = await supabase.rpc('demote_contributor_to_user', {
        target_user_id: userId,
      });

      if (error) {
        setError(error.message);
        return;
      }

      setSuccessMessage((data as any)?.message || 'Contributor demoted to user');
      setTimeout(() => setSuccessMessage(null), 3000);

      // Reload users
      await checkAdminAndLoadUsers();
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleDemoteToUser = async (userId: string) => {
    if (!confirm('Are you sure you want to demote this admin to regular user?')) {
      return;
    }

    try {
      const { data, error } = await supabase.rpc('demote_admin_to_user', {
        target_user_id: userId,
      });

      if (error) {
        setError(error.message);
        return;
      }

      setSuccessMessage((data as any)?.message || 'Admin demoted to user');
      setTimeout(() => setSuccessMessage(null), 3000);

      // Reload users
      await checkAdminAndLoadUsers();
    } catch (err: any) {
      setError(err.message);
    }
  };



  if (loading) {
    return (
      <div className="max-w-6xl mx-auto p-6">
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
          <p className="mt-4 text-text-muted">Loading user management panel...</p>
        </div>
      </div>
    );
  }

  if (error && currentUserRole !== 'admin') {
    return (
      <div className="max-w-6xl mx-auto p-6">
        <div className="bg-red-900/20 border border-red-500/50 rounded-lg p-6">
          <h2 className="text-xl font-bold text-red-500 mb-2">Access Denied</h2>
          <p className="text-red-400">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto p-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-white mb-2">User Management</h1>
        <p className="text-text-muted">Manage user roles and permissions</p>
      </div>

      {/* Messages */}
      {error && (
        <div className="bg-red-900/20 border border-red-500/50 rounded-lg p-4 mb-6">
          <p className="text-red-400">{error}</p>
          <button
            onClick={() => setError(null)}
            className="text-red-500 hover:text-red-300 text-sm mt-2 underline"
          >
            Dismiss
          </button>
        </div>
      )}

      {successMessage && (
        <div className="bg-green-900/20 border border-green-500/50 rounded-lg p-4 mb-6">
          <p className="text-green-400">{successMessage}</p>
        </div>
      )}

      {/* User Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-panel border border-border rounded-lg p-4">
          <h3 className="text-sm font-medium text-text-muted mb-1">Total Users</h3>
          <p className="text-3xl font-bold text-white">{profiles.length}</p>
        </div>
        <div className="bg-panel border border-border rounded-lg p-4">
          <h3 className="text-sm font-medium text-text-muted mb-1">Admins</h3>
          <p className="text-3xl font-bold text-purple-400">
            {profiles.filter(p => p.role === 'admin').length}
          </p>
        </div>
        <div className="bg-panel border border-border rounded-lg p-4">
          <h3 className="text-sm font-medium text-text-muted mb-1">Contributors</h3>
          <p className="text-3xl font-bold text-blue-400">
            {profiles.filter(p => p.role === 'contributor').length}
          </p>
        </div>
        <div className="bg-panel border border-border rounded-lg p-4">
          <h3 className="text-sm font-medium text-text-muted mb-1">Regular Users</h3>
          <p className="text-3xl font-bold text-text-muted">
            {profiles.filter(p => p.role === 'user').length}
          </p>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-panel border border-border rounded-lg overflow-hidden">
        <table className="min-w-full divide-y divide-border">
          <thead className="bg-surface">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">
                User
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">
                Role
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">
                Joined
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-text-muted uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border text-white">
            {profiles.map((profile) => {
              const isCurrentUser = profile.user_id === currentUser?.id;
              const email = profile.email || 'Unknown';

              return (
                <tr key={profile.id} className={isCurrentUser ? 'bg-primary/5' : ''}>
                  <td className="px-6 py-4">
                    <div className="flex items-center">
                      <div>
                        <div className="flex items-center gap-2">
                          <div className="text-sm font-medium text-white">
                            {profile.full_name || 'Unknown User'}
                          </div>
                          {profile.is_verified && (
                            <span className="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-blue-900/50 text-blue-400" title="Verified User">
                              ✓
                            </span>
                          )}
                          {isCurrentUser && (
                            <span className="text-xs text-primary font-semibold">(You)</span>
                          )}
                        </div>
                        <div className="text-sm text-text-muted">{email}</div>
                        <div className="text-[10px] text-text-muted/40 font-mono mt-0.5" title={profile.user_id}>
                          ID: {profile.user_id}
                        </div>

                        {/* New Profile Fields */}
                        <div className="mt-1 flex flex-col gap-0.5 text-xs text-text-muted/60">
                          {profile.location && (
                            <div className="flex items-center gap-1">
                              <span>📍 {profile.location}</span>
                            </div>
                          )}
                          {profile.website && (
                            <div className="flex items-center gap-1">
                              <span>🔗 <a href={profile.website} target="_blank" rel="noopener noreferrer" className="hover:underline">{profile.website}</a></span>
                            </div>
                          )}
                          {profile.bio && (
                            <div className="italic mt-0.5 text-text-muted/50 truncate max-w-xs" title={profile.bio}>
                              {profile.bio}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${profile.role === 'admin'
                        ? 'bg-purple-900/50 text-purple-400'
                        : profile.role === 'contributor'
                          ? 'bg-blue-900/50 text-blue-400'
                          : 'bg-white/10 text-white'
                        }`}
                    >
                      {profile.role}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-text-muted">
                    {new Date(profile.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    {!isCurrentUser && (
                      <>
                        {profile.role === 'user' && (
                          <div className="flex items-center justify-end gap-3">
                            <button
                              onClick={() => handlePromoteToContributor(profile.user_id)}
                              className="text-blue-400 hover:text-white font-medium"
                            >
                              Promote to Contributor
                            </button>
                            <span className="text-border">|</span>
                            <button
                              onClick={() => handlePromoteToAdmin(profile.user_id)}
                              className="text-purple-400 hover:text-white font-medium"
                            >
                              Promote to Admin
                            </button>
                          </div>
                        )}
                        {profile.role === 'contributor' && (
                          <div className="flex items-center justify-end gap-3">
                            <button
                              onClick={() => handleDemoteContributorToUser(profile.user_id)}
                              className="text-orange-500 hover:text-white font-medium"
                            >
                              Demote to User
                            </button>
                            <span className="text-border">|</span>
                            <button
                              onClick={() => handlePromoteToAdmin(profile.user_id)}
                              className="text-purple-400 hover:text-white font-medium"
                            >
                              Promote to Admin
                            </button>
                          </div>
                        )}
                        {profile.role === 'admin' && (
                          <button
                            onClick={() => handleDemoteToUser(profile.user_id)}
                            className="text-orange-500 hover:text-white font-medium"
                          >
                            Demote to User
                          </button>
                        )}
                      </>
                    )}
                    {isCurrentUser && (
                      <span className="text-text-muted italic">Cannot modify own role</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {profiles.length === 0 && (
          <div className="text-center py-12 text-text-muted">
            No users found
          </div>
        )}
      </div>

      {/* Refresh Button */}
      <div className="mt-6 text-center">
        <button
          onClick={checkAdminAndLoadUsers}
          className="px-4 py-2 border border-border rounded-md text-sm font-medium text-text-muted hover:bg-panel hover:text-white"
        >
          Refresh User List
        </button>
      </div>
    </div>
  );
}
