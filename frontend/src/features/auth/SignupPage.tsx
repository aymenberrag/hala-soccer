import { type FormEvent, useState } from "react";
import { Link } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { useAuth } from "@/context/AuthContext";
import { PrimaryButton, TextField } from "@/components/common/ui";

export default function SignupPage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { signup } = useAuth();

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (name.trim().length < 2) return setError("Enter your name");
    if (!email.includes("@")) return setError("Enter a valid email");
    if (password.length < 8) return setError("At least 8 characters, with a letter & number");
    if (confirm !== password) return setError("Passwords don't match");

    setLoading(true);
    setError(null);
    const err = await signup(name.trim(), email.trim(), password, confirm);
    setLoading(false);
    setError(err);
  }

  return (
    <div className="min-h-dvh bg-background px-6 py-8">
      <form onSubmit={onSubmit} className="flex flex-col gap-4">
        <div className="bg-brand-gradient flex h-16 w-16 items-center justify-center rounded-full text-3xl">⚽</div>
        <div>
          <h1 className="text-[28px] font-extrabold text-text-primary">Create your account</h1>
          <p className="mt-1 text-sm text-text-secondary">Join Hala Soccer and follow what matters to you.</p>
        </div>
        {error && <p className="rounded-[12px] bg-error/10 px-4 py-3 text-sm text-error">{error}</p>}
        <TextField label="Name" autoComplete="name" value={name} onChange={(e) => setName(e.target.value)} />
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
          autoComplete="new-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <TextField
          label="Confirm password"
          type="password"
          autoComplete="new-password"
          value={confirm}
          onChange={(e) => setConfirm(e.target.value)}
        />
        <PrimaryButton type="submit" loading={loading} className="mt-2">
          Sign Up
        </PrimaryButton>
        <p className="text-center text-sm text-text-secondary">
          Already have an account?{" "}
          <Link to={AppRoutes.login} className="font-semibold text-brand-green-bright">
            Log In
          </Link>
        </p>
      </form>
    </div>
  );
}
