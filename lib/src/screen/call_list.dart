import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../usecase/call.dart';

class CallList extends GetView<CallListController> {
  const CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: SliverAppBar(title: const Text('Call List')),
      body: controller.rx.obx(
        (state) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160.0,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                title: TextFormField(),
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
