/** detail */
Page({
    /**
    * 页面数据
    */
    data: {
        detail: {},
        catalogShort: "",
        showLong: false,
        btnText: "查看更多",
    },

    /**
    * 页面加载时触发。一个页面只会调用一次，可以在 onLoad 的参数中获取打开当前页面路径中的参数。
    */
    onLoad(e) {
        var detail = JSON.parse(e.item);
        cc.setNavigationBarTitle({
            title: detail.title
        });
        var catalogShort = detail.catalog;
        if (catalogShort.length > 50) {
            catalogShort = catalogShort.substring(0, 50) + "...";
        }
        this.setData({
            detail: detail,
            catalogShort: catalogShort
        });
    },

    onMoreClick(e) {
        var showLong = !this.data.showLong;
        var catalogShort = this.data.detail.catalog;
        var btnText = "收起更多";
        if (!showLong) {
            if (catalogShort.length > 50) {
                catalogShort = catalogShort.substring(0, 50) + "...";
            }
            btnText = "查看更多";
        }
        this.setData({
            showLong: showLong,
            catalogShort: catalogShort,
            btnText: btnText
        });
    },

    /**
    * 页面卸载时触发。如cc.redirectTo或cc.navigateBack到其他页面时。
    */
    onUnload() {

    }
});