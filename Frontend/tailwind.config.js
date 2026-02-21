/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#16a34a',
          secondary: '#0ea5e9',
          accent: '#f59e0b',
        },
      },
    },
  },
  plugins: [],
};
