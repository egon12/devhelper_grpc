import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../call/call.dart';
import '../repository/call.dart';

class CallList extends GetView<CallListController> {
  const CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: SliverAppBar(title: const Text('Call List')),
      bottomNavigationBar: CurvedNavigationBar(
          color: Colors.black,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.blueGrey,
          items: const [
            Icon(Icons.settings, size: 30),
            Icon(Icons.add, size: 30),
            Icon(Icons.menu_open, size: 30),
          ],
          index: 1, //optional, default as 0
          letIndexChange: (_) => true,
          onTap: (int i) {
            if (i == 1) {
              controller.newCall();
            }
          }),
      body: controller.rx.obx(
        (state) => CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xff275379),
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
        title: Text(d.pkg + "." + d.service + "/" + d.method),
        subtitle: Text(d.request),
        trailing: IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {},
        ));
  }
}

class CallListController extends GetxController {
  var rx = List<CallViewObject>.empty().reactive;

  var title = "".obs();

  var server = TextEditingController(text: "Hello");

  CallRepo callRepo = Get.find();

  @override
  void onInit() {
    super.onInit();
    load();
    title = "myserver.service.aws-main-ap-souteast-1.consul:50051";
  }
  //var rx = List<String>.from().reactive;

  void load() async {
    rx.append(() => callRepo.allViewObject);
  }

  void newCall() async {
    await Get.toNamed("/call/edit");
    load();
  }
}
