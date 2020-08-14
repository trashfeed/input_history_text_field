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
              /// - list
              InputHistoryTextField(
                historyKey: "01",
                listStyle: ListStyle.List,
              ),

              /// sample2
              /// - badge
              InputHistoryTextField(
                historyKey: "03",
                listStyle: ListStyle.Badge,
                showHistoryIcon: false,
                badgeColor: Colors.lightBlue,
                textColor: Colors.white,
                deleteIconColor: Colors.white,
              ),

              /// sampe3
              /// - customize
              InputHistoryTextField(
                historyKey: "02",
                minLines: 2,
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
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 3)),
                  ],
                ),
                historyIconTheme: IconTheme(
                  data: IconThemeData(color: Colors.red, size: 12),
                  child: Icon(Icons.add),
                ),
                deleteIconTheme: IconTheme(
                  data: IconThemeData(color: Colors.blue, size: 12),
                  child: Icon(Icons.remove_circle),
                ),
                listOffset: Offset(0, 5),
                listTextStyle: TextStyle(fontSize: 30),
                historyListItemLayoutBuilder: (controller, value, index) {
                  return InkWell(
                    onTap: () => controller.select(value.text),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                              margin: const EdgeInsets.only(left: 10.0),
                              padding: const EdgeInsets.only(left: 10.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    width: 5.0,
                                    color: index % 2 == 0
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    value.textToSingleLine,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    value.createdTimeLabel,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).disabledColor),
                                  ),
                                ],
                              )),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(context).disabledColor,
                          ),
                          onPressed: () {
                            controller.remove(value);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
