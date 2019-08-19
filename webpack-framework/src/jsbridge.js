
global.callBackJs = function(callbackId, data) {
    console.log("callbackId:" + callbackId + " data:" + data);
    if (task) {
        task.consumeCallBack(callbackId, data)
    }
}
//global.cms的附加和补充，会在attachGlobalBridge时挂靠在cms v8Object下
global.cmsAddition = {
    requireModule(moduleName){
        console.log("requireModule:" + moduleName);
        return requireModule(this, moduleName);
    }
}


global.Task = function (instanceId) {
    this.instanceId = instanceId;
    this.lastCallbackId = 0;
    this.callbacks = {};
    this.typof = function (v) {
        const s = Object.prototype.toString.call(v);
        return s.substring(8, s.length - 1);
    }.bind(this);

    this.normalizePrimitive = function (v) {
        var type = this.typof(v);
        switch (type) {
            case "Undefined":
            case "Null":
                return "";
            case "RegExp":
                return v.toString();
            case "Date":
                return v.toISOString();
            case "Number":
            case "String":
            case "Boolean":
            case "Array":
            case "Object":
                return v;
            default:
                return JSON.stringify(v);
        }
    }.bind(this);

    this.normalize = function (v, deep) {
        var normalize = this.normalize;
        var type = this.typof(v);
        if (type === "Function") {
            return this.addCallBack(v).toString();
        }
        if (deep) {
            if (type === "Object") {
                var object = {};
                for (var key in v) {
                    object[key] = this.normalize(v[key], true);
                }
                return object;
            }
            if (type === "Array") {
                var normalize = this.normalize;
                return v.map(function (item) {
                    return normalize(item, true);
                });
            }
        }
        return this.normalizePrimitive(v);
    }.bind(this);

    this.addCallBack = function (callback) {
        this.lastCallbackId++;
        this.callbacks[this.lastCallbackId] = callback;
        return this.lastCallbackId;
    }.bind(this);

    this.consumeCallBack = function (callbackId, data) {
        var callback = this.callbacks[callbackId];
        delete this.callbacks[callbackId];
        if (typeof callback === "function") {
            try {
                return callback.call(null, data);
            } catch (error) {
                console.error(
                    "Failed to execute the callback function:" + error.toString
                );
            }
        }
        return new Error("invalid callback id " + callbackId);
    }.bind(this);

    this.send = function (type, params, args, options) {
        var method = params["method"];
        var module = params["module"];
        var normalize = this.normalize;
        args = args.map(function (arg) {
            return normalize(arg, true);
        });
        switch (type) {
            case "module":
                return global.callNativeModule(
                    this.instanceId,
                    module,
                    method,
                    args,
                    options
                );
                break;
            default:
                break;
        }
    }.bind(this);
};

/**
 * get a module of methods for an app instance
 */
global.requireModule = function(app, name) {
    var methods = cmsModules[name];
    var target = {};
    if (!task || typeof task.send !== "function") {
        return null;
    }
    var loop = function (methodName) {
        Object.defineProperty(target, methodName, {
            configurable: true,
            enumerable: true,
            get: function moduleGetter() {
                return function () {
                    var args = [], len = arguments.length;
                    while (len--) args[len] = arguments[len];

                    return task.send(
                        "module",
                        {module: name, method: methodName},
                        args);
                }
            },
            set: function moduleSetter(value) {
                if (typeof value === 'function') {
                    return app.callTasks({
                        module: name,
                        method: methodName,
                        args: [value]
                    })
                }
            }
        });
    };
    for (var methodName in methods) loop(methodName);
    return target
}

//cms modules
const cmsModules = {};
/**
 * Register native modules information.
 * @param {object} newModules
 */
global.registerModules = function(newModules) {
    console.log("newModules:" + JSON.stringify(newModules));
    var obj = JSON.parse(newModules);
    for (name in obj) {
        console.log("name:" + name);
        if (!cmsModules[name]) {
            cmsModules[name] = {};
        }
        obj[name].forEach(method => {
            if (typeof method === 'string') {
                cmsModules[name][method] = true;
            }
            else {
                cmsModules[name][method.name] = method.args;
            }
        })
    }
}

global.callNativeModule = function(instanceId, module, method, args, options) {
    console.log("args:" + JSON.stringify(args))
    var argsContent = (args == null || args.length == 0) ? "" : JSON.stringify(args);
    return jsNative.callNativeModule(instanceId, module, method, argsContent, options);
}

const task = new Task(22);