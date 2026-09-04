// Ported from lib/core/constants/api_constants.dart's StorageKeys +
// lib/core/storage/app_storage.dart. Uses localStorage (not sessionStorage)
// so a returning user skips onboarding/login the same way the Flutter app
// does — there is no browser equivalent of Flutter's secure keychain
// storage, so tokens live in localStorage like any other web app; see
// frontend/README.md for the tradeoff this implies.
export const StorageKeys = {
  onboardingComplete: "hala_onboarding_complete",
  accessToken: "hala_access_token",
  refreshToken: "hala_refresh_token",
} as const;

export function readStorage(key: string): string | null {
  try {
    return window.localStorage.getItem(key);
  } catch {
    return null;
  }
}

export function writeStorage(key: string, value: string): void {
  try {
    window.localStorage.setItem(key, value);
  } catch {
    // Storage unavailable (private browsing, quota, etc.) — degrade
    // silently, same spirit as the Flutter app's SecureStorage wrapper.
  }
}

export function removeStorage(key: string): void {
  try {
    window.localStorage.removeItem(key);
  } catch {
    // ignore
  }
}
