import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart' hide Server;
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
      appBar: AppBar(title: const Text('Add new Call')),
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
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: controller.save,
                      child: const Text('Save'),
                    ),
                    OutlinedButton(
                        onPressed: controller.call, child: const Text('Call'))
                  ],
                )
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
      return controller.isLoadingServers.isTrue
          ? buildLoader(context, 'loading saved server ...')
          : buildDropDown(context);
    });
  }

  DropdownButtonFormField<String> buildDropDown(context) {
    return DropdownButtonFormField<String>(
      decoration: outlined(label: 'Server'),
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

  // TODO move this into one controller
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
    return Obx(() => controller.isLoadingServices.value
        ? buildLoader(context, 'loading services ...')
        : buildDropDown(context));
  }

  Widget buildDropDown(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: outlined(label: 'Service'),
      value: controller.selectedService.string,
      onChanged: controller.selectService,
      items: [emptyItem, ...controller.services.map(toItem)],
    );
  }
}

class MethodDropdownList extends GetView<CallEditController> {
  const MethodDropdownList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMethods.value) {
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
        controller.selectMethod(str.toString());
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
  final serverHost = ''.obs;
  final serverPort = ''.obs;
  final serverUseTLS = false.obs;

  final isLoadingServers = false.obs;
  final servers = List<Server>.empty().obs;
  final selectedServer = newServOpt.obs;

  final isLoadingServices = false.obs;
  final services = List<String>.empty().obs;
  final selectedService = ''.obs;

  final isLoadingMethods = false.obs;
  final methods = List<String>.empty().obs;
  final selectedMethod = ''.obs;

  final bodyCtrl = TextEditingController(text: '{}');

  List<MethodDescriptorProto> _allMethods = [];

  final ServerRepo _serverRepo = Get.find();

  final CallRepo _callRepo = Get.find();

  Server _server = Server('', 0);
  MethodDescriptorProto? _method;
  DescriptorProto? _reqProto;
  DescriptorProto? _resProto;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  void _start() async {
    isLoadingServers(true);
    try {
      var serversFromDB = await _serverRepo.all();
      servers.clear();
      servers.addAll(serversFromDB);
    } catch (e) {
      Get.dialog(buildDialog("Error", e.toString()));
    } finally {
      isLoadingServers(false);
    }
  }

  void addServer() async {
    var newServer = Server(
      serverHost.value,
      int.parse(serverPort.value),
      serverUseTLS.value,
    );

    await _serverRepo.save(newServer);
    _start();

    selectedServer.value = newServer.toString();

    serverHost.value = '';
    serverPort.value = '';
    serverUseTLS.value = false;
  }

  void selectServer(String serverChoosen) async {
    try {
      isLoadingServices(true);
      _server = servers.firstWhere((it) => it.toString() == serverChoosen);
      selectedServer.value = _server.toString();
      var allServices = await _server.reflection.services();
      selectedService('');
      selectedMethod('');
      services.clear();
      services.addAll(allServices);
    } catch (e) {
      Get.dialog(buildDialog("Error", e.toString()));
    } finally {
      isLoadingServices(false);
    }
  }

  void selectService(String? serviceChoosen) async {
    if (serviceChoosen == null) {
      methods.clear();
      return;
    }

    try {
      isLoadingMethods(true);
      _allMethods = await _server.reflection.methods(serviceChoosen);
      selectedService(serviceChoosen);
      selectedMethod(_allMethods[0].name);
      methods.clear();
      methods.addAll(_allMethods.map((i) => i.name));
      _generateBodyFromSelected();
    } catch (e) {
      Get.dialog(buildDialog("Error", e.toString()));
    } finally {
      isLoadingMethods(false);
    }
  }

  void selectMethod(String methodName) async {
    selectedMethod.value = methodName;
    _generateBodyFromSelected();
  }

  void _generateBodyFromSelected() async {
    _method = _allMethods.firstWhere((e) => e.name == selectedMethod.string);
    var reflection = _server.reflection;
    _reqProto = await reflection.message(_method!.inputType.substring(1));
    _resProto = await reflection.message(_method!.outputType.substring(1));

    // TODO throw error if cannot find req Proto
    var dm = DynamicMessage.fromDescriptor(_reqProto!, _getPackage());
    var body = dm.generateEditableJson();
    bodyCtrl.text = body;
  }

  void save() {
    // TODO throw Exception when reqProto is nil

    var methodName = _method?.name ?? '';

    var c = CallPersistent(
      name: '$selectedService/$methodName',
      host: _server.host,
      port: _server.port,
      pkg: selectedService.string,
      service: selectedService.string,
      method: methodName,
      reqProto: _reqProto ?? DescriptorProto(),
      resProto: _resProto ?? DescriptorProto(),
      req: bodyCtrl.text,
    );

    _callRepo.save(c);
    Get.back();
  }

  void call() async {
    // TODO think if method is empty
    var odm = DynamicMessage.fromDescriptor(_resProto!, _getPackage());

    final cm = ClientMethod(
      "/" + selectedService.string + "/" + (_method?.name ?? ''),
      (DynamicMessage dm) => dm.writeToBuffer(),
      (List<int> value) => odm.fromBuffer(value),
    );

    var dm = DynamicMessage.fromDescriptor(_reqProto!, '');
    dm.mergeFromProto3Json(jsonDecode(bodyCtrl.text));

    var call = _server.channel.createCall(cm, Stream.value(dm), CallOptions());

    var res = await call.response.first;
    Get.dialog(buildDialog("Response", res.toString()));
  }

  String _getPackage() {
    // TODO set the package name [DONE]
    // TODO move this logic into somewhere else
    var str = selectedService.string;
    var ind = str.lastIndexOf('.');
    var pkg = ind > -1 ? str.substring(0, ind) : '';
    return pkg;
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

InputDecoration outlined({String label = ''}) => InputDecoration(
      label: Text(label),
      border: const OutlineInputBorder(),
    );

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
