@react.component
let make = (~href, ~children, ~className="", ~rel="") => {
  <Link
    href
    className={className ++ "border-stone-600 underline decoration-dotted outline-none ring-stone-400 hover:border-solid focus:ring-2 dark:ring-stone-600 dark:focus:bg-stone-800"}
    rel>
    children
  </Link>
}
