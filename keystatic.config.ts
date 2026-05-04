import { config, collection, fields } from '@keystatic/core';

export default config({
  storage: { kind: 'local' },

  collections: {
    writing: collection({
      label: 'Writing',
      slugField: 'title',
      path: 'src/content/writing/*',
      format: { contentField: 'content' },
      schema: {
        title: fields.slug({ name: { label: 'Title' } }),
        date: fields.date({ label: 'Date' }),
        category: fields.select({
          label: 'Category',
          options: [
            { label: 'Poem', value: 'poem' },
            { label: 'Essay', value: 'essay' },
            { label: 'Journal', value: 'journal' },
            { label: 'Other', value: 'other' },
          ],
          defaultValue: 'other',
        }),
        excerpt: fields.text({
          label: 'Excerpt',
          description: 'A short summary (max 200 characters).',
          multiline: false,
        }),
        series: fields.text({ label: 'Series Name', validation: { isRequired: false } }),
        seriesOrder: fields.integer({ label: 'Series Order', validation: { isRequired: false } }),
        draft: fields.checkbox({ label: 'Draft (hidden from site)', defaultValue: false }),
        content: fields.mdx({ label: 'Content' }),
      },
    }),

    art: collection({
      label: 'Art',
      slugField: 'title',
      path: 'src/content/art/*',
      format: { contentField: 'content' },
      schema: {
        title: fields.slug({ name: { label: 'Title' } }),
        date: fields.date({ label: 'Date' }),
        medium: fields.select({
          label: 'Medium',
          options: [
            { label: 'Photography', value: 'photography' },
            { label: 'Drawing', value: 'drawing' },
            { label: 'Mixed Media', value: 'mixed-media' },
            { label: 'Other', value: 'other' },
          ],
          defaultValue: 'other',
        }),
        image: fields.image({
          label: 'Image',
          directory: 'public/art',
          publicPath: '/art/',
        }),
        note: fields.text({ label: 'Short Note', multiline: true, validation: { isRequired: false } }),
        draft: fields.checkbox({ label: 'Draft (hidden from site)', defaultValue: false }),
        content: fields.mdx({ label: 'Additional Notes (optional)', description: 'Optional extended notes about this piece.' }),
      },
    }),

    architecture: collection({
      label: 'Architecture',
      slugField: 'title',
      path: 'src/content/architecture/*',
      format: { contentField: 'content' },
      schema: {
        title: fields.slug({ name: { label: 'Title' } }),
        date: fields.date({ label: 'Date' }),
        typology: fields.select({
          label: 'Typology',
          options: [
            { label: 'Residential', value: 'residential' },
            { label: 'Public', value: 'public' },
            { label: 'Commercial', value: 'commercial' },
            { label: 'Concept', value: 'concept' },
            { label: 'Other', value: 'other' },
          ],
          defaultValue: 'concept',
        }),
        year: fields.integer({ label: 'Year' }),
        heroImage: fields.image({
          label: 'Hero Image',
          directory: 'public/architecture',
          publicPath: '/architecture/',
        }),
        images: fields.array(
          fields.image({
            label: 'Image',
            directory: 'public/architecture',
            publicPath: '/architecture/',
          }),
          {
            label: 'Project Images',
            itemLabel: () => 'Image',
          }
        ),
        excerpt: fields.text({ label: 'Short Description', multiline: true }),
        draft: fields.checkbox({ label: 'Draft (hidden from site)', defaultValue: false }),
        content: fields.mdx({ label: 'Project Description' }),
      },
    }),
  },
});
