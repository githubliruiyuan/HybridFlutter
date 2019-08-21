/** home */
Page({
    /**
    * 页面数据
    */
    data: {
        list: [],
    },

    /**
    * 页面加载时触发。一个页面只会调用一次，可以在 onLoad 的参数中获取打开当前页面路径中的参数。
    */
    onLoad(e) {
        cc.setNavigationBarTitle({
            title: 'Python系列丛书'
        });

        cc.showLoading({
            message: '正在玩命加载...'
        });
        let that = this;
        cc.request({
            url: 'https://www.easy-mock.com/mock/5ab46236e1c17b3b2cc55843/example/books',
            data: {},
            header: {},
            method: 'get',
            success: function (response) {
                that.setData({
                    list: response.body.books
                });
            },
            fail: function (error) {
                console.log('request error:' + JSON.stringify(error));
            },
            complete: function () {
                console.log('request complete');
                cc.hideLoading();
            } 
        });
    },

    onItemClick(e) {
        var item = this.data.list[e.target.dataset.index];
        cc.navigateTo({ 
            url: "detail?item=" + JSON.stringify(item)
        });
    },   

    /**
    * 页面卸载时触发。如cc.redirectTo或cc.navigateBack到其他页面时。
    */
    onUnload() {

    }
});