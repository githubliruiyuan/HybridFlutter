/**
 * 创建模板
 */
let path = require('path');
let fs = require('fs');
let logger = require('./logger')
module.exports = function(tplcode, tplname){
    let projectDir = path.resolve('.'), clidir = __dirname, tplDir = path.resolve(clidir, 'tpl')
    logger.log(`cli dir:${clidir}\n  template create dir:${projectDir}`)

    let srcDir = path.resolve(projectDir, 'src')
    if(!fs.existsSync(srcDir)){
        fs.mkdirSync(srcDir)
    }

    let files = fs.readdirSync(tplDir).filter((x) => x.endsWith('.tpl'))
    files.forEach((x) => {
        let name = x.replace('.tpl', ''), ext = path.extname(name)
        name = `${tplcode}${ext}`

        let src = path.resolve(tplDir, x)
        let dest = path.resolve(projectDir, 'src', name)
        
        let txt = fs.readFileSync(src).toString()

        //replace code、name
        txt = txt.replace('${code}', tplcode)
        txt = txt.replace('${name}', tplname)
        
        //write file
        fs.writeFileSync(dest, txt)
    });
    
    logger.success(`create template cdoe :${tplcode}    name:${tplname} successfully`)
}