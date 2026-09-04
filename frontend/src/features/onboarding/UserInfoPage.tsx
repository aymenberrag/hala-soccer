import { useState } from "react";
import { useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { usePreferencesDraft } from "@/context/PreferencesDraftContext";
import { Chip, TextField } from "@/components/common/ui";
import { OnboardingStepScaffold } from "./OnboardingStepScaffold";

const GENDERS = [
  { value: "male", label: "Male" },
  { value: "female", label: "Female" },
  { value: "prefer_not_to_say", label: "Prefer not to say" },
];

export default function UserInfoPage() {
  const { draft, setInfo } = usePreferencesDraft();
  const [country, setCountry] = useState(draft.country ?? "");
  const [age, setAge] = useState(draft.age != null ? String(draft.age) : "");
  const [gender, setGender] = useState<string | null>(draft.gender);
  const navigate = useNavigate();

  function next() {
    setInfo({ country: country.trim() || null, age: age.trim() ? Number(age.trim()) : null, gender });
    navigate(AppRoutes.preferencesTeams);
  }

  return (
    <OnboardingStepScaffold
      step={1}
      totalSteps={3}
      title="Tell us about you"
      subtitle="A little context helps Hala highlight the football that matters to you."
      onSkip={next}
      onNext={next}
      nextLabel="Continue"
    >
      <div className="flex flex-col gap-4">
        <TextField label="Country" placeholder="e.g. Algeria" value={country} onChange={(e) => setCountry(e.target.value)} />
        <TextField
          label="Age (optional)"
          type="number"
          placeholder="e.g. 24"
          value={age}
          onChange={(e) => setAge(e.target.value)}
        />
        <div>
          <span className="mb-2 block text-sm text-text-secondary">Gender (optional)</span>
          <div className="flex flex-wrap gap-2">
            {GENDERS.map((g) => (
              <Chip
                key={g.value}
                label={g.label}
                selected={gender === g.value}
                onClick={() => setGender(gender === g.value ? null : g.value)}
              />
            ))}
          </div>
        </div>
      </div>
    </OnboardingStepScaffold>
  );
}
