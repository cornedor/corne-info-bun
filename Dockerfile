FROM oven/bun:latest

COPY package.json .
COPY bun.lockb .
COPY bunfig.toml .
RUN bun install

COPY . .
RUN bun run rescript build
RUN bun run build.mjs
RUN bunx tailwindcss -o public/output.css --minify

ENV PORT 3000

CMD ["bun", "server/Server.js"]
