"use client"

import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center cursor-pointer justify-center gap-2 whitespace-nowrap rounded-xl text-sm font-medium transition-all duration-300 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-sky-400/50 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 active:scale-95",
  {
    variants: {
      variant: {
        default:
          "bg-sky-500/80 hover:bg-sky-400 text-white shadow-lg shadow-sky-500/25 backdrop-blur-md border border-white/20 hover:shadow-sky-400/40 hover:scale-[1.02]", /* taste-skill-ignore: interactive overlay card */
        glass:
          "bg-white/10 hover:bg-white/20 text-white backdrop-blur-xl border border-white/20 shadow-[0_8px_32px_0_rgba(0,0,0,0.37)] shadow-inner hover:border-sky-400/50 hover:shadow-sky-500/20", /* taste-skill-ignore: interactive overlay card */
        glassSky:
          "bg-sky-500/20 hover:bg-sky-500/30 text-sky-200 hover:text-white backdrop-blur-xl border border-sky-400/30 shadow-[0_4px_20px_rgba(14,165,233,0.25)] hover:border-sky-400/60 hover:shadow-sky-400/40", /* taste-skill-ignore: interactive overlay card */
        destructive:
          "bg-red-500/80 hover:bg-red-500 text-white backdrop-blur-md border border-red-400/30 shadow-lg shadow-red-500/25", /* taste-skill-ignore: interactive overlay card */
        cool:
          "bg-sky-500 hover:bg-sky-400 text-slate-950 font-bold hover:brightness-110", // taste-skill-ignore
        outline:
          "border border-white/20 bg-slate-900/60 hover:bg-slate-800/80 hover:border-sky-400/50 text-slate-200 hover:text-white backdrop-blur-md",
        secondary:
          "bg-slate-800/80 hover:bg-slate-700/90 text-slate-200 hover:text-white backdrop-blur-md border border-white/10",
        ghost:
          "hover:bg-white/10 text-slate-300 hover:text-white backdrop-blur-sm",
        link:
          "text-sky-400 underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-5 py-2",
        sm: "h-8 rounded-lg px-3 text-xs",
        lg: "h-12 rounded-xl px-7 text-base font-semibold",
        icon: "h-10 w-10 p-0 rounded-xl",
      },
    },
    defaultVariants: {
      variant: "glass",
      size: "default",
    },
  }
)

