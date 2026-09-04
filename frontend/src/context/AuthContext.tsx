import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from "react";

import { ApiException } from "@/services/apiException";
import { authService } from "@/services/authService";
import { StorageKeys, readStorage, writeStorage } from "@/utils/storage";
import type { AppUser } from "@/types/models";

export type AuthStatus = "unknown" | "authenticated" | "unauthenticated";

export interface AuthState {
  status: AuthStatus;
  user: AppUser | null;
  onboardingComplete: boolean;
}

interface AuthContextValue extends AuthState {
  login: (email: string, password: string) => Promise<string | null>;
  signup: (name: string, email: string, password: string, confirmPassword: string) => Promise<string | null>;
  logout: () => Promise<void>;
  completeOnboarding: () => void;
  setUser: (user: AppUser) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function readOnboardingComplete(): boolean {
  return readStorage(StorageKeys.onboardingComplete) === "true";
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    status: "unknown",
    user: null,
    onboardingComplete: readOnboardingComplete(),
  });

  // Bootstrap: validate any stored token against the server on first load.
  useEffect(() => {
    let cancelled = false;
    authService.currentSession().then((user) => {
      if (cancelled) return;
      setState((s) => ({ ...s, status: user ? "authenticated" : "unauthenticated", user }));
    });
    return () => {
      cancelled = true;
    };
  }, []);

  const completeOnboarding = useCallback(() => {
    writeStorage(StorageKeys.onboardingComplete, "true");
    setState((s) => ({ ...s, onboardingComplete: true }));
  }, []);

  const setUser = useCallback((user: AppUser) => {
    setState((s) => ({ ...s, user }));
  }, []);

  const login = useCallback(async (email: string, password: string): Promise<string | null> => {
    try {
      const user = await authService.login(email, password);
      setState((s) => ({ ...s, status: "authenticated", user }));
      return null;
    } catch (e) {
      return e instanceof ApiException ? e.message : "Something went wrong. Please try again.";
    }
  }, []);

  const signup = useCallback(
    async (name: string, email: string, password: string, confirmPassword: string): Promise<string | null> => {
      try {
        const user = await authService.signup(name, email, password, confirmPassword);
        setState((s) => ({ ...s, status: "authenticated", user }));
        return null;
      } catch (e) {
        return e instanceof ApiException ? e.message : "Something went wrong. Please try again.";
      }
    },
    [],
  );

  const logout = useCallback(async () => {
    await authService.logout();
    setState((s) => ({ ...s, status: "unauthenticated", user: null }));
  }, []);

  return (
    <AuthContext.Provider value={{ ...state, login, signup, logout, completeOnboarding, setUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within an AuthProvider");
  return ctx;
}
