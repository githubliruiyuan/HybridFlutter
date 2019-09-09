require('./observer');

global.pages = {};
global.callbacks = {};
global.callbackArgs = {};

function loadPage(pageId) {
    if (!pageId) return;

    function CC(pageId) {

        this.pageId = pageId;

        this.requestData = {};

        this.onNetworkResult = function(requestId, result, json) {
            let req = this.requestData[requestId];
            if (req) {
                if (result === 'success') {
                    req['success'](JSON.parse(json));
                } else {
                    req['fail'](JSON.parse(json));
                }
                req['complete']();
            }
        }
    }

    // __native__ 开头是内部方法，避免与外部冲突
    function RealPage(pageId) {

        this.pageId = pageId;

        this.cc = new CC(pageId);

        // 需要加这一行赋值，不然在模板使用cc.调用不到
        let cc = this.cc;

        this.__native__evalInPage = function (jsContent) {
            if (!jsContent) {
                console.log("js content is empty!");
            }
            eval(jsContent);
        };
    
        this.__native__getExpValue = function (id, type, prefix, script) {
            let watcher = new Watcher(id, type, prefix, script);
            let value = global.getExpValue(this.data, script);
            watcher.stopCollectMapping();
            return value;
        };
        
        this.__native__initComplete = function () {
            observe(this.data);
        };
    
        this.setData = function (dataObj) {
            console.log("call setData");
            for (var key in dataObj) {
                let str = "this.data." + key + " = dataObj['" + key + "']";
                eval(str);
            }
            let startTime = Date.now();
            var needUpdateMapping;
            if(observe(this.data)) {
                needUpdateMapping = getAssemblerSingle().getNeedUpdateMapping();
            }
            let endTime = Date.now();
            console.log("耗时:"+(endTime-startTime));
            if (needUpdateMapping) {
                this.__native__refresh(JSON.stringify(needUpdateMapping));
            }
        };

        function setTimeout(callback, ms, ...args) {
            let timerId = global.guid();
            global.callbacks[timerId] = callback;
            global.callbackArgs[timerId] = args;
            __native__setTimeout(pageId, timerId, ms);
            return timerId;
        }

        function clearTimeout(timerId) {
            let callback = global.callbacks[timerId];
            if (callback) {
                global.callbacks[timerId] = undefined;
                global.callbackArgs[timerId] = undefined;
            }
            __native__clearTimeout(timerId);
        }
    }

    let pageObj = new RealPage(pageId);
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
    let callback = global.callbacks[callbackId];
    if (callback) {
        let args = global.callbackArgs[callbackId];
        callback(args);
    } else {
        console.log("callback: (" + callbackId + ") is empty");
    }
}

global.getPage = function(pageId) {
    return global.pages[pageId];
};

global.Page = function(obj) {
    // 这里的page是个临时变量
    global.page = obj;
};

global.loadPage = loadPage;
global.callback = callback;
