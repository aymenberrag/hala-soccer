import { type FormEvent, useState } from "react";
import { Link, useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { useAuth } from "@/context/AuthContext";
import { PrimaryButton, TextField } from "@/components/common/ui";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { login } = useAuth();
  const navigate = useNavigate();

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!email.includes("@")) {
      setError("Enter a valid email");
      return;
    }
    if (!password) {
      setError("Enter your password");
      return;
    }
    setLoading(true);
    setError(null);
    const err = await login(email.trim(), password);
    setLoading(false);
    setError(err);
    // On success the root gate (driven by AuthContext state) redirects to
    // Home/preferences automatically — no explicit navigate() needed.
  }

  return (
    <div className="min-h-dvh bg-background px-6 py-8">
      <form onSubmit={onSubmit} className="flex flex-col gap-4">
        <div className="bg-brand-gradient flex h-16 w-16 items-center justify-center rounded-full text-3xl">⚽</div>
        <div>
          <h1 className="text-[28px] font-extrabold text-text-primary">Welcome back</h1>
          <p className="mt-1 text-sm text-text-secondary">Log in to keep up with your teams.</p>
        </div>
        {error && <p className="rounded-[12px] bg-error/10 px-4 py-3 text-sm text-error">{error}</p>}
        <TextField
          label="Email"
          type="email"
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <TextField
          label="Password"
          type="password"
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button
          type="button"
          onClick={() => navigate(AppRoutes.forgotPassword)}
          className="self-end text-sm font-semibold text-brand-green-bright"
        >
          Forgot password?
        </button>
        <PrimaryButton type="submit" loading={loading} className="mt-2">
          Log In
        </PrimaryButton>
        <p className="text-center text-sm text-text-secondary">
          Don't have an account?{" "}
          <Link to={AppRoutes.signup} className="font-semibold text-brand-green-bright">
            Sign Up
          </Link>
        </p>
      </form>
    </div>
  );
}
