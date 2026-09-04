import { type FormEvent, useState } from "react";
import { useNavigate } from "react-router-dom";

import { useAuth } from "@/context/AuthContext";
import { profileService } from "@/services/profileService";
import { ApiException } from "@/services/apiException";
import { Chip, PrimaryButton, TextField } from "@/components/common/ui";

const GENDERS = [
  { value: "male", label: "Male" },
  { value: "female", label: "Female" },
  { value: "prefer_not_to_say", label: "Prefer not to say" },
];

export default function ProfilePage() {
  const { user, logout, setUser } = useAuth();
  const navigate = useNavigate();
  const [editing, setEditing] = useState(false);

  return (
    <div className="pb-4">
      <h1 className="px-4 pt-4 pb-2 text-lg font-extrabold text-text-primary">Profile</h1>

      <div className="flex flex-col items-center gap-2 px-4 py-4">
        <div className="bg-brand-gradient flex h-20 w-20 items-center justify-center rounded-full text-3xl text-white">
          {user?.name ? user.name[0].toUpperCase() : "?"}
        </div>
        <p className="text-base font-bold text-text-primary">{user?.name}</p>
        <p className="text-sm text-text-muted">{user?.email}</p>
      </div>

      {editing ? (
        <div className="px-4">
          <EditPersonalInfoForm
            country={user?.country ?? null}
            age={user?.age ?? null}
            gender={user?.gender ?? null}
            onCancel={() => setEditing(false)}
            onSaved={(u) => {
              setUser(u);
              setEditing(false);
            }}
          />
        </div>
      ) : (
        <div className="flex flex-col gap-2 px-4">
          <MenuTile icon="👤" label="Personal information" onClick={() => setEditing(true)} />
          <MenuTile icon="🛡️" label="Favorite teams" onClick={() => navigate("/profile/favorites/teams")} />
          <MenuTile icon="🏆" label="Favorite leagues" onClick={() => navigate("/profile/favorites/leagues")} />
          <MenuTile icon="🔒" label="Change password" onClick={() => navigate("/profile/change-password")} />
          <div className="my-2 border-t border-divider" />
          <MenuTile icon="🚪" label="Log out" onClick={logout} danger />
        </div>
      )}
    </div>
  );
}

function MenuTile({
  icon,
  label,
  onClick,
  danger = false,
}: {
  icon: string;
  label: string;
  onClick: () => void;
  danger?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      className="flex items-center gap-3 rounded-[16px] border border-divider bg-surface-card p-4 text-left"
    >
      <span className="text-lg">{icon}</span>
      <span className={"flex-1 text-sm font-semibold " + (danger ? "text-error" : "text-text-primary")}>{label}</span>
      <span className="text-text-muted">›</span>
    </button>
  );
}

function EditPersonalInfoForm({
  country,
  age,
  gender,
  onCancel,
  onSaved,
}: {
  country: string | null;
  age: number | null;
  gender: string | null;
  onCancel: () => void;
  onSaved: (user: Awaited<ReturnType<typeof profileService.updatePersonalInfo>>) => void;
}) {
  const [countryValue, setCountryValue] = useState(country ?? "");
  const [ageValue, setAgeValue] = useState(age != null ? String(age) : "");
  const [genderValue, setGenderValue] = useState<string | null>(gender);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    try {
      const user = await profileService.updatePersonalInfo({
        country: countryValue.trim(),
        age: ageValue.trim() ? Number(ageValue.trim()) : undefined,
        gender: genderValue ?? undefined,
      });
      onSaved(user);
    } catch (err) {
      setError(err instanceof ApiException ? err.message : "Something went wrong.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-4 rounded-[16px] border border-divider bg-surface-card p-4">
      {error && <p className="rounded-[12px] bg-error/10 px-4 py-3 text-sm text-error">{error}</p>}
      <TextField label="Country" value={countryValue} onChange={(e) => setCountryValue(e.target.value)} />
      <TextField label="Age" type="number" value={ageValue} onChange={(e) => setAgeValue(e.target.value)} />
      <div>
        <span className="mb-2 block text-sm text-text-secondary">Gender</span>
        <div className="flex flex-wrap gap-2">
          {GENDERS.map((g) => (
            <Chip
              key={g.value}
              label={g.label}
              selected={genderValue === g.value}
              onClick={() => setGenderValue(genderValue === g.value ? null : g.value)}
            />
          ))}
        </div>
      </div>
      <div className="flex gap-2">
        <button type="button" onClick={onCancel} className="flex-1 rounded-[12px] border border-divider py-3 text-sm font-bold text-text-primary">
          Cancel
        </button>
        <PrimaryButton type="submit" loading={saving} className="flex-1">
          Save
        </PrimaryButton>
      </div>
    </form>
  );
}
