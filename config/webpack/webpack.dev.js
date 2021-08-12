const { readFileSync } = require('fs');
const { merge } = require('webpack-merge');
const config = require('./webpack.config');
const dotenv = require('dotenv');
dotenv.config();


module.exports = (env) =>
  merge(config, {
    mode: 'development',
    devtool: 'inline-source-map',
    output: { filename: '[name].min.js' },
    resolve: {
      extensions: ['.ts', '.tsx', '.js'],
    },
    context: __dirname,
    devServer: {
      hot: true,
      noInfo: false,
      compress: true,
      historyApiFallback: true,
      port: process.env.PORT || 3002,
      host: process.env.HOST || 'localhost',
      openPage: '/',
      stats: {
        'errors-only': true,
        children: false,
        chunks: false,
        warnings: false,
      },
    },
  });
