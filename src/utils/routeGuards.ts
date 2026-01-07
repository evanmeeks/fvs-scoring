import { redirect } from '@tanstack/react-router';
import { supabase } from './supabase';

type LocationLike = {
  href?: string;
  pathname?: string;
};

const buildRedirectSearch = (location?: LocationLike) => ({
  redirect: location?.href || location?.pathname || '/',
});

const fetchSessionUser = async () => {
  const { data, error } = await supabase.auth.getSession();
  if (error) {
    console.error('Supabase session check failed', error);
  }
  return data?.session?.user ?? null;
};

const fetchRoles = async () => {
  const [adminRes, contributorRes] = await Promise.all([
    supabase.rpc('is_admin'),
    supabase.rpc('is_contributor'),
  ]);

  return {
    isAdmin: !!adminRes.data,
    isContributor: !!contributorRes.data,
  };
};

export const ensureAuthenticated = async (location?: LocationLike) => {
  const user = await fetchSessionUser();

  if (!user) {
    throw redirect({ to: '/login', search: buildRedirectSearch(location) });
  }

  return { user };
};

export const ensureContributor = async (location?: LocationLike) => {
  const { user } = await ensureAuthenticated(location);
  const { isAdmin, isContributor } = await fetchRoles();

  if (!isAdmin && !isContributor) {
    throw redirect({ to: '/login', search: buildRedirectSearch(location) });
  }

  return { user, isAdmin, isContributor };
};

export const ensureAdmin = async (location?: LocationLike) => {
  const { user } = await ensureAuthenticated(location);
  const { isAdmin } = await fetchRoles();

  if (!isAdmin) {
    throw redirect({
      to: '/login',
      search: buildRedirectSearch(location),
    });
  }

  return { user, isAdmin };
};

/**
 * Route guard for beta features (Phase 1 rollout)
 * Checks if user has beta_features_enabled flag
 * Redirects to beta waitlist if not enabled
 */
export const ensureBetaAccess = async (location?: LocationLike) => {
  const { user } = await ensureAuthenticated(location);

  // Fetch user profile to check beta_features_enabled
  const { data: profile, error } = await supabase
    .from('user_profiles')
    .select('beta_features_enabled, role')
    .eq('user_id', user.id)
    .single();

  if (error) {
    console.error('Error fetching user profile for beta check:', error);
    throw redirect({ to: '/beta-waitlist' });
  }

  if (!profile?.beta_features_enabled) {
    throw redirect({ to: '/beta-waitlist' });
  }

  return { user, profile };
};
