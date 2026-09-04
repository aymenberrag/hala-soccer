import { type ButtonHTMLAttributes, type InputHTMLAttributes, type ReactNode, forwardRef } from "react";

export function PrimaryButton({
  className = "",
  loading = false,
  children,
  disabled,
  ...rest
}: ButtonHTMLAttributes<HTMLButtonElement> & { loading?: boolean }) {
  return (
    <button
      {...rest}
      disabled={disabled || loading}
      className={
        "flex h-[52px] w-full items-center justify-center rounded-[12px] bg-brand-green-bright text-[16px] font-bold tracking-[0.2px] text-brand-navy-dark transition-opacity disabled:opacity-40 " +
        className
      }
    >
      {loading ? <Spinner /> : children}
    </button>
  );
}

export function SecondaryButton({ className = "", children, ...rest }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      {...rest}
      className={
        "flex h-[52px] w-full items-center justify-center rounded-[12px] border border-divider text-[16px] font-bold text-text-primary " +
        className
      }
    >
      {children}
    </button>
  );
}

export function TextLinkButton({ className = "", children, ...rest }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button {...rest} className={"text-sm font-bold text-brand-green-bright " + className}>
      {children}
    </button>
  );
}

export function Spinner({ size = 20 }: { size?: number }) {
  return (
    <span
      className="inline-block animate-spin rounded-full border-2 border-current border-t-transparent"
      style={{ width: size, height: size, borderTopColor: "transparent" }}
    />
  );
}

interface TextFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  suffix?: ReactNode;
}

export const TextField = forwardRef<HTMLInputElement, TextFieldProps>(function TextField(
  { label, error, suffix, className = "", id, ...rest },
  ref,
) {
  const inputId = id ?? `field-${label.replace(/\s+/g, "-").toLowerCase()}`;
  return (
    <label htmlFor={inputId} className="block">
      <span className="mb-1.5 block text-sm text-text-secondary">{label}</span>
      <span className="relative flex items-center">
        <input
          ref={ref}
          id={inputId}
          {...rest}
          className={
            "h-[52px] w-full rounded-[12px] border bg-surface-elevated px-4 text-[14px] text-text-primary outline-none placeholder:text-text-muted focus:border-brand-green-bright " +
            (error ? "border-error" : "border-divider") +
            " " +
            className
          }
        />
        {suffix && <span className="absolute right-3 text-text-muted">{suffix}</span>}
      </span>
      {error && <span className="mt-1 block text-xs text-error">{error}</span>}
    </label>
  );
});

export function Card({ className = "", children }: { className?: string; children: ReactNode }) {
  return <div className={"rounded-[16px] border border-divider bg-surface-card " + className}>{children}</div>;
}

export function Chip({
  label,
  selected = false,
  onClick,
}: {
  label: string;
  selected?: boolean;
  onClick?: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={
        "rounded-full border px-3 py-1.5 text-sm font-medium transition-colors " +
        (selected
          ? "border-brand-green-bright bg-brand-green-bright/15 font-bold text-brand-green-bright"
          : "border-divider bg-surface-elevated text-text-muted")
      }
    >
      {label}
    </button>
  );
}
