import { type FormEvent, useState } from "react";
import { Link } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { authService } from "@/services/authService";
import { ApiException } from "@/services/apiException";
import { PrimaryButton, TextField } from "@/components/common/ui";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!email.includes("@")) {
      setError("Enter a valid email");
      return;
    }
    setLoading(true);
    setError(null);
    try {
      await authService.forgotPassword(email.trim());
      setSent(true);
    } catch (err) {
      setError(err instanceof ApiException ? err.message : "Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-dvh bg-background px-6 py-8">
      <div className="flex flex-col gap-4">
        <h1 className="text-[28px] font-extrabold text-text-primary">Reset your password</h1>
        {sent ? (
          <>
            <p className="text-sm text-text-secondary">
              If an account exists for {email}, we've sent instructions to reset the password.
            </p>
            <Link to={AppRoutes.login} className="text-sm font-semibold text-brand-green-bright">
              Back to Log In
            </Link>
          </>
        ) : (
          <form onSubmit={onSubmit} className="flex flex-col gap-4">
            <p className="text-sm text-text-secondary">
              Enter your account email and we'll send you a link to reset your password.
            </p>
            {error && <p className="rounded-[12px] bg-error/10 px-4 py-3 text-sm text-error">{error}</p>}
            <TextField
              label="Email"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <PrimaryButton type="submit" loading={loading}>
              Send Reset Link
            </PrimaryButton>
          </form>
        )}
      </div>
    </div>
  );
}
