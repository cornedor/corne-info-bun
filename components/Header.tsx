import { Link } from "./Link";
import { NavLink } from "./NavLink";

export function Header() {
  return (
    <>
      <nav class="group/linklist -mb-1 flex w-full gap-4 p-4 pl-6">
        <NavLink href="/">Home</NavLink>
        <NavLink href="/alice">Alice in Wonderland</NavLink>
        <NavLink href="/fediverse">Fediverse</NavLink>
      </nav>
      <h1 class="mt-0 bg-amber-400 px-2 pl-6 font-heading text-2xl font-extralight dark:text-black contrast-more:dark:bg-amber-700 contrast-more:dark:text-white sm:text-4xl md:text-8xl">
        Corné Dorrestijn
      </h1>
    </>
  );
}
