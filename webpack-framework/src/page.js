global.pages = {};

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

    function RealPage(pageId) {

        this.pageId = pageId;

        this.cc = new CC(pageId);

        // 需要加这一行赋值，不然在模板使用cc.调用不到
        var cc = this.cc;

        this.evalInPage = function (jsContent) {
            if (!jsContent) {
                console.log("js content is empty!");
            }
            eval(jsContent);
        }
    
        this.getExpValue = function (script) {
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
            return value;
        }
        
        this.handleRepeat = function (script) {
            const expFunc = exp => {
                return new Function('', 'with(this){' + exp + '}').bind(
                    this.data
                )();
            };
            var array = expFunc(script);
            if(!array) return 0;
            return array.length;
        }
    
        this.setData = function (dataObj) {
            console.log("setData");
            console.log(JSON.stringify(this.data));
            for (var key in dataObj) {
                var str = "this.data." + key + " = dataObj['" + key + "']";
                eval(str);
            }
            var startTime = Date.now();
            this.refresh();
            var endTime = Date.now();
            console.log("耗时:"+(endTime-startTime));
        }
    };

    var pageObj = new RealPage(pageId);
    cachePage(pageId, pageObj);
}

function cachePage(pageId, page) {
    if (page) {
        global.pages[pageId] = page;
    } else {
        console.log("page: <" + pageId + "> is empty");
    }
}

global.getPage = function(pageId) {
    return global.pages[pageId];
}

global.Page = function(obj) {
    // 这里的page是个零时变量
    global.page = obj;
}

global.loadPage = loadPage;
