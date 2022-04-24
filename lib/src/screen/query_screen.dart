import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

import '../usecase/call.dart';

/*
class QueryController {
  TextEditingController textController = TextEditingController();

  ClientChannel? cz;

  onInit() {
    textController.addListener(() {});
  }

  sendRequest() async {
    final callText = textController.text;
    final pos = textController.selection.start;

    final callExecutor = getCallExecutor(pos, callText);
    final res = callExecutor.execute();

    showResponse(res.toJSON());
  }

  getCallExecutor(int pos, CallBlocks callBlocks) {
    final callBlock = callBlocks.at(pos);
    final executor = callBlock.createExecutor(cz);
    return executor;
  }

  showResponse(String jsonResponse) {}
}

class QueryScreen extends StatefulWidget {
  const QueryScreen({Key? key}) : super(key: key);

  @override
  State<QueryScreen> createState() => _QueryScreen();
}

class _QueryScreen extends State<QueryScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


*/