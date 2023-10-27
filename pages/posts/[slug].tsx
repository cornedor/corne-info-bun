import { PageConfig } from "../../utils/renderPage";

export const config: PageConfig = {
  statusCode: 404,
  title: "Page not found",
};

export default function BlogNotFound() {
  return <>This article does not exists.</>;
}
