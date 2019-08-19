/**
 * es6 转 es5
 */
const babelcore = require('babel-core');

transform = function (es6Code) {
    return es6Code;
    var es5Code = babelcore.transform(es6Code, {
      presets: ['es2015']
    }).code;
    return es5Code;
}
module.exports = transform;