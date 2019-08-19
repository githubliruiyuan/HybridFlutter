const path = require('path');
const CleanWebpackPlugin = require('clean-webpack-plugin');
var utils = require('./config');
var glob = require('glob')
const fs = require('fs')
var entrycache = require('./entry.js')
//当前工作目录的绝对路径
var ROOT_PATH = path.resolve(__dirname);
//要打包的源代码路径
var RESOURCES_PATH = path.resolve(ROOT_PATH, 'src');
//设置要打包的js文件为入口文件
var entrys = utils.getEntries(path.join(RESOURCES_PATH, '/*.js'), path.join(RESOURCES_PATH, '/'));
if(entrycache.length){
  let entrynew = {}
  entrynew[entrycache] = entrys[entrycache]
  entrys = entrynew
}
console.log('entrys:...')
console.log(entrys)
module.exports = {
  entry: entrys,
  devServer: {
      contentBase: './dist'
  },
  plugins: [
      new CleanWebpackPlugin()
  ],
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  module: {
    rules: [
      {
        test:/\.js$/,
            exclude: __dirname + 'node_modules',
            use:{
                loader:'babel-loader',
                options:{
                    //plugins:["@babel/plugin-transform-arrow-functions"]
                }
            }
       }
    ]
  }
}