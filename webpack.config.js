const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'index.js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: {
        loader: 'elm-webpack-loader',
        options: {
            files: [
              path.resolve(__dirname, "src/Main.elm"),
            ]
          }
      }
    }]
  }
};