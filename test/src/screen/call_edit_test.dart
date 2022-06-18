import 'package:devhelper_grpc/src/repository/server.dart';
import 'package:devhelper_grpc/src/repository/call.dart';
import 'package:devhelper_grpc/proto/descriptor.pb.dart';
import 'dart:ui';

import 'package:devhelper_grpc/src/screen/call_edit.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'package:devhelper_grpc/src/server/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';

void main() {
  testWidgets('call list ...', (tester) async {
    Get.lazyPut(() => CallEditController());
    await tester.pumpWidget(const CallEdit());
  });
}

class ControllerMock implements CallEditController {
  @override
  List<MethodDescriptorProto> allMethods;

  @override
  TextEditingController bodyCtrl;

  @override
  CallRepo callRepo;

  @override
  RxBool isLoadingMethodList;

  @override
  RxBool isLoadingServerList;

  @override
  RxBool isLoadingServices;

  @override
  MethodDescriptorProto? method;

  @override
  RxList<String> methods;

  @override
  DescriptorProto? reqProto;

  @override
  DescriptorProto? resProto;

  @override
  RxString selectedMethod;

  @override
  RxString selectedServer;

  @override
  RxString selectedService;

  @override
  Server server;

  @override
  RxString serverHost;

  @override
  RxString serverPort;

  @override
  ServerRepo serverRepo;

  @override
  RxBool serverUseTLS;

  @override
  RxList<Server> servers;

  @override
  RxList<String> services;

  @override
  RxString title;

  @override
  void $configureLifeCycle() {
    // TODO: implement $configureLifeCycle
  }

  @override
  Disposer addListener(GetStateUpdate listener) {
    // TODO: implement addListener
    throw UnimplementedError();
  }

  @override
  Disposer addListenerId(Object? key, GetStateUpdate listener) {
    // TODO: implement addListenerId
    throw UnimplementedError();
  }

  @override
  void addServer() {
    // TODO: implement addServer
  }

  @override
  void call() {
    // TODO: implement call
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void disposeId(Object id) {
    // TODO: implement disposeId
  }

  @override
  void generateBodyFrom(String methodName) {
    // TODO: implement generateBodyFrom
  }

  @override
  void generateBodyFromSelected() {
    // TODO: implement generateBodyFromSelected
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => throw UnimplementedError();

  @override
  // TODO: implement initialized
  bool get initialized => throw UnimplementedError();

  @override
  // TODO: implement isClosed
  bool get isClosed => throw UnimplementedError();

  @override
  // TODO: implement listeners
  int get listeners => throw UnimplementedError();

  @override
  void notifyChildrens() {
    // TODO: implement notifyChildrens
  }

  @override
  void onClose() {
    // TODO: implement onClose
  }

  @override
  // TODO: implement onDelete
  InternalFinalCallback<void> get onDelete => throw UnimplementedError();

  @override
  void onInit() {
    // TODO: implement onInit
  }

  @override
  void onReady() {
    // TODO: implement onReady
  }

  @override
  // TODO: implement onStart
  InternalFinalCallback<void> get onStart => throw UnimplementedError();

  @override
  void open(String id) {
    // TODO: implement open
  }

  @override
  void refresh() {
    // TODO: implement refresh
  }

  @override
  void refreshGroup(Object id) {
    // TODO: implement refreshGroup
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }

  @override
  void removeListenerId(Object id, VoidCallback listener) {
    // TODO: implement removeListenerId
  }

  @override
  void save() {
    // TODO: implement save
  }

  @override
  void selectServer(String serverChoosen) {
    // TODO: implement selectServer
  }

  @override
  void selectService(String? serviceChoosen) {
    // TODO: implement selectService
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    // TODO: implement update
  }

}
