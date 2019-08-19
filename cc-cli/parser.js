const fs = require('fs');
const path = require('path');
const htmlparser = require("htmlparser2");
const shadyCss = require('shady-css-parser');
const chalk = require('chalk');
const logger = require('./logger');
const transform2es5 = require('./transform');
// const encrypter = require('./encrypt');
/**
 * link table,to point node relationship
 */
class Node {
    constructor() {
        this.prev = null;//prev node
        this.next = null;//next node
        this.data = null;//node's data
    }
}

class CCParser {
    /**
     * init parser with file path
     * @param {filepath} file 
     */
    constructor(file) {
        let stat = fs.lstatSync(file);
        if (stat.isFile()){
            this.file = file;
            this.dir = path.dirname(file);
        } else {
            this.file = null;
            this.dir = null;
        }
        this.result = {};
    }
    /**
     * entry point
     */
    async parse() {
        if (this.file) {
            //read file
            return await this.parseFile(this.file).then((content)=>{
                let jsonpath = this.file.replace(path.extname(this.file), '.json');
                fs.writeFileSync(jsonpath, content);
            });
        }
        return Promise.reject(new Error('file not exits'));
    }
    async parseFile(file){
        let content = fs.readFileSync(file).toString();
        if (!content || content.length == 0) {
            return Promise.reject('file content is empty.');
        }
        console.log(chalk.yellow(`Compling file ${file}.\n`));
        return await this.parseHTMLContent(content)
    }
    /**
    * parse css to json object
    * https://www.npmjs.com/package/shady-css-parser
    * @param {css text content} css
    */
    parseCSS(css) {
        if (!css) {
            return null;
        }
        var result = {};
        //process contains expression like {{}}
        if(css.includes('{{')){
            var regex1 = RegExp(/(?<name>.*?):(?<value>.*?);/, 'g');//非贪婪匹配
            var array1, expstr = '';
            try {
                while ((array1 = regex1.exec(css)) !== null) {
                    let name = array1.groups.name, value = array1.groups.value;
                    result[name] = value;
                }
            } catch (error) {

            }
            return result;
        }
        //other css
        const parser = new shadyCss.Parser();
        const ast = parser.parse(css);
        ast.rules.forEach((rule, index) => {
            if (rule.type === "ruleset") {
                let rulelist = {};
                rule.rulelist.rules.forEach((v) => {
                    rulelist[v.name] = v.value.text;
                });
                result[rule.selector] = rulelist;
            } else if (rule.type === "declaration") {
                result[rule.name] = rule.value.text;
            } else if (rule.type === "atRule") {//@
                if (rule.name == 'import') {//handle import css
                    let p = rule.parameters.replace(/"/g, '');
                    let filePath = path.join(this.dir, p);
                    result = this.parseCSSFile(filePath);
                }
            }
        });
        return result;
    }
    /**
     * parse css file
     * @param {*} filePath 
     */
    parseCSSFile(filePath) {
        if (fs.existsSync(filePath) == false) {
            return null;
        }
        let css = fs.readFileSync(filePath).toString();
        return this.parseCSS(css);
    }
    /**
     * html node json body builder
     * @param {*} tag 
     * @param {*} inner_html 
     * @param {*} child_nodes 
     */
    jsonBody(tag = '', inner_html = '', child_nodes = []) {
        return {
            "tag": tag,
            "innerHTML": inner_html,
            'childNodes': child_nodes,
            'datasets': {},
            'events': {},
            'directives': {},
            'attribStyle': {},
            'attrib': {}
        };
    }
    /**
     * 处理属性集合
     * @param {属性集合} attribs 
     * @param {节点数据} node 
     */
    handleAttributes(attribs, node){
        let that = this;
        Object.keys(attribs).forEach((o, i)=>{
            that.handleAttribute(o, attribs[o], node);
        });
        that.handleAttributeFinal(node);
    }
    /**
     * 处理属性
     * @param {attribute name} name 属性名
     * @param {attitude value} value 属性值
     * @param {节点数据} node data
     */
    handleAttribute(name, value, node) {
        if(!node || !name){
            return;
        }
        if (name === 'id') {//id
            node[name] = value;
        } else if (name === 'class') {//class
            node['className'] = value;
        } else if (name.indexOf('on') == 0) {//events
            node['events'][name] = value;
        } else if (name.indexOf('cc:') == 0) {//directives
            if (!node['repeatDirective']) {
                node['repeatDirective'] = {};
            }
            if (!node['shownDirective']) {
                node['shownDirective'] = {};
            }
            let repeatDirective = node['repeatDirective'], shownDirective = node['shownDirective'];
            let name_ = name.substr(4), attr = name.trim();
            if (attr.indexOf('cc:for') == 0) {
                if (attr == 'cc:for') {
                    repeatDirective['name'] = name_;
                    repeatDirective['expression'] = value;
                }
                else if (attr == 'cc:for-item') {
                    repeatDirective['item'] = value;
                }
                else if (attr == 'cc:for-index') {
                    repeatDirective['index'] = value;
                }
            }
            else if (attr == 'cc:if') {
                shownDirective['name'] = name_
                shownDirective['expression'] = value
            }
            else if (attr == 'cc:elif') {
                shownDirective['name'] = name_;
                shownDirective['expression'] = value;
            }
            else if (attr == 'cc:else') {
                shownDirective['name'] = name_;
                shownDirective['expression'] = value;
            }
        } else if (name == 'src') {//attribStyle
            node['attribStyle'][name.trim()] = value.trim();
        } else if (name == 'style') {//handleAttribute
            let styles = this.parseCSS(value);
            try {
                for (let n in styles) {
                    node['attribStyle'][n.trim()] = (styles[n]).trim();
                }
            } catch (error) {
                logger.fatal(error);
            }
        } else {//attrib
            node['attrib'][name] = value;
        }
        //dataset
        if (name.includes('data-')) {
            let dn = name.substr(8);
            node['datasets'][dn] = value;
        }
    }
    /**
     * 对属性做最后处理
     * @param {节点} node 
     */
    handleAttributeFinal(node) {
        //handle directives
        let directives = {};
        
        if (node['repeatDirective'] && Object.keys(node['repeatDirective']).length > 0) {
            let keys = Object.keys(node['repeatDirective']);
            if (keys.includes('item') === false) {
                node['repeatDirective']['item'] = 'item';
            }
            if (keys.includes('index') === false) {
                node['repeatDirective']['index'] = 'index';
            }
            directives['repeat'] = node['repeatDirective'];
        }
        delete node['repeatDirective'];
        //shown
        if (node['shownDirective'] && Object.keys(node['shownDirective']).length > 0) {
            directives['shown'] = node['shownDirective'];
        }
        delete node['shownDirective'];

        node['directives'] = directives;
    }
    _readFile(filepath){
        if(!filepath || typeof filepath!='string' || filepath.length == 0){
            return null;
        }
        let content = fs.readFileSync(filepath).toString()
        return content;
    }
    /**
     * handle extend script(a single js file for support webpack)
     */
    _handleScriptExtend(){
        let jsfile = path.resolve('.','dist', path.basename(this.file).replace('.html', '.bundle.js'));
        //let jsfile = this.file.replace('.html', '.js');
        try {
            if(fs.existsSync(jsfile) === false){
                logger.log(`bundle.js not exits:${jsfile}`)
                return;
            }
        } catch (error) {
            return;
        }
        let jscontent = this._readFile(jsfile)
        if(!jscontent || jscontent.length == 0){
            return;
        }

        //base64 encode
        jscontent = this._base64Str(jscontent) || ''

        this.result['script'] = this.jsonBody('script', jscontent);
    }
    _handleScript(str1) {
        //es6 to es5
        str1 = transform2es5(str1) || '';
        //导出function
        var regex1 = RegExp(/function\s*(?<funame>\w\S+?)\s*?\(.*?\)/, 'g');
        var array1, expstr = '';
        try {
            while ((array1 = regex1.exec(str1)) !== null) {
                console.log(`Found ${array1.groups.funame}. Next starts at ${regex1.lastIndex}.`);
                expstr +=`this["${array1.groups.funame}"] = ${array1.groups.funame};\n`
            }
            console.log(`export result:\n ${expstr}`);
        } catch (error) {
            
        }
        str1 += expstr;
        return str1;
    }
    /**
     * 对result做最后处理
     */
    handleResultFinal(){
        let result = this.result;
        //style
        let styles = this.parseCSS(result['style']['innerHTML']);
        result['style'] = styles || {};

        //fill default empty content
        this.fillDefaultContent('type', {}, result);
        this.fillDefaultContent('align', {}, result);
        this.fillDefaultContent('description', {}, result);

        //script extend
        this._handleScriptExtend();
    }
    /**
     * set a default val to result
     */
    fillDefaultContent(key, defaultValue, result){
        if(result[key]){
            return;
        }
        result[key] = defaultValue;
    }
    _base64Str(text){
        let buffer = new Buffer(text), base64Str = buffer.toString('base64');
        return base64Str;
    }
    async parseHTMLContent(content) {
        if (!content || typeof content != 'string') {
            return;
        }
        var currentNode = null;
        let result = this.result, heads = ['style','script', 'title', 'type', 'align', 'description'];
        let that = this;
        var parser = new htmlparser.Parser({
            onopentag: function (tagname, attribs) {
                //create new node,to link parent-child
                let node = new Node();
                node.data = that.jsonBody(tagname);
    
                if (currentNode) {//now, currentNode is prev node
                    //save prev node,to be use for prev
                    node.prev = currentNode;
                    currentNode.data['childNodes'].push(node.data);
                }
                currentNode = node;
                //处理属性
                that.handleAttributes(attribs, currentNode.data);
            },
            ontext: function (text) {
                if (!currentNode) {
                    return;
                }
                var innerText = text;
                let tagname = currentNode.data['tag'];
                if(tagname != 'style'){
                    innerText = innerText.trim();
                }
                currentNode.data['innerHTML'] += innerText;
            },
            onclosetag: function (tagname) {
                if(tagname != 'style') {
                    let content = currentNode.data['innerHTML'];
                    if(tagname == 'script') {
                        content = that._handleScript(content);
                    }
                    currentNode.data['innerHTML'] = that._base64Str(content);
                }
                if (currentNode.prev && currentNode.prev.data['tag'] == 'head' && heads.includes(tagname)) {
                    //move to top position
                    result[tagname] = currentNode.data;
                } else if (currentNode.prev && currentNode.prev.data['tag'] == 'html' && tagname == 'body') {
                    //move to top position
                    result[tagname] = currentNode.data;
                }

                //when meet close tag,parent node is current node's prev node
                currentNode = currentNode.prev;
            },
            onend: () => {
                that.handleResultFinal();
                console.log(chalk.yellow(JSON.stringify(result) + '\n'));
                console.log(chalk.green(`Parse file ${that.file} done.\n`))
            }
        }, { decodeEntities: true });
        parser.write(content);
        parser.end();
        await parser;
    
        return Promise.resolve(JSON.stringify(result));
    }
}

module.exports = {
    Parser: CCParser
}