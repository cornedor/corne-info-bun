@react.component
let make = (~children, ~title) => {
  let titleElem = switch title {
  | None => <> </>
  | Some(title) =>
    <h2
      className="font-wght-680 ml-auto inline w-max max-w-full pl-0 font-heading text-lg dark:text-black contrast-more:dark:text-white sm:text-3xl md:text-5xl sm:mt-1 md:mt-2">
      <span
        className="bg-amber-400 box-decoration-clone p-1 pl-6 pt-0 contrast-more:dark:bg-amber-700 sm:leading-[1.3]">
        {React.string(title)}
      </span>
    </h2>
  }

  <div
    className="flex min-h-screen max-w-screen-md flex-col gap-1 bg-stone-100 contrast-more:bg-white dark:bg-stone-900 md:border-r md:border-dashed md:border-stone-300 lg:ml-10 lg:border-l">
    <Header />
    <CommonIcon />
    titleElem
    <article
      className="max-w-screen-md p-4 pl-6 pt-20"
      key={switch title {
      | Some(title) => title
      | _ => ""
      }}>
      children
    </article>
    <footer className="flex items-center gap-2 p-4 pl-6 text-sm">
      {React.string("Follow me: ")}
      <SlimLink href="https://cd0.nl/@corne" rel="me"> {React.string("@corne@cd0.nl")} </SlimLink>
      {React.string(" - ")}
      <SlimLink href="https://github.com/cornedor/">
        {React.string("cornedor on GitHub")}
      </SlimLink>
      {React.string(" or ")}
      <SlimLink href="#"> {React.string("Share")} </SlimLink>
    </footer>
  </div>
}
