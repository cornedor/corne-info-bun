import { PageConfig } from "../utils/renderPage";
import { NavLink } from "../components/NavLink";

export default function About() {
  const formatter = new Intl.DateTimeFormat("en-US", {
    dateStyle: "full",
  });
  return (
    <ol class="list-roman pl-5" reversed>
      <li>
        <NavLink
          href="/blog/building-a-simple-nextjs-clone-with-bun"
          class="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center"
        >
          <span>Creating a blog with Bun</span>
          <span class="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
          <span class="text-sm text-stone-600 md:text-base md:text-inherit">
            {formatter.format(new Date("2023-03-27"))}
          </span>
        </NavLink>
      </li>
      <li>
        <NavLink
          href="/blog/nothing-here"
          class="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center"
        >
          <span>Non exsisting blog post</span>
          <span class="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
          <span class="text-sm text-stone-600 md:text-base md:text-inherit">
            {formatter.format(new Date("2023-03-27"))}
          </span>
        </NavLink>
      </li>
      <li>
        <NavLink
          href="/blog/two-counters"
          class="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center"
        >
          <span>Two counters</span>
          <span class="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
          <span class="text-sm text-stone-600 md:text-base md:text-inherit">
            {formatter.format(new Date("2023-03-27"))}
          </span>
        </NavLink>
      </li>
      <li>
        <NavLink
          href="/blog/docker-registry-trough-traefik"
          class="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center"
        >
          <span>Docker Registry trough Traefik</span>
          <span class="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
          <span class="text-sm text-stone-600 md:text-base md:text-inherit">
            {formatter.format(new Date("2023-03-27"))}
          </span>
        </NavLink>
      </li>
    </ol>
  );
}

export const config: PageConfig = {
  title: "Blog",
};
