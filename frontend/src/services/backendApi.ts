import axios, { type AxiosInstance, type InternalAxiosRequestConfig } from "axios";

import { ApiException } from "./apiException";
import { StorageKeys, readStorage, removeStorage, writeStorage } from "@/utils/storage";

// Mirrors ApiConstants.backendBaseUrl — override via .env (VITE_API_BASE_URL),
// same idea as Flutter's --dart-define=BACKEND_BASE_URL.
const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:5050";

export const backendApi: AxiosInstance = axios.create({
  baseURL: BASE_URL,
  timeout: 15_000,
  headers: { "Content-Type": "application/json" },
});

backendApi.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const skipAuth = (config as { skipAuth?: boolean }).skipAuth;
  if (!skipAuth) {
    const token = readStorage(StorageKeys.accessToken);
    if (token) {
      config.headers.set("Authorization", `Bearer ${token}`);
    }
  }
  return config;
});

let refreshPromise: Promise<boolean> | null = null;

async function tryRefresh(): Promise<boolean> {
  const refreshToken = readStorage(StorageKeys.refreshToken);
  if (!refreshToken) return false;
  try {
    const response = await axios.post(
      `${BASE_URL}/api/auth/refresh`,
      {},
      { headers: { Authorization: `Bearer ${refreshToken}` }, timeout: 15_000 },
    );
    writeStorage(StorageKeys.accessToken, response.data.access_token as string);
    return true;
  } catch {
    return false;
  }
}

backendApi.interceptors.response.use(
  (response) => response,
  async (error) => {
    const original = error.config as (InternalAxiosRequestConfig & { _retry?: boolean }) | undefined;

    if (!error.response) {
      throw new ApiException("Couldn't reach the server. Check your connection and try again.");
    }

    // One-shot refresh-and-retry on 401, same as the Flutter client.
    if (error.response.status === 401 && original && !original._retry && !(original as any).skipAuth) {
      original._retry = true;
      refreshPromise ??= tryRefresh().finally(() => {
        refreshPromise = null;
      });
      const refreshed = await refreshPromise;
      if (refreshed) {
        return backendApi(original);
      }
      removeStorage(StorageKeys.accessToken);
      removeStorage(StorageKeys.refreshToken);
    }

    const data = error.response.data ?? {};
    throw new ApiException(
      data.error ?? `Request failed (${error.response.status})`,
      error.response.status,
      data.field_errors ?? null,
    );
  },
);
