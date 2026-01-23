import type { Config } from 'tailwindcss'

export default {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        background: '#050505',
        surface: '#0a0a0a',
        panel: '#121212',
        border: '#2a2a2a',
        primary: '#00ff41',
        'primary-dim': 'rgba(0, 255, 65, 0.1)',
        warning: '#ffb300',
        danger: '#ff3333',
        text: {
          main: '#e0e0e0',
          muted: '#737373',
          dim: '#404040'
        },
        'ops-black': '#0a0a0b',
        'ops-panel': '#121214',
        'ops-border': '#27272a',
        'ops-accent': '#06b6d4',
        'ops-accent-dim': 'rgba(6, 182, 212, 0.1)',
        'ops-text': '#e4e4e7',
        'ops-text-dim': '#a1a1aa',
        'fvs-accent': '#00ff41',
        'fvs-accent-dim': 'rgba(0, 255, 65, 0.1)',
        ops: {
          black: '#0a0a0b',
          panel: '#121214',
          border: '#27272a',
          accent: '#06b6d4',
          'accent-dim': 'rgba(6, 182, 212, 0.1)',
          text: '#e4e4e7',
          'text-dim': '#a1a1aa'
        }
      },
      fontFamily: {
        mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'Monaco', 'monospace'],
        sans: ['"Inter"', 'sans-serif'],
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        }
      }
    },
  },
  plugins: [],
} satisfies Config
