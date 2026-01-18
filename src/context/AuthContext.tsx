/**
 * Authentication Context
 * Manages user authentication and authorization via Supabase
 */

import {
  createContext,
  useContext,
  useState,
  useEffect,
  type ReactNode,
} from "react";

import { supabase } from "../utils/supabase";
import type { UserRole } from "../types/metrics";
import type { User, Session, AuthChangeEvent } from "@supabase/supabase-js";

// Extend the Supabase User type to include our app-specific properties if needed
interface AppUser extends User {
  role?: UserRole;
}

interface AuthContextValue {
  user: AppUser | null;
  session: Session | null;
  authStatus: "unauthenticated" | "authenticating" | "authenticated";
  login: () => void; // Trigger for UI dependent login (e.g. open modal) - simplified
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  isAuthorized: (requiredRole?: UserRole) => boolean;
  isAdmin: boolean;
  isContributor: boolean;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AppUser | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [authStatus, setAuthStatus] = useState<
    "unauthenticated" | "authenticating" | "authenticated"
  >("unauthenticated");
  const [isAdmin, setIsAdmin] = useState<boolean>(false);
  const [isContributor, setIsContributor] = useState<boolean>(false);

  // Fetch user roles from database
  const fetchRoles = async () => {
    try {
      // Call RPC functions to check roles
      const [adminResult, contributorResult] = await Promise.all([
        supabase.rpc('is_admin'),
        supabase.rpc('is_contributor'),
      ]);

      setIsAdmin(!!adminResult.data);
      setIsContributor(!!contributorResult.data);
    } catch (error) {
      console.error('Error fetching user roles:', error);
      setIsAdmin(false);
      setIsContributor(false);
    }
  };

  useEffect(() => {
    // Initial Session Check
    supabase.auth
      .getSession()
      .then(({ data: { session } }: { data: { session: Session | null } }) => {
        setSession(session);
        // @ts-expect-error - User type mismatch
        setUser(session?.user ?? null);
        setAuthStatus(session ? "authenticated" : "unauthenticated");

        // Fetch roles if authenticated
        if (session?.user) {
          fetchRoles();
        } else {
          setIsAdmin(false);
          setIsContributor(false);
        }
      });

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(
      (_event: AuthChangeEvent, session: Session | null) => {
        setSession(session);
        // @ts-expect-error - User type mismatch
        setUser(session?.user ?? null);
        setAuthStatus(session ? "authenticated" : "unauthenticated");

        // Fetch roles when auth state changes
        if (session?.user) {
          fetchRoles();
        } else {
          setIsAdmin(false);
          setIsContributor(false);
        }
      },
    );

    return () => subscription.unsubscribe();
  }, []);

  const login = () => {
    // Placeholder: In a real implementation this might open a modal or redirect.
    // Ideally, UI components should handle the trigger, or we accept a callback in Provider to open the global modal.
    console.warn("AuthContext.login called. Use AuthModal for actual login.");
  };

  const logout = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setSession(null);
    setAuthStatus("unauthenticated");
  };

  const isAuthenticated = !!session && !!user;

  const isAuthorized = (requiredRole?: UserRole): boolean => {
    if (!isAuthenticated || !user) return false;
    if (!requiredRole) return true;

    if (requiredRole === "admin") return isAdmin;
    if (requiredRole === "contributor") return isContributor || isAdmin;
    if (requiredRole === "viewer") return true;

    return false;
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        authStatus,
        login,
        logout,
        isAuthenticated,
        isAuthorized,
        isAdmin,
        isContributor,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
