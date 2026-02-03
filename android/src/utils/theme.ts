export const theme = {
    colors: {
        primary: '#3B6BA5', // Primary Blue
        secondary: '#3AA79D', // Secondary Teal
        background: '#1E1E1E', // Background Dark
        surface: '#2A2A2A', // Card Surface
        text: '#FFFFFF',
        textDim: 'rgba(255, 255, 255, 0.6)',
        success: '#4CAF50',
        warning: '#FFB84D',
        error: '#E57373',
        info: '#64B5F6',
        border: 'rgba(255, 255, 255, 0.1)',
    },
    spacing: {
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32,
    },
    borderRadius: {
        sm: 6,
        md: 12,
        lg: 24,
        xl: 32,
        full: 9999,
    },
    typography: {
        h1: {
            fontSize: 34,
            lineHeight: 42,
            fontWeight: '700' as const,
        },
        h2: {
            fontSize: 28,
            lineHeight: 36,
            fontWeight: '600' as const,
        },
        body: {
            fontSize: 16,
            lineHeight: 24,
            fontWeight: '400' as const,
        },
        caption: {
            fontSize: 12,
            lineHeight: 16,
            fontWeight: '400' as const,
        },
    },
};
