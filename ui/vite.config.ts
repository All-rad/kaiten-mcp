import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// TODO: Add compression plugin (gzip/brotli) for production builds
// TODO: Implement PWA support for offline capability
// TODO: Consider bundle analysis tool for size optimization
// TODO: Add environment-based configuration (dev/staging/prod)
// TODO: Enable source maps for production debugging

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    strictPort: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
  },
})
