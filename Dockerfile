FROM oven/bun:latest

COPY package.json .
COPY bun.lockb .
COPY bunfig.toml .
RUN bun install

COPY . .
RUN bun run rescript build
RUN bunx tailwindcss -o public/output.css --minify
RUN bun run build.mjs

ENV PORT 3000

CMD ["bun", "server/Server.js"]
