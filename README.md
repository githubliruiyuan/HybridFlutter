# HybridFlutter
Flutter + V8/JsCore 开发小程序引擎

众所周知，小程序是由HTML标签来开发原生组件，那么首先需要将HTML做解析，这里我们将HTML通过node脚本解析成JSON字符串，再用Dart来解析JSON，映射对应的标签到flutter的组件。、

# 一、HTML部分
由于目前还没有将HTML的flex属性解析成flutter的样式，所有决定直接用flutter的组件名在HTML文件上开发

* 文件目录如下：

![文件结构](https://user-gold-cdn.xitu.io/2019/8/30/16ce13a3738de73d?w=360&h=97&f=png&s=4132)

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
                <raisedbutton id="raised-button" onclick="onItemClick" data-index="{{index}}">
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
```

# 二、渲染效果


![](https://user-gold-cdn.xitu.io/2019/8/30/16ce13c82d12943c?w=415&h=865&f=gif&s=2690414)


![](https://user-gold-cdn.xitu.io/2019/9/3/16cf718aecb4bf3f?w=415&h=865&f=gif&s=403181)


# 三、组件部分
直接使用flutter的组件

## 1、组件
### a、容器
- column
- row
- container
- singlechildscrollview
- ...

### b、基础内容
- text
- image
- ...
### c、表单组件
- 待完善


# 四、Api
模仿微信小程序的Api，cc对应是微信小程序的wx
## 1、界面
### a、交互
- cc.showToast
- cc.showLoading
- cc.hideToast
- cc.hideLoading
- ...

### b、导航栏
- cc.setNavigationBarTitle
- cc.setNavigationBarColor

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
# 六、实时调试


![](https://user-gold-cdn.xitu.io/2019/9/3/16cf7195023303b3?w=1547&h=885&f=gif&s=1961142)