# input_history_text_field
A `input_history_text_field` widget is show type history to users  as they type.

## Usage
- The only key in the your application set to `historyKey`, supports like a `text_field`,
    ```
    InputHistoryTextField(
        historyKey: "01",
    ),

    ```
- the input history is automatically saved.( save up to `limit`, default to `5` )

    ![input_history_text_field-1](https://user-images.githubusercontent.com/885696/89772114-6fe4ae80-db3c-11ea-91ff-9613da735258.gif)

- You will be suggested as you type.

    ![input_history_text_field-2](https://user-images.githubusercontent.com/885696/89772499-0f09a600-db3d-11ea-99a4-1439252dcbdb.gif)

- Unnecessary history can be deleted

    ![input_history_text_field-3](https://user-images.githubusercontent.com/885696/89772615-4710e900-db3d-11ea-92e9-f58988cad645.gif)



## Overview

![input_history_text_field](https://user-images.githubusercontent.com/885696/89764480-6ef95000-db2f-11ea-8ad8-f7540f85021d.gif)


## Attributes
| name                  | ex              |            | note                                                    |
| --------------------- | --------------- | ---------- | ------------------------------------------------------- |
| historyKey            | `key-01`        | String     | a only key in the your application,saved with this key. |
| limit                 | `5`             | int        | max limit of input history                              |
| hasFocusExpand        | `true`          | bool       | show input history of edit text focused                 |
| showHistoryIcon       | `true`          | bool       | icon of input history at left positioned                |
| showDeleteIcon        | `true`          | bool       | icon of delete at right positioned                      |
| enableHistory         | `true`          | bool       | enabled/disabled of input history                       |
| enableOpacityGradient | `true`          | bool       | make the input history list gradually transparent       |
| historyIcon           | `Icons.add`     | IconData   | a IconData for history icon.                            |
| deleteIcon            | `Icons.delete`  | IconData   | a IconData for delete icon.                             |
| listRowDecoration     | `BoxDecoration` | Decoration | a row of input history for decoration                   |
| listDecoration        | `BoxDecoration` | Decoration | a list of input history for decoration                  |

