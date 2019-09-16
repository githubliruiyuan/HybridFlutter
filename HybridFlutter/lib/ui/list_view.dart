import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';

import 'base_widget.dart';
import 'basic.dart';

class ListViewStateless extends BaseWidget {

  ScrollController _scrollController;

  ListViewStateless(BaseWidget parent, String pageId,
      MethodChannel methodChannel, Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.data = ValueNotifier(Data(component.properties));

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollChangeListener);
  }

  void _scrollChangeListener() {
//    print("offset : ${_scrollController.offset}");
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        builder: (BuildContext context, Data data, Widget child) {
          return ListView(
            key: UniqueKey(),
            scrollDirection: MAxis.parse(data.map["scrollDirection"],
                defaultValue: Axis.vertical),
            reverse: MBool.parse(data.map["reverse"], defaultValue: false),
            controller: _scrollController,
//            primary: mxj2d(bo, jsonMap["primary"]),
//            physics: mxj2d(bo, jsonMap["physics"]),
            shrinkWrap:
                MBool.parse(data.map["shrinkWrap"], defaultValue: false),
            padding: MPadding.parse(data.map),
//            itemExtent: mxj2d(bo, jsonMap["itemExtent"])?.toDouble(),
            addAutomaticKeepAlives: MBool.parse(
                data.map["addAutomaticKeepAlives"],
                defaultValue: true),
            addRepaintBoundaries: MBool.parse(data.map["addRepaintBoundaries"],
                defaultValue: true),
            addSemanticIndexes:
                MBool.parse(data.map["addSemanticIndexes"], defaultValue: true),
//            cacheExtent: mxj2d(bo, jsonMap["cacheExtent"])?.toDouble(),
            children: data.children,
//            semanticChildCount: mxj2d(bo, jsonMap["semanticChildCount"]),
          );
        },
        valueListenable: this.data);
  }
}
