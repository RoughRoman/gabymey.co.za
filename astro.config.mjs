import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';

const isDev = process.env.NODE_ENV !== 'production';

const integrations = [mdx()];

if (isDev) {
  const { default: keystatic } = await import('@keystatic/astro');
  integrations.push(keystatic());
}

export default defineConfig({
  output: 'static',
  integrations,
});
