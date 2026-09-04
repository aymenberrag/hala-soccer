import { useState } from "react";
import { useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { useAuth } from "@/context/AuthContext";
import { PrimaryButton, TextLinkButton } from "@/components/common/ui";

interface Slide {
  icon: string;
  title: string;
  subtitle: string;
}

const SLIDES: Slide[] = [
  {
    icon: "🌍",
    title: "Everything Football.\nIn One Place.",
    subtitle: "Live scores, fixtures, and results from leagues around the world.",
  },
  {
    icon: "⚽",
    title: "Follow Every Match",
    subtitle: "Live matches, upcoming fixtures, and full-time results — updated in real time.",
  },
  {
    icon: "⭐",
    title: "Follow Your Teams",
    subtitle: "Favorite the clubs you care about and keep them one tap away.",
  },
  {
    icon: "⚡",
    title: "Stay Connected",
    subtitle: "A fast, focused football experience — built for fans who never miss a moment.",
  },
];

export default function OnboardingPage() {
  const [page, setPage] = useState(0);
  const { completeOnboarding } = useAuth();
  const navigate = useNavigate();
  const isLast = page === SLIDES.length - 1;

  function finish() {
    completeOnboarding();
    navigate(AppRoutes.login, { replace: true });
  }

  function next() {
    if (isLast) finish();
    else setPage((p) => p + 1);
  }

  return (
    <div className="flex min-h-dvh flex-col bg-background">
      <div className="flex justify-end p-4">
        {!isLast && <TextLinkButton onClick={finish}>Skip</TextLinkButton>}
      </div>
      <div className="flex flex-1 flex-col items-center justify-center px-8 text-center">
        <div className="bg-brand-gradient flex h-[140px] w-[140px] items-center justify-center rounded-full text-6xl">
          {SLIDES[page].icon}
        </div>
        <h1 className="mt-12 whitespace-pre-line text-[28px] leading-tight font-extrabold text-text-primary">
          {SLIDES[page].title}
        </h1>
        <p className="mt-4 text-sm text-text-secondary">{SLIDES[page].subtitle}</p>
      </div>
      <div className="flex justify-center gap-1 pb-6">
        {SLIDES.map((_, i) => (
          <span
            key={i}
            className={
              "h-2 rounded-full transition-all " + (i === page ? "w-[22px] bg-brand-green-bright" : "w-2 bg-divider")
            }
          />
        ))}
      </div>
      <div className="p-6">
        <PrimaryButton onClick={next}>{isLast ? "Get Started" : "Next"}</PrimaryButton>
      </div>
    </div>
  );
}
