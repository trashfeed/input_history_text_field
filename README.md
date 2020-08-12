# input_history_text_field
A `input_history_text_field` widget is show type history to users  as they type.

# Overview

| Simple                                                                                                       | Customize                                                                                                    |
| ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| ![image](https://user-images.githubusercontent.com/885696/89993604-eced6080-dcc1-11ea-8dbb-e2e12029d3de.png) | ![image](https://user-images.githubusercontent.com/885696/89993579-e19a3500-dcc1-11ea-895f-e8eae5288017.png) |

## Getting Started

### Usage
The only key in the your application set to `historyKey`, supports like a `text_field`.

```dart
InputHistoryTextField(
    historyKey: "01",
),

```

a saved automatically as you type.( save up to `limit`, default to `5` )

![input_history_text_field-1](https://user-images.githubusercontent.com/885696/89772114-6fe4ae80-db3c-11ea-91ff-9613da735258.gif)

a input history is suggested.

![input_history_text_field-2](https://user-images.githubusercontent.com/885696/89772499-0f09a600-db3d-11ea-99a4-1439252dcbdb.gif)

input history can be deleted.

![input_history_text_field-3](https://user-images.githubusercontent.com/885696/89772615-4710e900-db3d-11ea-92e9-f58988cad645.gif)


## Example
### simple
All you need is a `historyKey`.
```
InputHistoryTextField(
    historyKey: "01",
),
```

### change icon
Can hide or change the icon.

```dart
InputHistoryTextField(
    historyKey: "01",
    showHistoryIcon: true,
    showDeleteIcon: true,
    historyIcon: Icons.add,
    deleteIcon: Icons.delete,
),
```

| &nbsp;                                                                                                       |
| ------------------------------------------------------------------------------------------------------------ |
| ![image](https://user-images.githubusercontent.com/885696/89994867-abf64b80-dcc3-11ea-9a92-e45f43264b3b.png) |

### gradually transmitted
`enableOpacityGradient` is input history list is gradually transmitted.

```dart
InputHistoryTextField(
    historyKey: "01",
    enableOpacityGradient: true,
),
```
| &nbsp;                                                                                                       |
| ------------------------------------------------------------------------------------------------------------ |
| ![image](https://user-images.githubusercontent.com/885696/89995053-f4156e00-dcc3-11ea-9bfa-ce9699a8bb2d.png) |


### lines decoration 
`listRowDecoration` is input history lines as a decoration.

```dart
InputHistoryTextField(
    historyKey: "01",
    listRowDecoration: BoxDecoration(
        border: Border(
        left: BorderSide(color: Colors.blue, width: 8),
        ),
    ),
),

```

| &nbsp;                                                                                                       |
| ------------------------------------------------------------------------------------------------------------ |
| ![image](https://user-images.githubusercontent.com/885696/89995391-5a01f580-dcc4-11ea-8d70-0c1955d28eca.png) |


### list decoration
`listDecoration` is input history list as a decoration.

```dart
InputHistoryTextField(
    historyKey: "01",
    listDecoration: BoxDecoration(
        color: Colors.cyan,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)),
        boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 8,
            blurRadius: 8,
            offset: Offset(0, 3)),
        ],
    ),
),

```

| &nbsp;                                                                                                       |
| ------------------------------------------------------------------------------------------------------------ |
| ![image](https://user-images.githubusercontent.com/885696/89996047-44d99680-dcc5-11ea-9902-841181c83906.png) |

#### list layout builder
If you want to customize everything, to use `historyListItemLayoutBuilder` or `inputHistoryController`.

```dart
final _inputHistoryController = InputHistoryController();
InputHistoryTextField(
    historyKey: "01",
    inputHistoryController: _inputHistoryController,
    historyListItemLayoutBuilder: (value, index) {
        return InkWell(
        onTap: () => _inputHistoryController.select(value.text),
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
                        DateTime.fromMillisecondsSinceEpoch(
                                value.createdTime)
                            .toUtc()
                            .toString(),
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
                _inputHistoryController.remove(value);
                },
            ),
            ],
        ),
    );}
)
```


| &nbsp;                                                                                                       |
| ------------------------------------------------------------------------------------------------------------ |
| ![image](https://user-images.githubusercontent.com/885696/89993579-e19a3500-dcc1-11ea-895f-e8eae5288017.png) |



### API
| name                         | ex                        |                        | note                                                                                                                 |
| ---------------------------- | ------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------- |
| historyKey                   | `key-01`                  | String                 | a only key in the your application,saved with this key.                                                              |
| limit                        | `5`                       | int                    | max limit of input history                                                                                           |
| hasFocusExpand               | `true`                    | bool                   | show input history of edit text focused                                                                              |
| showHistoryIcon              | `true`                    | bool                   | icon of input history at left positioned                                                                             |
| showDeleteIcon               | `true`                    | bool                   | icon of delete at right positioned                                                                                   |
| enableHistory                | `true`                    | bool                   | enabled/disabled of input history                                                                                    |
| enableOpacityGradient        | `true`                    | bool                   | make the input history list gradually transparent                                                                    |
| historyIcon                  | `Icons.add`               | IconData               | `IconData` for history icon.                                                                                         |
| historyIconTheme             | `IconTheme`               | IconTheme              | `IconTheme` for history icon.                                                                                        |
| deleteIcon                   | `Icons.delete`            | IconData               | `IconData` for delete icon.                                                                                          |
| deleteIconTheme              | `IconTheme`               | IconTheme              | `IconTheme` for delete icon.                                                                                         |
| listOffset                   | `Offset(0, 5)`            | Offset                 | set a position for list.                                                                                             |
| listTextStyle                | `TextStyle(fontSize: 30)` | TextStyle              | sets a text style for list.                                                                                          |
| listRowDecoration            | `BoxDecoration`           | Decoration             | a row of input history for decoration                                                                                |
| listDecoration               | `BoxDecoration`           | Decoration             | a list of input history for decoration                                                                               |
| historyListItemLayoutBuilder | `Widget`                  | Widget                 | a customize full layout. It is necessary to use `InputHistoryController` to select and delete the input history list |
| InputHistoryController       | `InputHistoryController`  | InputHistoryController | Select or delete the input history list                                                                              |
