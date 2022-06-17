import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/repository/call.dart';
import 'src/repository/db.dart';
import 'src/screen/call_list.dart';
import 'src/screen/call_edit.dart';

void main() async {
  var db = await getDB();
  Get.put(db);

  Get.lazyPut(() => CallRepo(db: db));
  Get.lazyPut(() => CallListController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DH GRPC',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      home: const CallList(),
      getPages: [
        callEditGetPage,
      ],
    );
  }
}
