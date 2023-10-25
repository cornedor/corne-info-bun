@react.component
let make: Page.makeFn = () => {
  let formatter = Intl.DateTimeFormat.makeWithLocaleAndOptions(
    "en-US",
    {
      "dateStyle": "full",
    },
  )

  <ol className="list-roman pl-5 pt-20" reversed={true}>
    <li>
      <NavLink
        href="/features"
        className="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center">
        <span> {React.string("Features Test")} </span>
        <span className="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
        <span className="text-sm text-stone-600 md:text-base md:text-inherit">
          {React.string(Intl.DateTimeFormat.format(formatter, Date.fromString("2023-03-27")))}
        </span>
      </NavLink>
    </li>
    <li>
      <NavLink
        href="/blog/advent-of-code-2022-day-4-to-6"
        className="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center">
        <span> {React.string("Advent of Code 2022 Day 4 to 6")} </span>
        <span className="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
        <span className="text-sm text-stone-600 md:text-base md:text-inherit">
          {React.string(Intl.DateTimeFormat.format(formatter, Date.fromString("2023-03-27")))}
        </span>
      </NavLink>
    </li>
    <li>
      <NavLink
        href="/blog/building-a-simple-nextjs-clone-with-bun"
        className="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center">
        <span> {React.string("Creating a blog with Bun")} </span>
        <span className="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
        <span className="text-sm text-stone-600 md:text-base md:text-inherit">
          {React.string(Intl.DateTimeFormat.format(formatter, Date.fromString("2023-03-27")))}
        </span>
      </NavLink>
    </li>
    <li>
      <NavLink
        href="/blog/nothing-here"
        className="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center">
        <span> {React.string("Non existing blog post")} </span>
        <span className="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
        <span className="text-sm text-stone-600 md:text-base md:text-inherit">
          {React.string(Intl.DateTimeFormat.format(formatter, Date.fromString("2023-03-27")))}
        </span>
      </NavLink>
    </li>
    <li>
      <NavLink
        href="/blog/two-counters"
        className="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center">
        <span> {React.string("Two counters")} </span>
        <span className="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
        <span className="text-sm text-stone-600 md:text-base md:text-inherit">
          {React.string(Intl.DateTimeFormat.format(formatter, Date.fromString("2023-03-27")))}
        </span>
      </NavLink>
    </li>
    <li>
      <NavLink
        href="/blog/docker-registry-trough-traefik"
        className="mb-2 flex w-full flex-col justify-between md:flex-row md:items-center">
        <span> {React.string("Docker Registry trough Traefik")} </span>
        <span className="m-2 hidden h-[2px] flex-1 bg-stone-300 dark:bg-stone-700 md:block" />
        <span className="text-sm text-stone-600 md:text-base md:text-inherit">
          {React.string(Intl.DateTimeFormat.format(formatter, Date.fromString("2023-03-27")))}
        </span>
      </NavLink>
    </li>
  </ol>
}

let config: Page.pageConfig = {
  title: "Blog",
  useBaseLayout: true,
  statusCode: 200,
  getProps: async () => Js.Json.array([Js.Json.string("Foo")]),
}
