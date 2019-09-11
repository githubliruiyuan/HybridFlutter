/**
 * 观察者，用于观察data对象属性变化
 * @param data
 * @constructor
 */
function Observer(data) {
    this.data = data;
    this.observe(data);
}

Observer.prototype = {
    /**
     * 将data的属性变成可响应对象，为了监听变化回调
     * @param data
     */
    observe: function (data) {
        if (!data || data === undefined || typeof (data) !== "object") {
            return;
        }
        for (const key in data) {
            let value = data[key];
            if (value === undefined) {
                continue;
            }
            // console.log("key = " + key + " value = " + value);
            this.defineReactive(data, key, value);
            if (Array.isArray(value) || typeof(value) === "object") {
                this.observe(value);
            }
        }
    },

    defineReactive: function (data, key, val) {
        const property = Object.getOwnPropertyDescriptor(data, key);
        if (property && property.configurable === false) {
            return
        }
        const getter = property && property.get;
        const setter = property && property.set;
        if ((!getter || setter) && arguments.length === 2) {
            val = data[key];
        }

        let that = this;

        const dep = new DependCollector();
        Object.defineProperty(data, key, {
            enumerable: true,
            configurable: true,
            get: function reactiveGetter() {
                const value = getter ? getter.call(data) : val;
                if (DependCollector.targetWatcher) {
                    dep.depend();
                }
                return value;
            },
            set: function reactiveSetter(newVal) {
                const value = getter ? getter.call(data) : val;
                if (newVal === value || (newVal !== newVal && value !== value)) {
                    return;
                }
                if (setter) {
                    setter.call(data, newVal);
                } else {
                    val = newVal;
                }
                // 新值如果是object或数组的话，也要进行监听
                that.observe(newVal);
                dep.notify(data);
            }
        });
    },
};

/**
 * 依赖收集器，收集订阅的容器，用于增减观察者队列中的观察者，并发布更新通知
 * @constructor
 */
let uid = 0;
function DependCollector() {
    this.id = uid++;
    //订阅者队列
    this.subs = {};
}
//表示当前订阅者，全局唯一的Watcher，因为在同一时间只能有一个全局的Watcher被计算
DependCollector.targetWatcher = null;
DependCollector.prototype = {

    addSub: function (sub) {
        // console.log("sub key = " + sub.key());
        this.subs[sub.key()] = sub;
    },

    removeSub: function (sub) {
        delete this.subs[sub.key()];
    },

    removeSubByKey: function (key) {
        delete this.subs[key];
    },

    depend: function () {
        if (DependCollector.targetWatcher) {
            DependCollector.targetWatcher.addDep(this)
        }
    },

    /**
     * 通知所有订阅者，同时把当前Dep持有的所有订阅者的映射数组（id-表达式）添加到组装者中，等待组装
     */
    notify: function (data) {
        let subs = this.subs;
        for (const _k in subs) {
            let sub = subs[_k];
            sub.value = global.getExpValue(data, sub.script);
            getAssemblerSingle().addPackagingObject(sub.format());
            sub.update();
        }
    }
};

/**
 * 订阅者，用于响应观察者的变化
 * @constructor
 */
function Watcher(id, type, prefix, script, callBack) {
    this.id = id;
    this.type = type;
    this.prefix = prefix;
    this.script = script;
    this.value = {};
    this.callBack = callBack;
    this.elementId = [];
    this.depIds = [];
    this.get();
}
Watcher.prototype = {

    update: function () {
        //callBack可选，收到通知后会调用callBack回调到初始化Watcher的地方
        if (this.callBack) {
            this.callBack.call(this.id, this.elementId, this.script);
        }
    },

    addDep: function (dep) {
        // console.log("dep = " + dep);
        if (!this.depIds.hasOwnProperty(dep.id)) {
            dep.addSub(this);
            this.depIds[dep.id] = dep;
        }
        if (!this.elementId.hasOwnProperty(this.id)) {
            this.elementId.push(this.id);
        }
    },

    removeDep: function () {
        this.depIds.forEach((it) => {
            // console.log("remove key = " + this.key());
            it.removeSubByKey(this.key());
        });
    },

    get: function () {
        Observer.currentScript = this.script;
        DependCollector.targetWatcher = this;
    },

    stopCollectMapping: function () {
        DependCollector.targetWatcher = null;
        Observer.currentScript = null;
    },

    format: function () {
        let obj = {};
        obj.id = this.id;
        obj.type = this.type;
        obj.key = this.prefix;
        obj.value = this.value;
        return obj;
    },

    key: function () {
        return this.id + '-' + this.type + '-' + this.script;
    }
};

/**
 * 组装者，用于合并组装 id-属性 映射的结果，回传给原生做表达式计算和局部刷新
 * 因为表达式计算是各自独立的，所以 id-属性 映射散乱在各个Watcher中，需要在Dep层收集起来，在组装者中打平多余的层级
 * @constructor
 */
function Assembler() {
    this.packagingArray = [];
}
Assembler.prototype = {
    addPackagingObject: function (item) {
        this.packagingArray.push(item);
    },

    getNeedUpdateMapping: function () {
        let result = this.packing();
        this.packagingArray = [];
        return result;
    },

    /**
     * 组装映射关系
     * @returns [] 组装结果
     */
    packing: function () {
        console.log("组装映射结果:" + JSON.stringify(this.packagingArray));
        return this.packagingArray;
    }
};
/**
 * 获取组装者单例instance方法，全局只有一个组装者
 */
let getAssemblerSingle = (function () {
    let instance;
    return function () {
        return instance || (instance = new Assembler())
    }
})();

global.Observer = Observer;
global.Watcher = Watcher;
global.getAssemblerSingle = getAssemblerSingle;

