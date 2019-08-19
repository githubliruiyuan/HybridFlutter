const AdmZip = require('adm-zip');
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');

function exitsFile(filepath) {
    return fs.existsSync(filepath);
}
function makeZip(filepath) {
    if(!filepath || !filepath.endsWith('.html')){
        return;
    }
    let htmlfile = filepath, 
    cssfile = filepath.replace('.html', '.css'), 
    jsonfile = filepath.replace('.html', '.json');

    if(!exitsFile(htmlfile)) {
        console.log(chalk.red(`${htmlfile} not exits.Ignore zip.`));
        return;
    }
    if(!exitsFile(jsonfile)) {
        console.log(chalk.red(`${jsonfile} not exits.Ignore zip.`));
        return;
    }

    let zip = new AdmZip();
    zip.addLocalFile(htmlfile);
    zip.addLocalFile(jsonfile);

    if(exitsFile(cssfile)){
        zip.addLocalFile(cssfile);
    }

    let zipfile = filepath.replace('.html', '.zip');
    zip.writeZip(zipfile, (err) =>{
        if(err){
            console.log(chalk.red(`${zipfile} zip error ${err}`));
        }
    });
}

zipper =  function (fileOrDir){
    if(fs.lstatSync(fileOrDir).isFile()){
        //file
        makeZip(fileOrDir);
    } else {
        var paths = fs.readdirSync(fileOrDir).filter((value, i) => {
            return value.endsWith('.html');
        });
        paths.forEach((f) => {
            let file = path.join(fileOrDir, f);
            makeZip(file);
        });
    }
}

module.exports = zipper;