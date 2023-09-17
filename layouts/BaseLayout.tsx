import { ComponentChildren } from "preact";
import { memo } from "preact/compat";
import { Header } from "../components/Header";
import { SlimLink } from "../components/SlimLink";

interface BaseLayoutProps {
  children?: ComponentChildren;
  title?: ComponentChildren;
}

export function _BaseLayout({ children, title }: BaseLayoutProps) {
  return (
    <div class="flex min-h-screen max-w-screen-md flex-col gap-1 bg-stone-100 contrast-more:bg-white dark:bg-stone-900 md:border-r md:border-dashed md:border-stone-300 lg:ml-10 lg:border-l">
      <Header />
      {title && (
        <h2 class="font-wght-680 ml-auto inline w-max max-w-full pl-0 font-heading text-lg dark:text-black contrast-more:dark:text-white sm:text-3xl md:text-5xl sm:mt-1 md:mt-2">
          <span class="bg-amber-400 box-decoration-clone p-1 pl-6 pt-0 contrast-more:dark:bg-amber-700 sm:leading-[1.3]">
            {title}
          </span>
        </h2>
      )}
      <article class="max-w-screen-md p-4 pl-6 pt-20">{children}</article>
      <footer class="flex items-center gap-2 p-4 pl-6 text-sm">
        Follow me:
        <SlimLink href="https://cd0.nl/@corne" rel="me">
          @corne@cd0.nl
        </SlimLink>
        -
        <SlimLink href="https://github.com/cornedor/">
          cornedor on GitHub
        </SlimLink>
        or
        <SlimLink href="#">Share</SlimLink>
      </footer>
    </div>
  );
}

export const BaseLayout = memo(_BaseLayout);
