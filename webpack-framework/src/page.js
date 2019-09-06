import {Watcher, getAssemblerSingle, observe} from './observer'

global.pages = {};
global.callbacks = {};
global.callbackArgs = {};

function loadPage(pageId) {
    if (!pageId) return;

    function CC(pageId) {

        this.pageId = pageId;

        this.requestData = {};

        this.onNetworkResult = function(requestId, result, json) {
            var req = this.requestData[requestId];
            if (req) {
                if (result === 'success') {
                    req['success'](JSON.parse(json));
                } else {
                    req['fail'](JSON.parse(json));
                }
                req['complete']();
            }
        }
    };

    // __native__ 开头是内部方法，避免与外部冲突
    function RealPage(pageId) {

        this.pageId = pageId;

        this.cc = new CC(pageId);

        // 需要加这一行赋值，不然在模板使用cc.调用不到
        var cc = this.cc;

        this.__native__evalInPage = function (jsContent) {
            if (!jsContent) {
                console.log("js content is empty!");
            }
            eval(jsContent);
        }
    
        this.__native__getExpValue = function (id, script) {
            let watcher = new Watcher(id, script);
            const expFunc = exp => {
                return new Function('', 'with(this){' + exp + '}').bind(
                    this.data
                )();
            };
            var value = expFunc(script);
            if (value instanceof Object) {
                return JSON.stringify(value);
            }
            if (value instanceof Array) {
                return JSON.stringify(value);
            }
            watcher.stopCollectMapping();
            return value;
        }
        
        this.__native__handleRepeat = function (id, script) {
            let watcher = new Watcher(id, script);
            const expFunc = exp => {
                return new Function('', 'with(this){' + exp + '}').bind(
                    this.data
                )();
            };
            var array = expFunc(script);
            if(!array) return 0;
            watcher.stopCollectMapping();
            return array.length;
        }

        this.__native__initComplete = function () {
            observe(this.data);
            getAssemblerSingle().getNeedUpdateMapping();
        }
    
        this.setData = function (dataObj) {
            console.log("call setData");
            for (var key in dataObj) {
                var str = "this.data." + key + " = dataObj['" + key + "']";
                eval(str);
            }
            this.__native__refresh();
            var startTime = Date.now();
            if(observe(this.data)) {
                let needUpdateMapping = getAssemblerSingle().getNeedUpdateMapping();
//            if (Object.keys(needUpdateMapping).length) {
//                this._updatePartlyData(JSON.stringify(needUpdateMapping));
//            }
            }
            var endTime = Date.now();
            console.log("耗时:"+(endTime-startTime));
        }

        function setTimeout(callback, ms, ...args) {
            var timerId = global.guid();
            global.callbacks[timerId] = callback;
            global.callbackArgs[timerId] = args;
            __native__setTimeout(pageId, timerId, ms);
            return timerId;
        }

        function clearTimeout(timerId) {
            var callback = global.callbacks[timerId];
            if (callback) {
                global.callbacks[timerId] = undefined;
                global.callbackArgs[timerId] = undefined;
            }
            __native__clearTimeout(timerId);
        }
    };

    var pageObj = new RealPage(pageId);
    cachePage(pageId, pageObj);
}

function cachePage(pageId, page) {
    if (page) {
        global.pages[pageId] = page;
    } else {
        console.log("page: (" + pageId + ") is empty");
    }
}

function callback(callbackId) {
    var callback = global.callbacks[callbackId];
    if (callback) {
        var args = global.callbackArgs[callbackId];
        callback(args);
    } else {
        console.log("callback: (" + callbackId + ") is empty");
    }
}

global.getPage = function(pageId) {
    return global.pages[pageId];
}

global.Page = function(obj) {
    // 这里的page是个临时变量
    global.page = obj;
}

global.loadPage = loadPage;
global.callback = callback;

