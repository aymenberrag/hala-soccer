import { type FormEvent, useState } from "react";
import { useNavigate } from "react-router-dom";

import { profileService } from "@/services/profileService";
import { ApiException } from "@/services/apiException";
import { PrimaryButton, TextField } from "@/components/common/ui";

export default function ChangePasswordPage() {
  const navigate = useNavigate();
  const [current, setCurrent] = useState("");
  const [next, setNext] = useState("");
  const [confirm, setConfirm] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (next !== confirm) {
      setError("New passwords don't match.");
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await profileService.changePassword(current, next);
      setDone(true);
    } catch (err) {
      setError(err instanceof ApiException ? err.fieldErrors?.current_password ?? err.message : "Something went wrong.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="min-h-dvh pb-4">
      <div className="flex items-center gap-2 px-4 py-3">
        <button onClick={() => navigate(-1)} className="text-xl text-text-primary">
          ‹
        </button>
        <h1 className="text-base font-bold text-text-primary">Change Password</h1>
      </div>

      <div className="px-4">
        {done ? (
          <div className="flex flex-col items-center gap-3 py-12 text-center">
            <span className="text-4xl text-brand-green-bright">✓</span>
            <p className="text-lg font-bold text-text-primary">Password updated</p>
            <button onClick={() => navigate(-1)} className="text-sm font-semibold text-brand-green-bright">
              Done
            </button>
          </div>
        ) : (
          <form onSubmit={onSubmit} className="flex flex-col gap-4">
            {error && <p className="rounded-[12px] bg-error/10 px-4 py-3 text-sm text-error">{error}</p>}
            <TextField label="Current password" type="password" value={current} onChange={(e) => setCurrent(e.target.value)} />
            <TextField label="New password" type="password" value={next} onChange={(e) => setNext(e.target.value)} />
            <TextField
              label="Confirm new password"
              type="password"
              value={confirm}
              onChange={(e) => setConfirm(e.target.value)}
            />
            <PrimaryButton type="submit" loading={saving} className="mt-2">
              Update Password
            </PrimaryButton>
          </form>
        )}
      </div>
    </div>
  );
}
