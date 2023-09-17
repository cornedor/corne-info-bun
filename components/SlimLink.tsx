import { Link, LinkProps } from "./Link";

export function SlimLink(props: LinkProps) {
  return (
    <Link
      {...props}
      class="border-stone-600 underline decoration-dotted outline-none ring-stone-400 hover:border-solid focus:ring-2 dark:ring-stone-600 dark:focus:bg-stone-800"
    />
  );
}
