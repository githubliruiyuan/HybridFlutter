/** ${code} */
Page({
    /**
    * 页面数据
    */
    data: {
        name: "demo"
    },
    
    /**
    * 页面加载时触发。一个页面只会调用一次，可以在 onLoad 的参数中获取打开当前页面路径中的参数。
    */
    onLoad(e) {
        console.log('name = ' + this.data.name);
    },

    /**
    * 页面卸载时触发。如cc.redirectTo或cc.navigateBack到其他页面时。
    */
    onUnload() {

    }
});