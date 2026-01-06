import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { TanStackRouterVite } from "@tanstack/router-vite-plugin";

export default defineConfig({
  plugins: [react(), TanStackRouterVite()],
  server: {
    host: "0.0.0.0", // Listen on all network interfaces for Netlify
    port: 5173,
    strictPort: false, // Allow fallback to another port if 5173 is taken
    allowedHosts: ["devserver-feat-public-score-rev3--fvs-metrics.netlify.app"],
  },
  define: {
    'import.meta.env.VITE_NETLIFY_CONTEXT': JSON.stringify(process.env.CONTEXT || 'development'),
  },
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: "./src/test/setup.ts",
  },
});
