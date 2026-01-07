import { createClient } from '@supabase/supabase-js'
import type { Database } from '../types/supabase';

export const getURL = () => {
  // Prefer the runtime origin (so branch/preview deploys redirect back correctly)
  let url =
    (typeof window !== 'undefined' ? window.location.origin : undefined) ??
    import.meta.env.VITE_SITE_URL ?? // Set this to your site URL in production env.
    import.meta.env.VITE_VERCEL_URL ?? // Automatically set by Vercel.
    'http://localhost:5173'
  // Make sure to include `https://` when not localhost.
  url = url.includes('http') ? url : `https://${url}`
  // Make sure to include a trailing `/`.
  url = url.charAt(url.length - 1) === '/' ? url : `${url}/`

  return url
}

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY

// Create real Supabase client
export const supabase = (supabaseUrl && supabaseKey)
  ? createClient<Database>(supabaseUrl, supabaseKey)
  : {
    auth: {
      onAuthStateChange: () => ({ data: { subscription: { unsubscribe: () => { } } } }),
      getSession: () => Promise.resolve({ data: { session: null } }),
      getUser: () => Promise.resolve({ data: { user: null } }),
      signInWithPassword: () => Promise.resolve({ data: null, error: null }),
      signUp: () => Promise.resolve({ data: null, error: null }),
      signOut: () => Promise.resolve({ error: null }),
      signInWithOAuth: () => Promise.resolve({ data: null, error: null }),
    },
    from: () => ({
      select: () => {
        const mockQueryResult = {
          data: [],
          error: null
        };
        const chainable = {
          eq: () => ({
            single: () => Promise.resolve({ data: null, error: null }),
            order: () => Promise.resolve(mockQueryResult)
          }),
          order: () => Promise.resolve(mockQueryResult),
          then: (resolve: (value: unknown) => void) => Promise.resolve(mockQueryResult).then(resolve),
          catch: (reject: (reason: unknown) => void) => Promise.resolve(mockQueryResult).catch(reject)
        };
        return chainable;
      },
      insert: () => ({
        select: () => Promise.resolve({ data: null, error: null })
      }),
      update: () => ({
        eq: () => Promise.resolve({ data: null, error: null })
      }),
      delete: () => ({
        eq: () => Promise.resolve({ data: null, error: null })
      })
    }),
    rpc: () => Promise.resolve({ data: null, error: null })
  } as unknown as ReturnType<typeof createClient<Database>>; // Fallback for tests/CI