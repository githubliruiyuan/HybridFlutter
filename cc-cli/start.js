/**
 * webpack打包   ->模板编译成json
 */
const parser = require('./parser');
const pwpackage = require('./wppackage');
const chalk = require('chalk')
const fs = require('fs')
const path = require('path')
const watcher = require('./watch')

module.exports = async function (argv) {
    if (argv.e && argv.e === 'dev') {
        try {
            let dir = argv.d || argv.f;
            if (fs.statSync(dir).isFile()) {
                dir = path.dirname(dir)
            }
            let w = new watcher(dir);
            w.start();
        } catch (error) {
            return Promise.reject(error);
        }
    }
    if (argv.d) {//编译目录
        let { d, e } = argv;
        if (argv.e && argv.e != 'dev') {
            await pwpackage(d, 'build');
        }

        let dir = d;
        if (dir) {
            var paths = fs.readdirSync(dir).filter((value, i) => {
                return value.endsWith('.html');
            });
            paths.forEach((v, i) => {
                let fullpath = path.join(dir, v);
                new parser.Parser(fullpath).parse()
            });
        }
        return Promise.resolve();
    } else if (argv.f) {//编译单个文件
        let { f, e } = argv;
        let dir = path.dirname(f);
        if (argv.env && argv.env != 'dev') {
            await pwpackage(dir ,'build');
        }
        return await new parser.Parser(f).parse();
    } else {
        console.log(chalk.red('请用--f指定模板文件或用--d指定模板目录\n'));
        return Promise.resolve();
    }
}
