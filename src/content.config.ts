import { defineCollection, z } from 'astro:content';

const writing = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    category: z.enum(['poem', 'essay', 'journal', 'other']),
    excerpt: z.string().max(200),
    series: z.string().optional(),
    seriesOrder: z.number().optional(),
    draft: z.boolean().default(false),
  }),
});

const art = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    medium: z.enum(['photography', 'drawing', 'mixed-media', 'other']),
    image: z.string(),
    note: z.string().optional(),
    draft: z.boolean().default(false),
  }),
});

const architecture = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    typology: z.enum(['residential', 'public', 'commercial', 'concept', 'other']),
    year: z.number(),
    heroImage: z.string(),
    images: z.array(z.string()).optional(),
    excerpt: z.string(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { writing, art, architecture };
