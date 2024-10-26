// tailwind.config.js
module.exports = {
  content: [
      "./src/**/*.{js,jsx,ts,tsx}", // Adjust the path according to your project structure
  ],
  theme: {
      extend: {
          colors: {
              ucfBlack: '#000000',
              ucfGold: '#F8C500',
              ucfWhite: '#FFFFFF',
              ucfDarkGray: '#7D7F81',
              ucfLightGray: '#E4E4E4',
          },
      },
  },
  variants: {},
  plugins: [],
};
