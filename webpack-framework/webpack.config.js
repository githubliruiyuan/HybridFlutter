/*
  eslint-disable import/no-extraneous-dependencies
  eslint-disable arrow-body-style
  eslint-disable no-unused-vars
*/

var path = require('path');
 
module.exports = {
    entry: "./src/framework.js",
    output: {
        path: path.resolve("./", "dist"),
        filename: "framework.js",
    },
    module: {
       rules: [
            {
                test: [/.js$/],
                exclude: [/node_modules/],
                loader: 'babel-loader'
            },
            {
                test: /\.scss$/,
                exclude: [/node_modules/],
                use: [
                    {
                        loader: 'style-loader'
                    },
                    {
                        loader: 'css-loader'
                    },
                    {
                        loader: 'sass-loader'
                    }
                ]
            },
            {
                test: /\.css$/,
                exclude: [/node_modules/],
                use: [
                    {
                        loader: 'style-loader'
                    },
                    {
                        loader: 'css-loader'
                    }
                ]
            },
            {
                test: /\.woff(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: "url-loader?limit=10000&minetype=application/font-woff"
            },
            {
                test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: "file-loader"
            }
        ],
    },
    stats: {
        colors: true,
    },
    // devtool: 'source-map'
};
