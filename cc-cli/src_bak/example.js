Page({
    /**
    * 页面数据
    */
    data: {
        list: [[['x1','x2'],['y1','y2'],['z1','z2']]],
        btnColor:'green',
        colors:['green','red','blue'],
        item2:'yyyy',
        width: 0.2,
        height: 0.2,
        name: "cms demo"     
    },
    onclick() { 
        let name = "cms"
        let width = this.data.width + 0.1;
        let height = this.data.height + 0.1;

        let random = Math.ceil(Math.random() * 3);
        console.log('random = ' + random);  

        let btnColor = this.data.colors[random];
        this.setData({name,width,height,btnColor});    

        let that = this;
        cc.request({  
            url:'https://www.easy-mock.com/mock/5ab46236e1c17b3b2cc55843/example/items', 
            data:{},  
            header:{},  
            method:'get', 
            success: function (response) {    
                console.log('request success:'+JSON.stringify(response));   
                that.setData({
                    list:response.body.payload
                }); 
            },
            fail: function (error) {  
                console.log('request error:'+JSON.stringify(error));  
            }, 
            complete: function () {
                console.log('request complete');       
            }
        });
    },
    /**
    * 页面加载时触发。一个页面只会调用一次，可以在 onLoad 的参数中获取打开当前页面路径中的参数。
    */
    onLoad(e) {
        console.log('ppcms name = ' + this.data.name);
    },

    /**
    * 页面卸载时触发。如cc.redirectTo或cc.navigateBack到其他页面时。
    */
    onUnload() {

    }
});