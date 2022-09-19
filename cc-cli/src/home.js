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
        cc.showLoading({});
        this.doRequest(true);
    },

    doRequest(isOnload) {
        const book = {
            title:"Python编程",
            image:"https://img1.doubanio.com/view/subject/s/public/s33716278.jpg",
            author:"[美]埃里克·马瑟斯（Eric Matthes）",
            publisher:"人民邮电出版社",
            subtitle:"从入门到实践（第2版）",
            summary:"本书是针对所有层次Python读者而作的Python入门书。全书分两部分：第一部分介绍用Python编程所必须了解的基本概念，包括Matplotlib等强大的Python库和工具，以及列表、字典、if语句、类、文件与异常、代码测试等内容；第二部分将理论付诸实践，讲解如何开发三个项目，包括简单的2D游戏、利用数据生成交互式的信息图以及创建和定制简单的Web应用，并帮助读者解决常见编程问题和困惑。第2版进行了全面修订，简化了Python安装流程，新增了f字符串、get()方法等内容，并且在项目中使用了Plotly库以及新版本的Django和Bootstrap，等等。",
            author_intro:"埃里克·马瑟斯（Eric Matthes）\n\n高中科学和数学老师，现居住在阿拉斯加，在当地讲授Python入门课程。他从5岁开始就一直在编写程序。",
            catalog:"第一部分 基础知识\n" +
            "第1章 起步　　2\n" +
            "1.1 搭建编程环境　　2\n" +
            "1.1.1 Python版本　　2\n" +
            "1.1.2 运行Python代码片段　　2\n" +
            "1.1.3 Sublime Text简介　　3\n" +
            "1.2 在不同操作系统中搭建Python编程环境　　3\n" +
            "1.2.1 在Windows系统中搭建Python编程环境　　4\n" +
            "1.2.2 在macOS系统中搭建Python编程环境　　5\n" +
            "1.2.3 在Linux 系统中搭建Python编程环境　　7\n" +
            "1.3 运行Hello World 程序　　8\n" +
            "1.3.1 配置Sublime Text以使用正确的Python版本　　8\n" +
            "1.3.2 运行程序hello_world.py　　8\n" +
            "1.4 解决安装问题　　9\n" +
            "1.5 从终端运行Python程序　　9\n" +
            "1.5.1 在Windows系统中从终端运行Python 程序　　10\n" +
            "1.5.2 在Linux和macOS系统中从终端运行Python程序　　10\n",
        };
        let that = this;
        that.setData({
            list: [
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
                book,
            ]
        });
        if (isOnload) {
            cc.hideLoading();
        } else {
            cc.stopPullDownRefresh();
        }
        // cc.request({
        //     url: 'http://47.107.46.220:10808/query', //'https://douban.uieee.com/v2/book/search?q=python', 
        //     data: {},
        //     header: {},
        //     method: 'get',
        //     success: function (response) {
        //         that.setData({
        //             list: response.body.books
        //         });
        //         cc.showToast({
        //             title: '加载成功'
        //         });
        //     },
        //     fail: function (error) {
        //         console.log('request error:' + JSON.stringify(error));
        //         cc.showToast({
        //             title: '加载失败'
        //         });
        //     },
        //     complete: function () {
        //         console.log('request complete');
        //         if (isOnload) {
        //             cc.hideLoading(); 
        //         } else {
        //             cc.stopPullDownRefresh();
        //         }
        //     } 
        // });
    },

    onItemClick(e) {
        var item = this.data.list[e.target.dataset.index];
        cc.navigateTo({
            url: "detail?item=" + JSON.stringify(item)
        });
    },

    onPullDownRefresh() {
        console.log("onPullDownRefresh");
        this.doRequest(false);
    },

    /**
    * 页面卸载时触发。如cc.redirectTo或cc.navigateBack到其他页面时。
    */
    onUnload() {

    }
});