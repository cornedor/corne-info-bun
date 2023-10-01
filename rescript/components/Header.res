@react.component
let make = () => {
  <>
    <nav className="group/linklist -mb-1 flex w-full gap-4 p-4 pl-6">
      <NavLink href="/"> {React.string("Home")} </NavLink>
      <NavLink href="/alice"> {React.string("Alice in Wonderland")} </NavLink>
      <NavLink href="/fediverse"> {React.string("Fediverse")} </NavLink>
    </nav>
    <h1
      className="mt-0 bg-amber-400 px-2 pl-6 font-heading text-2xl font-extralight dark:text-black contrast-more:dark:bg-amber-700 contrast-more:dark:text-white sm:text-4xl md:text-8xl">
      {React.string("Corné Dorrestijn")}
    </h1>
  </>
}
