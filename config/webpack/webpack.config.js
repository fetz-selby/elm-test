const path = require("path");
const Dotenv = require("dotenv-webpack");

const isDevMode = process.env.NODE_ENV === 'development';

const withCacheLoader = isDevMode
  ? ['cache-loader', 'babel-loader', 'ts-loader']
  : ['babel-loader', 'ts-loader'];

const elmLoaderOptions = isDevMode
  ? [
      {
        loader: 'elm-hot-webpack-loader',
      },
      { loader: 'elm-webpack-loader', options: { debug: true } },
    ]
  : [
      {
        loader: 'elm-webpack-loader',
        options: {
          optimize: true,
        },
      },
    ];

module.exports = {
  entry: path.resolve(__dirname, '../', '../',  "src/index.ts"),
  output: {
    filename: "index.js",
    path: path.resolve(__dirname, "dist"),
  },
  plugins: [new Dotenv()],
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {
            files: [path.resolve(__dirname, '../', '../',  "src/Main.elm")],
          },
        },
      },
      // {
      //   test: /\.(t|j)sx?$/,
      //   exclude: /node_modules/,
      //   use: withCacheLoader,
      // },
      // {
      //   test: /\.elm$/,
      //   exclude: [/elm-stuff/, /node_modules/],
      //   use: elmLoaderOptions,
      // },
      {
        test: /\.(html)$/,
        exclude: [/node_modules/],
        use: {
          loader: 'html-loader',
          options: {
            minimize: true,
          },
        },
      },
      {
        test: /\.(svg|png|jpg|gif)$/,
        exclude: [/node_modules/],
        use: {
          loader: 'file-loader',
          options: {
            name: '[name].[ext]',
            outputPath: 'assets/images',
          },
        },
      },
    ],
  },
  resolve: {
    modules: ['src', 'node_modules'],
    extensions: ['.ts', '.tsx', '.js'],
  },
};
