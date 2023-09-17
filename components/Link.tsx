import { Component, JSX } from "preact";

export interface LinkProps extends JSX.HTMLAttributes<HTMLAnchorElement> {
  href: string;
  state?: any;
}

export function Link({ onClick, onMouseEnter, state, ...props }: LinkProps) {
  if (!props.href.startsWith("/")) {
    return <a {...props} />;
  }
  return (
    <a
      {...props}
      onMouseEnter={(e) => {
        onMouseEnter?.(e);
        const url = new URL(props.href, document.location.href);

        dispatchEvent(
          new CustomEvent("_s_l", {
            detail: {
              href: url,
            },
          })
        );
      }}
      onClick={(e) => {
        e.preventDefault();
        if (onClick) {
          onClick(e);
        }

        const url = new URL(props.href, document.location.href);

        history.pushState(state, "", url);

        dispatchEvent(new Event("_s_p"));
      }}
    />
  );
}
