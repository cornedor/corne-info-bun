FROM oven/bun:latest

COPY package.json .
COPY bun.lockb .
COPY bunfig.toml .
RUN bun install

COPY . .
RUN bunx tailwindcss -i ./styles/base.css -o public/output.css --minify
RUN bun run rescript build
RUN bun run build.mjs

ENV PORT 3000

CMD ["bun", "server/Server.js"]
