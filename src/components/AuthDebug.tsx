import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../utils/supabase';

/**
 * AuthDebug Component
 * Temporary component to debug authentication issues
 * Shows user info, role checks, and RPC function results
 *
 * To use: Add <AuthDebug /> anywhere in your app (e.g., Header or __root.tsx)
 */
export default function AuthDebug() {
  const { user, isAdmin, isContributor, isAuthenticated } = useAuth();
  /* eslint-disable @typescript-eslint/no-explicit-any */
  const [profileData, setProfileData] = useState<{ profile: any; profileError: any } | null>(null);
  const [rpcResults, setRpcResults] = useState<{ is_admin: any; is_contributor: any } | null>(null);
  /* eslint-enable @typescript-eslint/no-explicit-any */

  useEffect(() => {
    if (!user) return;

    const checkProfile = async () => {
      // Check user_profiles table directly
      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', user.id)
        .single();

      // Check RPC functions
      const [adminRpc, contributorRpc] = await Promise.all([
        supabase.rpc('is_admin'),
        supabase.rpc('is_contributor')
      ]);

      setProfileData({ profile, profileError });
      setRpcResults({
        is_admin: adminRpc,
        is_contributor: contributorRpc
      });
    };

    checkProfile();
  }, [user]);

  if (!isAuthenticated) {
    return (
      <div className="fixed bottom-4 right-4 bg-red-900 border border-red-500 text-white p-4 rounded-lg shadow-lg max-w-md z-50">
        <h3 className="font-bold mb-2">🔴 Not Authenticated</h3>
        <p className="text-xs">User is not logged in</p>
      </div>
    );
  }

  return (
    <div className="fixed bottom-4 right-4 bg-gray-900 border border-gray-700 text-white p-4 rounded-lg shadow-lg max-w-md z-50 text-xs font-mono overflow-auto max-h-96">
      <h3 className="font-bold mb-2 text-sm">🔍 Auth Debug Panel</h3>

      <div className="space-y-2">
        <div>
          <strong>Email:</strong> {user?.email}
        </div>
        <div>
          <strong>User ID:</strong> {user?.id?.substring(0, 8)}...
        </div>

        <hr className="border-gray-700 my-2" />

        <div>
          <strong>Context State:</strong>
          <div className="ml-2">
            <div>isAdmin: <span className={isAdmin ? 'text-green-400' : 'text-red-400'}>{String(isAdmin)}</span></div>
            <div>isContributor: <span className={isContributor ? 'text-green-400' : 'text-red-400'}>{String(isContributor)}</span></div>
          </div>
        </div>

        <hr className="border-gray-700 my-2" />

        <div>
          <strong>Database Profile:</strong>
          {profileData?.profileError && (
            <div className="text-red-400 ml-2">
              Error: {profileData.profileError.message}
            </div>
          )}
          {profileData?.profile && (
            <div className="ml-2">
              <div>Role: <span className="text-cyan-400">{profileData.profile.role}</span></div>
              <div>Name: {profileData.profile.full_name}</div>
            </div>
          )}
          {!profileData?.profile && !profileData?.profileError && (
            <div className="text-yellow-400 ml-2">No profile found</div>
          )}
        </div>

        <hr className="border-gray-700 my-2" />

        <div>
          <strong>RPC Functions:</strong>
          {rpcResults && (
            <div className="ml-2">
              <div>
                is_admin():
                <span className={rpcResults.is_admin?.data ? 'text-green-400' : 'text-red-400'}>
                  {' '}{String(rpcResults.is_admin?.data)}
                </span>
                {rpcResults.is_admin?.error && (
                  <div className="text-red-400 text-xs">
                    Error: {rpcResults.is_admin.error.message}
                  </div>
                )}
              </div>
              <div>
                is_contributor():
                <span className={rpcResults.is_contributor?.data ? 'text-green-400' : 'text-red-400'}>
                  {' '}{String(rpcResults.is_contributor?.data)}
                </span>
                {rpcResults.is_contributor?.error && (
                  <div className="text-red-400 text-xs">
                    Error: {rpcResults.is_contributor.error.message}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        <hr className="border-gray-700 my-2" />

        <div className="text-xs text-gray-400 mt-2">
          <strong>Next Steps:</strong>
          <ol className="list-decimal ml-4 mt-1">
            <li>Check "Database Profile" role</li>
            <li>If role is not "admin", run fix_admin_role.sql</li>
            <li>Refresh page after fixing</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
