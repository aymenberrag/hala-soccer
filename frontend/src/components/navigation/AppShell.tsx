import { NavLink, Outlet } from "react-router-dom";

import { AppRoutes } from "@/app/routes";

const NAV_ITEMS = [
  { to: AppRoutes.home, label: "Home", icon: HomeIcon },
  { to: AppRoutes.matches, label: "Fixtures", icon: BallIcon },
  { to: AppRoutes.competitions, label: "Leagues", icon: TrophyIcon },
  { to: AppRoutes.favorites, label: "Favorites", icon: StarIcon },
  { to: AppRoutes.profile, label: "Profile", icon: PersonIcon },
];

/**
 * Mirrors HomeShell in home_shell.dart: the gradient pill nav bar stays
 * bottom-fixed on mobile widths. From `md` up we switch to a left rail so
 * desktop doesn't feel like a stretched phone screen (spec section 8-9)
 * while keeping exactly the same 5 destinations/icons.
 */
export default function AppShell() {
  return (
    <div className="min-h-dvh bg-background md:flex">
      <DesktopRail />
      <div className="mx-auto min-h-dvh w-full max-w-[480px] pb-24 md:max-w-[640px] md:pb-0">
        <Outlet />
      </div>
      <MobileNav />
    </div>
  );
}

function MobileNav() {
  return (
    <nav className="bg-brand-gradient fixed inset-x-2 bottom-2 z-40 flex h-16 items-center rounded-[16px] md:hidden">
      {NAV_ITEMS.map((item) => (
        <NavLink key={item.to} to={item.to} className="flex-1">
          {({ isActive }) => (
            <div
              className={
                "mx-1.5 flex flex-col items-center justify-center gap-0.5 rounded-[12px] py-2 " +
                (isActive ? "bg-white/15" : "")
              }
            >
              <item.icon active={isActive} />
              <span className={"text-[10px] font-semibold " + (isActive ? "text-white" : "text-brand-navy-dark")}>
                {item.label}
              </span>
            </div>
          )}
        </NavLink>
      ))}
    </nav>
  );
}

function DesktopRail() {
  return (
    <nav className="hidden w-56 shrink-0 flex-col gap-1 border-r border-divider p-4 md:flex">
      <div className="mb-6 px-2 text-lg font-extrabold tracking-tight text-text-primary">HALA SOCCER</div>
      {NAV_ITEMS.map((item) => (
        <NavLink key={item.to} to={item.to}>
          {({ isActive }) => (
            <div
              className={
                "flex items-center gap-3 rounded-[12px] px-3 py-2.5 text-sm font-semibold " +
                (isActive ? "bg-brand-green-bright/15 text-brand-green-bright" : "text-text-secondary")
              }
            >
              <item.icon active={isActive} />
              {item.label}
            </div>
          )}
        </NavLink>
      ))}
    </nav>
  );
}

function iconColor(active: boolean, activeColor = "white") {
  return active ? activeColor : "currentColor";
}

function HomeIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill={iconColor(active)}>
      <path d="M12 3l9 8h-3v9h-5v-6H11v6H6v-9H3l9-8z" />
    </svg>
  );
}
function BallIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={iconColor(active)} strokeWidth="1.6">
      <circle cx="12" cy="12" r="9" />
      <path d="M12 6.5l3.2 2.3-1.2 3.8h-4l-1.2-3.8L12 6.5z" />
    </svg>
  );
}
function TrophyIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={iconColor(active)} strokeWidth="1.6">
      <path d="M7 4h10v4a5 5 0 01-10 0V4z" />
      <path d="M7 5H4v1a4 4 0 004 4M17 5h3v1a4 4 0 01-4 4" />
      <path d="M12 13v4M9 20h6M9 17h6v3H9z" />
    </svg>
  );
}
function StarIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill={iconColor(active)}>
      <path d="M12 2.5l3.1 6.6 7.2.9-5.3 5 1.4 7.2L12 18.8l-6.4 3.4 1.4-7.2-5.3-5 7.2-.9L12 2.5z" />
    </svg>
  );
}
function PersonIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill={iconColor(active)}>
      <circle cx="12" cy="8" r="4" />
      <path d="M4 20c0-4.4 3.6-7 8-7s8 2.6 8 7v1H4v-1z" />
    </svg>
  );
}
