import type { ReactNode } from "react";

export function ShimmerBox({ height, className = "" }: { height: number; className?: string }) {
  return (
    <div
      className={"animate-pulse rounded-[12px] bg-surface-elevated " + className}
      style={{ height }}
    />
  );
}

export function HomeFeedSkeleton() {
  return (
    <div className="flex flex-col gap-4 p-4">
      {Array.from({ length: 4 }).map((_, i) => (
        <ShimmerBox key={i} height={88} />
      ))}
    </div>
  );
}

export function AppStateError({ message, onRetry }: { message: string; onRetry: () => void }) {
  return (
    <div className="flex flex-col items-center gap-4 px-8 py-12 text-center">
      <CloudOffIcon />
      <p className="text-sm text-text-secondary">{message}</p>
      <button
        onClick={onRetry}
        className="rounded-[12px] border border-divider px-6 py-3 text-sm font-bold text-text-primary"
      >
        Retry
      </button>
    </div>
  );
}

export function AppStateEmpty({ message, icon }: { message: string; icon?: ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-4 px-8 py-12 text-center whitespace-pre-line">
      {icon ?? <BallOutlineIcon />}
      <p className="text-sm text-text-secondary">{message}</p>
    </div>
  );
}

function CloudOffIcon() {
  return (
    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="text-text-muted">
      <path
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M3 3l18 18M9.5 5.5A6 6 0 0118 10a4 4 0 010 8H7a4 4 0 01-2.3-7.3"
      />
    </svg>
  );
}

function BallOutlineIcon() {
  return (
    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="text-text-muted">
      <circle cx="12" cy="12" r="9" strokeWidth="1.5" />
      <path
        strokeWidth="1.2"
        d="M12 6.5l3.2 2.3-1.2 3.8h-4l-1.2-3.8L12 6.5zM12 2.5v4M12 21.5v-4M21 12h-4M3 12h4"
      />
    </svg>
  );
}
