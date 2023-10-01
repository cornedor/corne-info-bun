@react.component
let make = (~href, ~children, ~className="") => {
  <Link
    href
    className={className ++ "px-3 py-1 underline decoration-dotted outline-none ring-stone-400 after:inline-block after:translate-x-0 after:text-stone-600 hover:border-solid hover:bg-stone-200 hover:decoration-solid hover:!opacity-100 hover:after:-translate-y-1 hover:after:translate-x-1 hover:after:text-stone-400 focus:bg-stone-200 focus:ring-2 focus:after:-translate-y-1 focus:after:translate-x-1 focus:after:text-stone-500 active:after:-translate-y-2 active:after:translate-x-2 motion-safe:after:transition-transform dark:ring-stone-600 dark:after:text-stone-100 dark:hover:bg-stone-800 dark:hover:after:text-stone-400 dark:focus:bg-stone-800"}>
    children
  </Link>
}
