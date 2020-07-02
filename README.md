# HybridFlutter
Flutter + V8/JsCore 动态化实践

DSL（HTML+CSS+JS）

由HTML标签来开发原生组件，那么首先需要将HTML做解析，这里我们将HTML通过node脚本解析成JSON字符串，再用Dart来解析JSON，映射对应的标签到flutter的组件。

# 一、HTML部分
为了高效解析，直接用flutter的组件名在HTML文件上开发

* 文件目录如下：

![](https://user-gold-cdn.xitu.io/2019/9/20/16d4de1ed3be0c3a?w=322&h=109&f=png&s=5750)

- config
``` json
{
  "navigationBarTitleText": "",
  "backgroundColor": "#eeeeee",
  "enablePullDownRefresh": true  
}
```
- HTML
```
<!DOCTYPE html>
<html lang="en" html-identify="CC">

<head>
    <meta charset="UTF-8" />
    <style type="text/css" media="screen">
        @import "home.css";
    </style>
</head>

<body>
    <singlechildscrollview>  
        <column>   
            <container id="btn-container" cc:for="{{list}}"> 
                <raisedbutton id="raised-button" bindtap="onItemClick" data-index="{{index}}">
                    <row>
                        <container id="image-container">
                            <image src="{{item.image}}" />  
                        </container>
                        <expanded>  
                            <column id="column-text">
                                <text id="text-title">{{item.title}}</text>
                                <text id="text-publisher">{{item.publisher}}</text> 
                                <text id="text-summary">{{item.summary.substring(0, 20) + '...'}}</text>    
                            </column>
                        </expanded>
                    </row>
                </raisedbutton>
            </container>
        </column>
    </singlechildscrollview>
</body>

</html>
```

- css样式
```css
/* home */
.btn-container{
    margin-top:10;
    margin-left: 10; 
    margin-right: 10;
}

.raised-button {
    color: white;
}

.image-container {
    width: 100px; 
    height:100px; 
    padding: 5;
}

.column-text {
    cross-axis-alignment: start;
}

.text-title {
    font-size: 14px;
    color: black;
}

.text-publisher {
    font-size: 12px;
    color: gray;
}

.text-summary {
    font-size: 12px;
    color: gray;
}

```


- js交互
```js
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
        let that = this;
        cc.request({
            url: 'https://douban.uieee.com/v2/book/search?q=python', 
            data: {},
            header: {},
            method: 'get',
            success: function (response) {
                that.setData({
                    list: response.body.books
                });
                cc.showToast({
                    title: '加载成功'
                });
            },
            fail: function (error) {
                console.log('request error:' + JSON.stringify(error));
                cc.showToast({
                    title: '加载失败'
                });
            },
            complete: function () {
                console.log('request complete');
                if (isOnload) {
                    cc.hideLoading(); 
                } else {
                    cc.stopPullDownRefresh();
                }
            } 
        });
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
```

# 二、渲染效果

![](https://user-gold-cdn.xitu.io/2019/8/30/16ce13c82d12943c?w=415&h=865&f=gif&s=2690414)

# 三、组件部分
直接使用flutter的组件

## 1、组件
### a、布局类组件
- 线性布局（row和column）
- 弹性布局（flex）
- 流式布局（wrap、flow）
- 层叠布局（stack、positioned）
- 对齐与相对定位（align）

### b、基础组件
- text
- image
- raisedbutton
- circularprogressindicator

### c、容器类组件
- 填充（padding）
- 尺寸限制类容器（constrainedbox等）
- 装饰容器（decoratedbox）
- 变换（transform）
- container容器
- 剪裁（clip）

### d、可滚动组件
- singlechildscrollview
- listview
- gridview

# 四、Api
模仿微信小程序的Api，cc对应是微信小程序的wx
## 1、界面
### a、交互
- cc.showToast
- cc.showLoading
- cc.hideToast
- cc.hideLoading
- ...

### b、背景 
- cc.setBackgroundColor

### c、导航栏
- cc.setNavigationBarTitle
- cc.setNavigationBarColor

### e、下拉刷新 
- cc.startPullDownRefresh
- cc.stopPullDownRefresh

## 2、网络
### a、cc.request
以上HTML中的例子

# 五、框架
## 1、语法参考
### a、数据绑定
> HTML 中的动态数据均来自对应 Page 的 data。
> 
> 双大括号 {{}} 将变量包起来

```
<text>{{message}}</text>

Page({
  data: {
    message: "hello world"
  }
})

```

### b、列表渲染

- cc:for
> 在组件上使用 cc:for 控制属性绑定一个数组，即可使用数组中各项的数据重复渲染该组件。
>
> 默认数组的当前项的下标变量名默认为 index，数组当前项的变量名默认为 item

```
<column>
    <text cc:for="{{array}}">
      {{index + '-' + item.name}}
    </text>
</column>  

Page({
  data: {
    array: [{
      name: 'first',
    }, {
      name: 'second'
    }]
  }
})
```

> 使用 cc:for-item 可以指定数组当前元素的变量名，
>
> 使用 cc:for-index 可以指定数组当前下标的变量名：

```
<column>
    <text cc:for="{{array}}" cc:for-index="idx" cc:for-item="itemName">
      {{idx + ' - ' + itemName.name}}
    </text>
</column>
```

- cc:for 嵌套
```
<column>
    <row cc:for="{{array1}}" cc:for-item="i">
        <text cc:for="{{array2}}" cc:for-item="j">
            {{'i * j = ' + i * j}}
        </text>
    </row>
</column>
Page({
  data: {
    array1: [1, 2, 3, 4, 5, 6, 7, 8, 9],
    array2: [1, 2, 3, 4, 5, 6, 7, 8, 9]
  }
})

```
# 六、API 演示
![](https://user-gold-cdn.xitu.io/2019/9/3/16cf718aecb4bf3f?w=415&h=865&f=gif&s=403181)

# 七、实时调试


![](https://user-gold-cdn.xitu.io/2019/9/3/16cf7195023303b3?w=1547&h=885&f=gif&s=1961142)


# 八、代码运行

- 1、目前只实现了Android版，需要使用Android Studio导入项目，路径如下图所示；
- 2、将main.dart中的_pageCode值改为“home”，如下图所示。

![](https://user-gold-cdn.xitu.io/2019/10/11/16db8b9afc9f6eac?w=1212&h=738&f=png&s=143747)

- 3、由于代码直接run出来的debug包里面lib下armabi-v7a没有生成Flutter的so包，所以不能直接在真机上面直接测试
![](https://user-gold-cdn.xitu.io/2019/11/14/16e67f2065786d11?w=752&h=722&f=png&s=69674)

- 4、真机上面运行需要通过build->Flutter->Build APK方式得到app-release.apk包进行安装
![](https://user-gold-cdn.xitu.io/2019/11/14/16e67f1dfc895eea?w=857&h=173&f=png&s=45686)
![](https://user-gold-cdn.xitu.io/2019/11/14/16e67f1f3d73bad4?w=950&h=663&f=png&s=74616)

- 系列文章：

[《使用Flutter + V8开发小程序引擎（一）》](https://juejin.im/post/5d68c2046fb9a06aca3833a2)

[《使用Flutter + V8开发小程序引擎（二）》](https://juejin.im/post/5d68f1b36fb9a06ad0058541)

[《使用Flutter + V8开发小程序引擎（三）》](https://juejin.im/post/5d70af6ee51d456206115a6f)
