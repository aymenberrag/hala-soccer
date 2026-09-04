import type { ReactNode } from "react";

import { PrimaryButton } from "@/components/common/ui";

export function OnboardingStepScaffold({
  step,
  totalSteps,
  title,
  subtitle,
  onSkip,
  onNext,
  nextLabel = "Next",
  nextEnabled = true,
  loading = false,
  error,
  children,
}: {
  step: number;
  totalSteps: number;
  title: string;
  subtitle: string;
  onSkip?: () => void;
  onNext: () => void;
  nextLabel?: string;
  nextEnabled?: boolean;
  loading?: boolean;
  error?: string | null;
  children: ReactNode;
}) {
  return (
    <div className="flex min-h-dvh flex-col bg-background">
      <div className="flex items-center gap-3 px-6 pt-4">
        <div className="flex flex-1 gap-1">
          {Array.from({ length: totalSteps }).map((_, i) => (
            <div
              key={i}
              className={"h-1 flex-1 rounded-full " + (i < step ? "bg-brand-green-bright" : "bg-divider")}
            />
          ))}
        </div>
        {onSkip && (
          <button onClick={onSkip} className="text-sm font-semibold text-text-secondary">
            Skip
          </button>
        )}
      </div>
      <div className="flex-1 overflow-y-auto px-6 py-6">
        <h1 className="text-[24px] font-extrabold text-text-primary">{title}</h1>
        <p className="mt-1 text-sm text-text-secondary">{subtitle}</p>
        {error && <p className="mt-4 rounded-[12px] bg-error/10 px-4 py-3 text-sm text-error">{error}</p>}
        <div className="mt-6">{children}</div>
      </div>
      <div className="p-6">
        <PrimaryButton onClick={onNext} disabled={!nextEnabled} loading={loading}>
          {nextLabel}
        </PrimaryButton>
      </div>
    </div>
  );
}
