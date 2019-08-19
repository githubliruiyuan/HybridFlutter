const merge = require('webpack-merge');
var WebpackShellPlugin = require('webpack-shell-plugin');
const common = require('./webpack.common');

module.exports = merge(common, {
  devtool: "source-map",
  plugins: [
    new WebpackShellPlugin({onBuildEnd: ['node ./index.js build']})
  ]
});
