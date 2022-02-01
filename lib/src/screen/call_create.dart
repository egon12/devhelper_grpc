import 'package:flutter/material.dart';

class CreateCallScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateCallScreenState();
  }
}

class CreateCallScreenState extends State<CreateCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          child: Column(
            children: [
              TextFormField(), // Maybe it will need, something
            ],
          ),
        ),
      ),
    );
  }
}
