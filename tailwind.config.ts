import type { Config } from "tailwindcss";
import defaultTheme from "tailwindcss/defaultTheme";
import type { PluginAPI } from "tailwindcss/types/config";

export default {
  content: [
    // "./{_s,client,components,layouts,pages,rescript}/*.{js,mdx,res}",
    // "./{_s,client,components,layouts,pages,rescript}/**/*.{js,mdx,res}",
    "./_s/**/*.js",
    "./layouts/**/*.js",
    "./styles/base.css",
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
        ".font-wght-800": {
          "font-variation-settings": `'wght' 800;`,
        },
      });
    },
  ],
} satisfies Config;
