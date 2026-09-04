export default function SplashPage() {
  return (
    <div className="bg-brand-gradient-vertical flex min-h-dvh items-center justify-center">
      <div className="flex flex-col items-center gap-5 px-8 text-center">
        <div
          className="bg-brand-gradient flex h-24 w-24 items-center justify-center rounded-full"
          style={{ boxShadow: "0 0 32px 4px rgba(26,218,154,0.35)" }}
        >
          <BallIcon />
        </div>
        <h1 className="text-[32px] font-extrabold tracking-tight text-white">HALA SOCCER</h1>
        <p className="text-sm text-white/70">Everything Football. In One Place.</p>
      </div>
    </div>
  );
}

function BallIcon() {
  return (
    <svg width="52" height="52" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <circle cx="12" cy="12" r="9.5" stroke="white" strokeWidth="1.5" />
      <path
        d="M12 6.5l3.2 2.3-1.2 3.8h-4l-1.2-3.8L12 6.5zM12 2.5v4M12 21.5v-4M21.5 12h-4M2.5 12h4M18.5 5.5l-2.8 2.8M5.5 18.5l2.8-2.8M18.5 18.5l-2.8-2.8M5.5 5.5l2.8 2.8"
        stroke="white"
        strokeWidth="1"
        strokeLinecap="round"
      />
    </svg>
  );
}
