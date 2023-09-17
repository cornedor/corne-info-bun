import { ComponentChildren } from "preact";

interface IntroProps {
  children?: ComponentChildren;
}

export function Intro({ children }: IntroProps) {
  return (
    <p
      class="first-line:uppercase first-line:tracking-widest
    sm:first-letter:float-left sm:first-letter:mr-2
    sm:first-letter:font-heading sm:first-letter:text-6xl"
    >
      {children}
    </p>
  );
}
