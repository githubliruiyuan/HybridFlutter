var path = require('path')
var glob = require('glob')
/**
 * 读取指定路径下的文件
 * @param {String} glob 表达式
 * @param {String} base 基础路径
 */
exports.getEntries = function (globPath, base, replaceed) {
    var entries = {}
    glob.sync(globPath).forEach(function (entry) {
        //获取对应文件的名称
        console.log(entry)
        var moduleName = path.basename(entry, '.js');
        let entry_ = './src/'+path.basename(entry);
        // let entry_ = base +path.basename(entry);
        entries[moduleName] = entry_
    })
    console.log(entries)
    return entries;
}
