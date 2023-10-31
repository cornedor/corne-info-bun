type props = {children: React.element, className?: string}
type linkProps = {children: React.element, href: string, rel: option<string>}

type components = {
  p: JsxU.component<props>,
  ul: JsxU.component<props>,
  ol: JsxU.component<props>,
  li: JsxU.component<props>,
  a: JsxU.component<linkProps>,
  h2: JsxU.component<props>,
  h3: JsxU.component<props>,
  h4: JsxU.component<props>,
  h5: JsxU.component<props>,
  em: JsxU.component<props>,
  code: JsxU.component<props>,
  pre: JsxU.component<props>,
}

let components = {
  p: ({children}) => <p className="py-2"> children </p>,
  ul: ({children}) => <ul className="py-2 pl-6 list-disc"> children </ul>,
  ol: ({children}) => <ul className="py-2 pl-6 list-decimal"> children </ul>,
  li: ({children}) => <li className="py-1 list-disc"> children </li>,
  a: ({children, href, rel}) =>
    switch rel {
    | Some(rel) => <Link href className="underline" rel> children </Link>
    | None => <Link href className="underline"> children </Link>
    },
  h2: ({children}) => <h2 className="text-3xl font-heading font-wght-800"> children </h2>,
  h3: ({children}) => <h3 className="text-2xl font-heading"> children </h3>,
  h4: ({children}) => <h4 className="text-xl font-bold"> children </h4>,
  h5: ({children}) => <h5 className="font-bold"> children </h5>,
  em: ({children}) => <em className="italic"> children </em>,
  pre: props => {
    let preClassName = "overflow-auto rounded shadow bg-stone-50 p-2"
    switch props {
    | {className: ?None, children} => <pre className=preClassName> children </pre>
    | {className: ?Some(className), children} =>
      <pre className={preClassName ++ className}> children </pre>
    }
  },
  code: ({children}) => <code className="italic"> children </code>,
}
