import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../dynamic_message/dynamic_message.dart';
import '../repository/call.dart';
import '../repository/server.dart';
import '../server/server.dart';
import '../call/call.dart';
import '../../proto/descriptor.pb.dart';

class CallEdit extends GetView<CallEditController> {
  const CallEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.title.string))),
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
                      label: Text('Body'),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    style: const TextStyle(fontFamily: 'Monospace'),
                    controller: controller.bodyCtrl,
                    //focusNode: controller.textFocus,
                  ),
                ),
                OutlinedButton(
                    onPressed: controller.save, child: const Text('Save'))
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
    return Obx(() {
      if (controller.isLoadingServerList.value) {
        return buildLoader(context, 'loading saved server ...');
      } else {
        return buildDropDown(context);
      }
    });
  }

  DropdownButtonFormField<String> buildDropDown(context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        label: Text('Server'),
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      value: controller.selectedServer.string,
      onChanged: (String? str) {
        if (str == newServOpt) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: buildModalBottomSheet,
          );
        } else {
          controller.selectServer(str.toString());
        }
      },
      items: [
        ...controller.servers.map(toItem),
        const DropdownMenuItem(value: newServOpt, child: Text('Add New')),
      ],
    );
  }

  Widget buildModalBottomSheet(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
    return Obx(() {
      if (controller.isLoadingServiceList.value) {
        return buildLoader(context, 'loading services ...');
      } else {
        return buildDropDown(context);
      }
    });
  }

  Widget buildDropDown(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        label: Text('Service'),
        border: OutlineInputBorder(),
      ),
      value: controller.selectedService.string,
      onChanged: (str) {
        controller.selectService(str.toString());
      },
      items: [
        emptyItem,
        ...controller.services.map(toItem),
      ],
    );
  }
}

class MethodDropdownList extends GetView<CallEditController> {
  const MethodDropdownList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMethodList.value) {
        return buildLoader(context, 'loading methods ...');
      } else {
        return buildDropDown(context);
      }
    });
  }

  Widget buildDropDown(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        label: Text('Method'),
        border: OutlineInputBorder(),
      ),
      value: controller.selectedMethod.string,
      onChanged: (str) {
        controller.generateBodyFrom(str.toString());
      },
      items: [emptyItem, ...controller.methods.map(toItem)],
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
  CallRepo callRepo = Get.find();

  var title = 'Add new Call'.obs;

  var serverHost = ''.obs;
  var serverPort = ''.obs;
  var serverUseTLS = false.obs;
  var isLoadingServerList = false.obs;
  var servers = List<Server>.empty().obs;
  var selectedServer = newServOpt.obs;
  var server = Server('', 0);

  var isLoadingServiceList = false.obs;
  var services = List<String>.empty().obs;
  var selectedService = ''.obs;

  var isLoadingMethodList = false.obs;
  var methods = List<String>.empty().obs;
  var selectedMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  void _start() async {
    isLoadingServerList(true);
    try {
      var serversFromDB = await serverRepo.all();
      servers.clear();
      servers.addAll(serversFromDB);
    } catch (e) {
      Get.dialog(buildDialog("Error", e.toString()));
    } finally {
      isLoadingServerList(false);
    }
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

  void selectServer(String serverChoosen) async {
    try {
      isLoadingServiceList(true);
      server = servers.firstWhere((it) => it.toString() == serverChoosen);
      selectedServer.value = server.toString();
      var allServices = await server.reflection.services();
      services.clear();
      services.addAll(allServices);
    } catch (e) {
      Get.dialog(buildDialog("Error", e.toString()));
    } finally {
      isLoadingServiceList(false);
    }
  }

  List<MethodDescriptorProto> allMethods = [];
  void selectService(String serviceChoosen) async {
    try {
      isLoadingMethodList(true);
      allMethods = await server.reflection.methods(serviceChoosen);
      selectedService(serviceChoosen);
      selectedMethod(allMethods[0].name);
      methods.clear();
      methods.addAll(allMethods.map((i) => i.name));
      generateBodyFromSelected();
    } catch (e) {
      Get.dialog(buildDialog("Error", e.toString()));
    } finally {
      isLoadingMethodList(false);
    }
  }

  TextEditingController bodyCtrl = TextEditingController(text: '{}');
  MethodDescriptorProto? method;
  DescriptorProto? reqProto;
  DescriptorProto? resProto;
  void generateBodyFrom(String methodName) async {
    method = allMethods.firstWhere((element) => element.name == methodName);
    reqProto = await server.reflection.message(method!.inputType.substring(1));
    resProto = await server.reflection.message(method!.outputType.substring(1));

    // TODO set the package name
    // TODO throw error if cannot find req Proto
    var dm = DynamicMessage.fromDescriptor(reqProto!, '');
    dm.setDefaultToAll();
    var body = jsonEncode(dm.toProto3Json());
    bodyCtrl.text = body;
  }

  void generateBodyFromSelected() async {
    method = allMethods
        .firstWhere((element) => element.name == selectedMethod.string);
    reqProto = await server.reflection.message(method!.inputType.substring(1));
    resProto = await server.reflection.message(method!.outputType.substring(1));

    // TODO set the package name
    // TODO throw error if cannot find req Proto
    var dm = DynamicMessage.fromDescriptor(reqProto!, '');
    dm.setDefaultToAll();
    var body = jsonEncode(dm.toProto3Json());
    bodyCtrl.text = body;
  }

  void save() {
    // TODO throw Exception when reqProto is nil

    var methodName = method?.name ?? '';

    var c = CallPersistent(
      name: '$selectedService/$methodName',
      host: server.host,
      port: server.port,
      pkg: selectedService.string,
      service: selectedService.string,
      method: methodName,
      reqProto: reqProto ?? DescriptorProto(),
      resProto: resProto ?? DescriptorProto(),
      req: bodyCtrl.text,
    );

    callRepo.save(c);
    Get.back();
  }
}

class CallEditBinding extends Bindings {
  @override
  void dependencies() {
    Database db = Get.find();
    Get.lazyPut(() => ServerRepo(db: db));
    Get.lazyPut(() => CallRepo(db: db));
    Get.lazyPut(() => CallEditController());
  }
}

var callEditGetPage = GetPage(
    name: '/call/edit',
    page: () => const CallEdit(),
    binding: CallEditBinding());

const emptyItem = DropdownMenuItem(child: Text(''), value: '', enabled: false);

const vertPad = EdgeInsets.symmetric(vertical: 8.0);

const newServOpt = '___add__new';

Widget buildLoader(BuildContext context, String loadingText) {
  return Shimmer.fromColors(
    baseColor: Theme.of(context).highlightColor,
    highlightColor: Colors.white,
    child: TextFormField(
      enabled: false,
      decoration: InputDecoration(
        label: Text(loadingText),
        border: const OutlineInputBorder(),
        fillColor: Colors.white,
      ),
    ),
  );
}

Widget buildDialog(String title, String content) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      TextButton(
        child: const Text("Close"),
        onPressed: () => Get.back(),
      ),
    ],
  );
}

DropdownMenuItem<String> toItem(Object? it) {
  return DropdownMenuItem(
    value: it.toString(),
    child: Text(
      it.toString(),
      overflow: TextOverflow.fade,
    ),
  );
}
