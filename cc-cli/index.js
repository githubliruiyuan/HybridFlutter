#!/usr/bin/env node
/**
 * use example :
 * node index.js c -e dev -d /Users/xxx/Documents/npm/demo
 * node index.js zip -p /Users/xxx/Documents/npm/demo
 */
const start = require('./start');
const zip = require('./zip');
const path = require('path');
const createtemplate = require('./command-tpl');
const watcher = require('./watch')
const logger = require('./logger')

const argv = require('yargs')
.command(
  'tpl',
  '创建页面',
  function (yargs) {//可选参数
    return yargs
      .option('name', {
        alias: 'n',
        describe: '指定页面名称'
      })
      .option('code', {
        alias: 'c',
        describe: '指定页面code'
      })
  },
  function (argv) {
    let {code , name} = argv
    if(!code){
      logger.fatal(`请用--code参数指定页面名字`);
      return;
    }
    if(!name){
      logger.fatal(`请用--name 参数指定页面名字`);
      return;
    }
     createtemplate(code, name)
  }
)
.command(
  'watch',
  '开启实时编译',
  function (yargs) {//可选参数
    return yargs
      .option('help', {
        alias: 'h',
        describe: '查看帮助'
      })
  },
  function (argv) {
     let dir = path.resolve('.')
     new watcher(dir).start()
  }
)
.command(
  'build',
  '编译工程',
  function (yargs) {//可选参数
    return yargs
      .option('help', {
        alias: 'h',
        describe: '查看帮助'
      })
  },
  function (argv) {
    let dir = path.resolve('.', 'src')
    start({"d": dir})
  }
)
.command(
    'zip',
    'zip压缩模板文件',
    function(yargs) {//可选参数
      return yargs
        .option('path', {
          alias: 'p',
          describe: '文件路径或目录'
        })
        .example(//示例
          'cc-cli -p /xxx/tpl',
          '压缩/xxx/tpl目录下的模板文件'
        )
        .example(//示例
          'cc-cli -p /xxx/tpl/xxx.html',
          '压缩/xxx/tpl/xxx的模板文件'
        )
    },
    function(argv) {
      if(argv.path){
        zip(argv.path);
      }
    }
  )
  .help('help').argv;

;(function () {
  if (argv.v) {//查看版本号
    let json = require('./package.json')
    console.log(json.version)
  }
})();