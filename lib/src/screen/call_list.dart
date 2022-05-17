import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../usecase/call.dart';

class CallList extends GetView<CallListController> {
  const CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: SliverAppBar(title: const Text('Call List')),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.black,
        backgroundColor: Colors.grey,
        buttonBackgroundColor: Colors.blueGrey,
        items: const [
          Icon(Icons.settings, size: 30),
          Icon(Icons.add, size: 30),
          Icon(Icons.menu_open, size: 30),
        ],
        index: 1, //optional, default as 0
        letIndexChange: (_) => false,
        onTap: (int i) => print('click index=$i'),
      ),
      body: controller.rx.obx(
        (state) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160.0,
              floating: true,
              snap: true,
              pinned: true,
              leading: Image.asset("images/app_logo_512.png"),
              actions: [
                PopupMenuButton(
                    itemBuilder: (context) => [
                          const PopupMenuItem(child: Text("Change URL")),
                          const PopupMenuItem(child: Text("Use Proto")),
                        ])
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  controller.title,
                  maxLines: 1,
                ),
                background: const FlutterLogo(),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => CallViewItem(data: state?[index]),
                childCount: state?.length ?? 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CallViewItem extends StatelessWidget {
  final CallViewObject? data;

  const CallViewItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = data;

    if (d == null) {
      return const ListTile(
        title: Text("empty"),
      );
    }

    return ListTile(
        leading: const Icon(Icons.bookmark),
        title: Text(d.package + "." + d.service + "/" + d.method),
        subtitle: Text(d.request),
        trailing: IconButton(
          icon: const Icon(Icons.send_outlined),
          onPressed: () {},
        ));
  }
}

class CallListController extends GetxController {
  var rx = List<CallViewObject>.empty().reactive;

  var title = "".obs();

  var server = TextEditingController(text: "Hello");

  @override
  void onInit() {
    super.onInit();
    var calls = Future.value([
      CallViewObject(
          package: "pkg", service: "Service", method: "Get1", request: "{1}"),
      CallViewObject(
          package: "pkg", service: "Service", method: "Get2", request: "{2}"),
      CallViewObject(
          package: "pkg", service: "Service", method: "Get3", request: "{3}"),
      CallViewObject(
          package: "pkg", service: "Service", method: "Get4", request: "{}"),
      CallViewObject(
          package: "pkg", service: "Service", method: "Get4", request: "{}"),
      CallViewObject(
          package: "pkg", service: "Service", method: "Get4", request: "{}"),
      CallViewObject(
          package: "pkg", service: "Service", method: "Get4", request: "{}"),
      CallViewObject(
          package: "pkg", service: "Service", method: "Get4", request: "{}"),
      CallViewObject(
          package: "pkg",
          service: "Service",
          method: "Set",
          request: '{"key":"mykey", "value": "myvalue"}'),
    ]);
    rx.append(() => () => calls);
    title = "myserver.service.aws-main-ap-souteast-1.consul:50051";
  }
  //var rx = List<String>.from().reactive;
}

class CallViewObject {
  String package;
  String service;
  String method;

  String request;

  CallViewObject(
      {required this.package,
      required this.service,
      required this.method,
      required this.request});
}
