import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/util/event_util.dart';

import 'base_widget.dart';
import 'basic.dart';

class ListViewStateless extends BaseWidget {
  ListViewStateless(BaseWidget parent, String pageId,
      MethodChannel methodChannel, Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.data = ValueNotifier(Data(component.properties));
  }

  void _scrollToUpper() {
    var upper = component.events["bindscrolltoupper"];
    if (null != upper) {
      onScrollLimitEvent(methodChannel, pageId, component.id, upper);
    }
  }

  void _scrollToLower() {
    var lower = component.events["bindscrolltolower"];
    if (null != lower) {
      onScrollLimitEvent(methodChannel, pageId, component.id, lower);
    }
  }

  void _scroll(double pixels) {
    var bindScroll = component.events["bindscroll"];
    if (null != bindScroll) {
      onScrollEvent(methodChannel, pageId, component.id, bindScroll, pixels);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: ObjectKey(component),
      child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
//            print("runtimeType: ${notification.runtimeType}");
            if (notification is ScrollEndNotification) {
              if (notification.metrics.pixels ==
                  notification.metrics.minScrollExtent) {
                _scrollToUpper();
              } else if (notification.metrics.pixels ==
                  notification.metrics.maxScrollExtent) {
                _scrollToLower();
              }
              _scroll(notification.metrics.pixels);
            }
            return true; // 返回false可见滚动条
          },
          child: ValueListenableBuilder(
              builder: (BuildContext context, Data data, Widget child) {
                return ListView(
                    key: UniqueKey(),
                    scrollDirection: MAxis.parse(data.map["scrollDirection"],
                        defaultValue: Axis.vertical),
                    reverse:
                        MBool.parse(data.map["reverse"], defaultValue: false),
//              controller: _scrollController,
                    primary: MBool.parse(data.map["primary"]),
//                  physics: data.map["physics"],
                    shrinkWrap: MBool.parse(data.map["shrinkWrap"],
                        defaultValue: false),
                    padding: MPadding.parse(data.map),
                    itemExtent: MDouble.parse(data.map["itemExtent"]),
                    addAutomaticKeepAlives: MBool.parse(
                        data.map["addAutomaticKeepAlives"],
                        defaultValue: true),
                    addRepaintBoundaries: MBool.parse(
                        data.map["addRepaintBoundaries"],
                        defaultValue: true),
                    addSemanticIndexes: MBool.parse(
                        data.map["addSemanticIndexes"],
                        defaultValue: true),
                    cacheExtent: MDouble.parse(data.map["cacheExtent"]),
                    children: data.children,
                    semanticChildCount:
                        MInt.parse(data.map["semanticChildCount"]));
              },
              valueListenable: this.data)),
    );
  }
}
