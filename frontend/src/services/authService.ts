import { backendApi } from "./backendApi";
import { StorageKeys, readStorage, removeStorage, writeStorage } from "@/utils/storage";
import { type AppUser, parseAppUser } from "@/types/models";

interface AuthResponse {
  access_token: string;
  refresh_token: string;
  user: any;
}

function persist(result: AuthResponse) {
  writeStorage(StorageKeys.accessToken, result.access_token);
  writeStorage(StorageKeys.refreshToken, result.refresh_token);
}

export const authService = {
  async signup(name: string, email: string, password: string, confirmPassword: string): Promise<AppUser> {
    const { data } = await backendApi.post<AuthResponse>("/api/auth/signup", {
      name,
      email,
      password,
      confirm_password: confirmPassword,
    });
    persist(data);
    return parseAppUser(data.user);
  },

  async login(email: string, password: string): Promise<AppUser> {
    const { data } = await backendApi.post<AuthResponse>("/api/auth/login", { email, password });
    persist(data);
    return parseAppUser(data.user);
  },

  async logout(): Promise<void> {
    try {
      await backendApi.post("/api/auth/logout");
    } catch {
      // Clear the local session even if the server call fails (e.g. offline).
    }
    removeStorage(StorageKeys.accessToken);
    removeStorage(StorageKeys.refreshToken);
  },

  async me(): Promise<AppUser> {
    const { data } = await backendApi.get("/api/auth/me");
    return parseAppUser(data);
  },

  /** Validates the stored token against the server rather than trusting local state. */
  async currentSession(): Promise<AppUser | null> {
    const token = readStorage(StorageKeys.accessToken);
    if (!token) return null;
    try {
      return await authService.me();
    } catch {
      return null;
    }
  },

  async forgotPassword(email: string): Promise<void> {
    await backendApi.post("/api/auth/forgot-password", { email });
  },
};
