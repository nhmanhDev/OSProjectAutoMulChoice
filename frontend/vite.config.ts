
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [react()],
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx', '.json'],
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    target: 'esnext',
    outDir: 'dist',
    emptyOutDir: true,
  },
  // Serve from root in production (monolithic frontend)
  base: process.env.VITE_BASE_URL || '/',
  server: {
    port: 3000,
    open: true,
    proxy: {
      // Proxy API requests to FastAPI backend
      '/upload-image': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/results': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  },
});