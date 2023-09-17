import { BaseLayout } from "../layouts/BaseLayout";

export interface PageConfig {
  useBaseLayout?: boolean;
  title?: string;
  statusCode?: number;
}

export async function renderPage(source: string) {
  const { default: App, config, getProps } = await import(source);
  const {
    useBaseLayout = true,
    title,
    statusCode,
  } = (config ?? {}) as PageConfig;

  let props = {};
  if (typeof getProps === "function") {
    props = await getProps();
  }

  const ssrConfig = { statusCode } as const;

  if (useBaseLayout) {
    return [
      <BaseLayout title={title}>
        <App {...props} />
      </BaseLayout>,
      ssrConfig,
    ] as const;
  }

  return [<App {...props} />, ssrConfig] as const;
}
