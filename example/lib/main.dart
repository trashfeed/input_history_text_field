import 'package:flutter/material.dart';
import 'package:input_history_text_field/input_history_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Sampe"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(50),
            child: Column(
              children: <Widget>[
                /// sample1
                InputHistoryTextField(
                  historyKey: "01",
                ),

                /// sampe2
                InputHistoryTextField(
                  historyKey: "02",
                  minLines: 6,
                  maxLines: 10,
                  limit: 3,
                  enableHistory: true,
                  hasFocusExpand: true,
                  showHistoryIcon: true,
                  showDeleteIcon: true,
                  historyIcon: Icons.add,
                  deleteIcon: Icons.delete,
                  enableOpacityGradient: false,
                  listRowDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.red, width: 3),
                    ),
                  ),
                  listDecoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 6,
                        // offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
