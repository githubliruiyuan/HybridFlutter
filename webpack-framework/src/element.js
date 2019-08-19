function Element(moduleId, id) {
    this.id = id;
    this.moduleId = moduleId;
    this.attrib = {};

    //修改样式属性
    this.updateStyle = function (key, value) {
        if (key && value) {
            var content = typeof value === "string" ? value : JSON.stringify(value);
            jsNative.updateElementStyle(this.moduleId, this.id, key, content);
        }
    };
}
Element.prototype = {
    set id(val) {
        this._id = val;
        if (judgeIsNotNull(this.moduleId, this.id, val)) {
            jsNative.updateCSSAttr(this.moduleId, this.id, val, "id");
        }
    },
    get id() {
        return this._id;
    },

    set innerHTML(text) {
        this._innerHTML = text;
        if (this.moduleId && this.id && typeof(text) != "undefined") {
            jsNative.updateCSSAttr(this.moduleId, this.id, text, "innerHTML");
        }
    },
    get innerHTML() {
        return this._innerHTML;
    },

    set onclick(click) {
        this._onclick = click;
        this.attrib["onclick"] = "onClickTag";
        if (this.moduleId && this.id && this.attrib) {
            jsNative.updateCSSAttr(this.moduleId, this.id, JSON.stringify(this.attrib), "attrib");
        }
    },
    get onclick() {
        return this._onclick;
    },
}

global.Element = Element;