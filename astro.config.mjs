// @ts-check
import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";
import { parse as parseToml } from "toml";
import { readFileSync } from "fs";

// Read the configuration file to get the dev port
const configContent = readFileSync("content/configuration.toml", "utf-8");
const config = parseToml(configContent);
const port = config._.site.devPort || 4321;

// https://astro.build/config
export default defineConfig({
  server: {
    port: port,
    host: true,
  },
  vite: {
    plugins: [tailwindcss()],
  },
});
