import 'dart:convert';

import 'package:devhelper_grpc/proto/descriptor.pb.dart';
import 'package:devhelper_grpc/src/dynamic_message/dynamic_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../repository/server.dart';
import '../server/server.dart';

class CallEdit extends GetView<CallEditController> {
  const CallEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.title.string))),
      //bottomSheet: AddServerBottomSheet(),
      body: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Get Service from reflection from server:",
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                const Padding(padding: vertPad, child: ServerDropdownList()),
                const Padding(padding: vertPad, child: ServiceDropdownList()),
                const Padding(padding: vertPad, child: MethodDropdownList()),
                Padding(
                  padding: vertPad,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 100, // some bad hardcode
                    style: const TextStyle(fontFamily: 'Monospace'),
                    controller: controller.bodyCtrl,
                    //focusNode: controller.textFocus,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServerDropdownList extends GetView<CallEditController> {
  const ServerDropdownList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownButtonFormField(
        decoration: const InputDecoration(
          label: Text('Server'),
          border: OutlineInputBorder(),
        ),
        value: controller.selectedServer.string,
        onChanged: (str) {
          if (str == '___add_new___') {
            showModalBottomSheet(
              context: context,
              builder: buildModalBottomSheet,
            );
          } else {
            controller.showServiceFrom(str.toString());
          }
        },
        items: [
          ...controller.servers.map(
            (it) => DropdownMenuItem(
              value: it.toString(),
              child: Text(it.toString()),
            ),
          ),
          const DropdownMenuItem(
            value: '___add_new___',
            child: Text('Add New'),
          ),
        ],
      ),
    );
  }

  Widget buildModalBottomSheet(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        width: double.infinity,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: ServerEdit(),
        ),
      ),
    );
  }
}

class ServiceDropdownList extends GetView<CallEditController> {
  const ServiceDropdownList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(
          label: Text('Service'),
          border: OutlineInputBorder(),
        ),
        value: controller.selectedService.string,
        onChanged: (str) {
          controller.showMethodsFrom(str.toString());
        },
        items: [
          emptyItem,
          ...controller.services.map(toItem),
        ],
      ),
    );
  }
}

class MethodDropdownList extends GetView<CallEditController> {
  const MethodDropdownList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownButtonFormField(
        isExpanded: true,
        decoration: const InputDecoration(
          label: Text('Method'),
          border: OutlineInputBorder(),
        ),
        value: controller.selectedMethod.string,
        onChanged: (str) {
          controller.generateBodyFrom(str.toString());
        },
        items: [
          emptyItem,
          ...controller.methods.map(toItem),
        ],
      ),
    );
  }
}

class ServerEdit extends GetView<CallEditController> {
  const ServerEdit({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Form(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Add/Edit Server',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'host',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                initialValue: controller.serverHost.value,
                onChanged: (val) => controller.serverHost.value = val,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'port',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                initialValue: controller.serverPort.string,
                onChanged: (val) => controller.serverPort.value = val,
              ),
            ),
            SwitchListTile(
              title: const Text('Use TLS'),
              value: controller.serverUseTLS.value,
              onChanged: (val) => controller.serverUseTLS.value = val,
            ),
            OutlinedButton(
                onPressed: () {
                  controller.addServer();
                  navigator?.pop();
                },
                child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

class CallEditController extends GetxController {
  ServerRepo serverRepo = Get.find();

  var title = 'Add new Call'.obs;

  var addNewServerOptions = '___add_new___';
  var serverHost = ''.obs;
  var serverPort = ''.obs;
  var serverUseTLS = false.obs;

  var servers = List<Server>.empty().obs;
  var selectedServer = '___add_new___'.obs;
  var server = Server('', 0);

  var services = List<String>.empty().obs;
  var selectedService = ''.obs;

  var methods = List<String>.empty().obs;
  var selectedMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  void _start() async {
    var serversFromDB = await serverRepo.all();
    servers.clear();
    servers.addAll(serversFromDB);
  }

  void addServer() async {
    var newServer = Server(
      serverHost.value,
      int.parse(serverPort.value),
      serverUseTLS.value,
    );

    await serverRepo.save(newServer);
    _start();

    selectedServer.value = newServer.toString();

    serverHost.value = '';
    serverPort.value = '';
    serverUseTLS.value = false;
  }

  void open(String id) {}

  void save() {}

  void showServiceFrom(String serverChoosen) async {
    server = servers.firstWhere((it) => it.toString() == serverChoosen);
    var allServices = await server.reflection.services();
    services.clear();
    services.addAll(allServices);
  }

  List<MethodDescriptorProto> allMethods = [];
  void showMethodsFrom(String serviceChoosen) async {
    allMethods = await server.reflection.methods(serviceChoosen);
    methods.clear();
    methods.addAll(allMethods.map((i) => i.name));
  }

  TextEditingController bodyCtrl = TextEditingController();
  void generateBodyFrom(String methodName) async {
    var method = allMethods.firstWhere((element) => element.name == methodName);
    var inputType =
        await server.reflection.message(method.inputType.substring(1));

    // TODO set the package name
    var dm = DynamicMessage.fromDescriptor(inputType, '');
    var body = jsonEncode(dm.toProto3Json());
    bodyCtrl.text = body;
  }
}

class CallEditBinding extends Bindings {
  @override
  void dependencies() {
    Database db = Get.find();
    Get.lazyPut(() => ServerRepo(db: db));
    Get.lazyPut(() => CallEditController());
  }
}

var callEditGetPage = GetPage(
    name: '/call/edit',
    page: () => const CallEdit(),
    binding: CallEditBinding());

const emptyItem = DropdownMenuItem(child: Text(''), value: '');

const vertPad = EdgeInsets.symmetric(vertical: 8.0);

DropdownMenuItem<String> toItem(Object? it) {
  return DropdownMenuItem(
    value: it.toString(),
    child: Text(
      it.toString(),
      overflow: TextOverflow.fade,
    ),
  );
}