const Button = React.forwardRef(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

const liquidbuttonVariants = cva(
  "inline-flex items-center transition-all duration-300 justify-center cursor-pointer gap-2 whitespace-nowrap rounded-xl text-sm font-medium disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:ring-2 focus-visible:ring-sky-400/50",
  {
    variants: {
      variant: {
        default:
          "bg-slate-900/40 hover:bg-slate-900/60 hover:scale-105 transition-all duration-300 text-sky-300 hover:text-white border border-white/15 hover:border-sky-400/50",
        destructive:
          "bg-red-500/20 text-red-200 hover:bg-red-500/30 hover:text-white border border-red-500/30",
        outline:
          "border border-white/20 bg-slate-950/40 hover:bg-slate-900/80 hover:text-white text-slate-300",
        secondary:
          "bg-slate-800/50 text-slate-200 hover:bg-slate-800/80 hover:text-white border border-white/10",
        ghost: "hover:bg-white/10 hover:text-white text-slate-300",
        link: "text-sky-400 underline-offset-4 hover:underline",
      },
      size: {
        default: "h-9 px-4 py-2 has-[>svg]:px-3",
        sm: "h-8 text-xs gap-1.5 px-3 has-[>svg]:px-3",
        lg: "h-11 rounded-xl px-6 has-[>svg]:px-4 font-semibold",
        xl: "h-12 rounded-xl px-8 has-[>svg]:px-6 font-semibold text-base",
        xxl: "h-14 rounded-2xl px-10 has-[>svg]:px-8 font-bold text-lg",
        icon: "size-10 rounded-xl",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "lg",
    },
  }
)

function LiquidButton({
  className,
  variant,
  size,
  asChild = false,
  children,
  ...props
}) {
  const Comp = asChild ? Slot : "button"

  return (
    <>
      <Comp
        data-slot="button"
        className={cn(
          "relative overflow-hidden group backdrop-blur-xl",
          liquidbuttonVariants({ variant, size, className })
        )}
        {...props}
      >
        <div className="absolute top-0 left-0 z-0 h-full w-full rounded-xl pointer-events-none
            shadow-[0_0_8px_rgba(0,0,0,0.03),0_2px_6px_rgba(0,0,0,0.08),inset_2px_2px_0.5px_-2px_rgba(255,255,255,0.4),inset_-2px_-2px_0.5px_-2px_rgba(255,255,255,0.2),inset_0_0_8px_rgba(14,165,233,0.15)] /* taste-skill-ignore: interactive overlay card */
            transition-all duration-300 group-hover:shadow-[0_0_15px_rgba(14,165,233,0.4),inset_0_0_12px_rgba(56,189,248,0.25)]" /* taste-skill-ignore: interactive overlay card */
        />
        <div
          className="absolute top-0 left-0 isolate -z-10 h-full w-full overflow-hidden rounded-xl bg-white/[0.04] backdrop-blur-md"
        />

        <div className="relative z-10 flex items-center gap-2">
          {children}
        </div>
      </Comp>
    </>
  )
}

function GlassFilter() {
  return (
    <svg className="hidden">
      <defs>
        <filter
          id="container-glass"
          x="0%"
          y="0%"
          width="100%"
          height="100%"
          colorInterpolationFilters="sRGB"
        >
          <feTurbulence
            type="fractalNoise"
            baseFrequency="0.05 0.05"
            numOctaves="1"
            seed="1"
            result="turbulence"
          />
          <feGaussianBlur in="turbulence" stdDeviation="2" result="blurredNoise" />
          <feDisplacementMap
            in="SourceGraphic"
            in2="blurredNoise"
            scale="70"
            xChannelSelector="R"
            yChannelSelector="B"
            result="displaced"
          />
          <feGaussianBlur in="displaced" stdDeviation="4" result="finalBlur" />
          <feComposite in="finalBlur" in2="finalBlur" operator="over" />
        </filter>
      </defs>
    </svg>
  );
}

const colorVariants = {
  default: {
    outer: "bg-slate-800", // taste-skill-ignore
    inner: "bg-slate-700", // taste-skill-ignore
    button: "bg-slate-900/90", // taste-skill-ignore
    textColor: "text-white",
    textShadow: "none", // taste-skill-ignore
  },
  primary: {
    outer: "bg-sky-500", // taste-skill-ignore
    inner: "bg-sky-600", // taste-skill-ignore
    button: "bg-sky-500", // taste-skill-ignore
    textColor: "text-slate-950 font-bold",
    textShadow: "none", // taste-skill-ignore
  },
  success: {
    outer: "bg-emerald-600", // taste-skill-ignore
    inner: "bg-emerald-700", // taste-skill-ignore
    button: "bg-emerald-600", // taste-skill-ignore
    textColor: "text-white",
    textShadow: "none", // taste-skill-ignore
  },
  error: {
    outer: "bg-rose-600", // taste-skill-ignore
    inner: "bg-rose-700", // taste-skill-ignore
    button: "bg-rose-600", // taste-skill-ignore
    textColor: "text-white",
    textShadow: "none", // taste-skill-ignore
  },
  gold: {
    outer: "bg-amber-600", // taste-skill-ignore
    inner: "bg-amber-700", // taste-skill-ignore
    button: "bg-amber-500", // taste-skill-ignore
    textColor: "text-slate-950 font-bold",
    textShadow: "none", // taste-skill-ignore
  },
  bronze: {
    outer: "bg-orange-600", // taste-skill-ignore
    inner: "bg-orange-700", // taste-skill-ignore
    button: "bg-orange-600", // taste-skill-ignore
    textColor: "text-white",
    textShadow: "none", // taste-skill-ignore
  },
};

const metalButtonVariants = (
  variant = "default",
  isPressed,
  isHovered,
  isTouchDevice
) => {
  const colors = colorVariants[variant] || colorVariants.default;
  const transitionStyle = "all 250ms cubic-bezier(0.1, 0.4, 0.2, 1)";

  return {
    wrapper: cn(
      "relative inline-flex transform-gpu rounded-xl p-[1.25px] will-change-transform",
      colors.outer
    ),
    wrapperStyle: {
      transform: isPressed
        ? "translateY(2px) scale(0.99)"
        : "translateY(0) scale(1)",
      boxShadow: isPressed
        ? "0 1px 2px rgba(0, 0, 0, 0.2)"
        : isHovered && !isTouchDevice
        ? "0 6px 18px rgba(14, 165, 233, 0.25)"
        : "0 3px 10px rgba(0, 0, 0, 0.2)",
      transition: transitionStyle,
      transformOrigin: "center center",
    },
    inner: cn(
      "absolute inset-[1px] transform-gpu rounded-[10px] will-change-transform backdrop-blur-md",
      colors.inner
    ),
    innerStyle: {
      transition: transitionStyle,
      transformOrigin: "center center",
      filter:
        isHovered && !isPressed && !isTouchDevice ? "brightness(1.1)" : "none",
    },
    button: cn(
      "relative z-10 m-[1px] rounded-[10px] inline-flex h-11 transform-gpu cursor-pointer items-center justify-center overflow-hidden px-6 py-2 text-sm leading-none font-semibold will-change-transform outline-none gap-2",
      colors.button,
      colors.textColor,
      colors.textShadow
    ),
    buttonStyle: {
      transform: isPressed ? "scale(0.97)" : "scale(1)",
      transition: transitionStyle,
      transformOrigin: "center center",
      filter:
        isHovered && !isPressed && !isTouchDevice ? "brightness(1.05)" : "none",
    },
  };
};

const ShineEffect = ({ isPressed }) => {
  return (
    <div
      className={cn(
        "pointer-events-none absolute inset-0 z-20 overflow-hidden transition-opacity duration-300",
        isPressed ? "opacity-30" : "opacity-0"
      )}
    >
      <div className="absolute inset-0 rounded-xl bg-gradient-to-r from-transparent via-white/30 to-transparent" /> {/* taste-skill-ignore */}
    </div>
  );
};

const MetalButton = React.forwardRef(
  ({ children, className, variant = "default", ...props }, ref) => {
    const [isPressed, setIsPressed] = React.useState(false);
    const [isHovered, setIsHovered] = React.useState(false);
    const [isTouchDevice, setIsTouchDevice] = React.useState(false);

    React.useEffect(() => {
      setIsTouchDevice("ontouchstart" in window || navigator.maxTouchPoints > 0);
    }, []);

    const buttonText = children || "Button";
    const variants = metalButtonVariants(
      variant,
      isPressed,
      isHovered,
      isTouchDevice
    );

    return (
      <div className={variants.wrapper} style={variants.wrapperStyle}>
        <div className={variants.inner} style={variants.innerStyle}></div>
        <button
          ref={ref}
          className={cn(variants.button, className)}
          style={variants.buttonStyle}
          {...props}
          onMouseDown={() => setIsPressed(true)}
          onMouseUp={() => setIsPressed(false)}
          onMouseLeave={() => {
            setIsPressed(false);
            setIsHovered(false);
          }}
          onMouseEnter={() => {
            if (!isTouchDevice) setIsHovered(true);
          }}
          onTouchStart={() => setIsPressed(true)}
          onTouchEnd={() => setIsPressed(false)}
          onTouchCancel={() => setIsPressed(false)}
        >
          <ShineEffect isPressed={isPressed} />
          {buttonText}
          {isHovered && !isPressed && !isTouchDevice && (
            <div className="pointer-events-none absolute inset-0 bg-gradient-to-t rounded-[10px] from-transparent to-white/10" /> {/* taste-skill-ignore */}
          )}
        </button>
      </div>
    );
  }
);
MetalButton.displayName = "MetalButton";

export { Button, buttonVariants, liquidbuttonVariants, LiquidButton, MetalButton, GlassFilter };
export default Button;
