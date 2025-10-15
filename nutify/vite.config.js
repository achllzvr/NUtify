import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    proxy: {
      "/api": {
        target: "https://nutify.site",
        changeOrigin: true,
        secure: true,
        // Map /api/* -> https://nutify.site/api.php?action=*
        rewrite: (path) => path.replace(/^\/api/, "/api.php"),
        // Ensure cookies from upstream are valid on localhost during dev
        cookieDomainRewrite: "localhost",
        configure: (proxy) => {
          proxy.on("proxyRes", (proxyRes) => {
            const setCookie = proxyRes.headers["set-cookie"];
            if (setCookie) {
              proxyRes.headers["set-cookie"] = setCookie.map((c) =>
                c.replace(/Domain=[^;]+/i, "Domain=localhost")
              );
            }
          });
        },
      },
    },
  },
});
