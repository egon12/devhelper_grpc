import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../usecase/call.dart';

class CallList extends GetView<CallListController> {
  const CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call List')),
      body: controller.rx.obx(
        (state) => ListView.builder(
          itemBuilder: (context, index) => CallViewItem(data: state?[index]),
          itemCount: state?.length ?? 0,
        ),
      ),
    );
  }
}

class CallViewItem extends StatelessWidget {
  CallViewObject? data;

  CallViewItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var d = data;
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

  @override
  void onInit() {
    super.onInit();
    var calls = Future.value([
      CallViewObject(
          package: "pkg", service: "Service", method: "Get", request: "{}"),
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
