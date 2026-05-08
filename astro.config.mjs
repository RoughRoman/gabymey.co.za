import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import react from '@astrojs/react';

const isDev = process.env.NODE_ENV !== 'production';

const integrations = [mdx(), react()];
let adapter;

if (isDev) {
  const { default: keystatic } = await import('@keystatic/astro');
  const { default: node } = await import('@astrojs/node');
  integrations.push(keystatic());
  adapter = node({ mode: 'middleware' });
}

export default defineConfig({
  output: 'static',
  adapter,
  integrations,
});
