import type { Config } from "tailwindcss";
import defaultTheme from "tailwindcss/defaultTheme";
import type { PluginAPI } from "tailwindcss/types/config";

export default {
  content: [
    "./{client,components,layouts,pages,server,styles}/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue,rescript}",
  ],
  theme: {
    fontFamily: {
      heading: ["Playfair Display Variable", ...defaultTheme.fontFamily.serif],
      serif: ["Vollkorn Variable", ...defaultTheme.fontFamily.serif],
      mono: defaultTheme.fontFamily.mono,
      sans: defaultTheme.fontFamily.sans,
    },
    listStyleType: {
      none: "none",
      roman: "upper-roman",
      decimal: "decimal",
      disc: "disc",
    },
    extend: {},
  },
  plugins: [
    function ({ addComponents, theme }: PluginAPI) {
      addComponents({
        ".font-wght-680": {
          "font-variation-settings": `'wght' 680;`,
        },
      });
    },
  ],
} satisfies Config;
