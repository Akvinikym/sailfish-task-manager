import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import "../db"

Page {
    id: mainPage

    property int todayTasksMode: 0
    property int dueTasksMode: 1
    property int urgencyTasksMode: 2
    property int completedTasksMode: 3
    property int currentMode: todayTasksMode

    readonly property int urgencyLow: 0
    property int urgencyMedium: 1
    property int urgencyHigh: 2

    Dao {
        id: dao
    }

    function refreshTasks() {
        listModel.clear();
        switch (currentMode) {
        case mainPage.todayTasksMode: {
           dao.getTasks(function(tasks) {
              for (var i = 0; i < tasks.length; i++) {
                  var task = tasks.item(i);
                  listModel.append(task);
              }
           });
        }
//                // TODO: Dao.getTodayTasks()
//                listModel.append({
//                    name: "Make projecttttttttttttt",
//                    description: "Make a QML project",
//                    tags: "studying",                       // TODO: must be a list
//                    urgency: 0,
//                    due: "28-11-2018 12:00:00",
//                    trackedTime: "01:52:03",
//                    isCompleted: false
//                });
//                listModel.append({
//                    name: "Make assignment",
//                    description: "Make a QML project",
//                    tags: "studying",
//                    urgency: 1,
//                    due: "27-11-2018 13:00:00",
//                    trackedTime: "02:43:03",
//                    isCompleted: false
//                });
                break;
            case mainPage.dueTasksMode: return "Tasks by due date";
            case mainPage.urgencyTasksMode: return "Tasks by urgency";
            case mainPage.completedTasksMode:
                // TODO: Dao.getCompletedTasks()
                listModel.append({
                                     name: "Cook dinner",
                                     description: "Make a QML project",
                                     tags: "cooking",
                                     urgency: 2,
                                     due: "29-11-2018 20:00:00",
                                     trackedTime: "00:12:03",
                                     isCompleted: true
                                 })
                break;
        }
    }

    SilicaListView {
        id: mainView
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: parent.height - 1.5 * buttons.height

        header: PageHeader {
            id: listHeader
            title:
                switch (mainPage.currentMode) {
                    case mainPage.todayTasksMode: return "Tasks for today";
                    case mainPage.dueTasksMode: return "Tasks by due date";
                    case mainPage.urgencyTasksMode: return "Tasks by urgency";
                    case mainPage.completedTasksMode: return "Completed tasks";
            }
        }

        model: ListModel {
            id: listModel
        }

        delegate: ListItem {
            width: ListView.view.width
            Label {
                id: listLabel
                anchors.fill: parent
                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    Text {
                        id: urgencyText
                        Layout.preferredHeight: 100
                        Layout.preferredWidth: parent.width * 0.1
                        color: "white"
                        font.pointSize: 50
                        text:
                            switch (model.urgency) {
                                case mainPage.urgencyLow: return "L";
                                case mainPage.urgencyMedium: return "M";
                                case mainPage.urgencyHigh: return "H";
                            }
                    }

                    ColumnLayout {
                        Layout.preferredHeight: 100
                        Layout.preferredWidth: dueDateText.width
                        Text {
                            color: "white"
                            text: model.name
                        }
                        Text {
                            id: dueDateText
                            color: "white"
                            text: "Due " + model.due
                        }
                    }


                    Text {
                        id: trackedTimeText
                        anchors.right: parent.right
                        color: "white"
                        font.pointSize: 50
                        text: model.trackedTime
                    }
                }
            }

            menu: ContextMenu {
                MenuItem {
                    text: "Show Task"
                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("TaskDialog.qml"))
                        dialog.name = model.name
                        dialog.description = model.description
                        dialog.tags = model.tags
                        dialog.urgency = model.urgency
                        dialog.due = Date.fromLocaleString(Qt.locale(), model.due, "dd-MM-yyyy hh:mm:ss")
                        dialog.accepted.connect(function() {
                            listModel.append({
                                                 name: dialog.name,
                                                 description: dialog.description,
                                                 tags: dialog.tags,
                                                 urgency: dialog.urgency,
                                                 due: dialog.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                                 trackedTime: model.trackedTime,
                                                 isCompleted: model.isCompleted
                                             });
                            listModel.remove(model);
                        })
                    }
                }
                MenuItem {
                    text: "Complete Task"
                    onClicked: listModel.remove(model)
                }

                MenuItem {
                    text: "Remove Task"
                    onClicked: listModel.remove(model.index)
                }
            }
        }

        ViewPlaceholder {
            enabled: mainView.count === 0
            text: "No items yet"
            hintText: "Pull down to add items"
        }

        PullDownMenu {
            MenuItem {
                text: "Add New Task"
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("TaskDialog.qml"))
                    dialog.accepted.connect(function() {
                        dao.insertTask({
                                           name: dialog.name,
                                           description: dialog.description,
                                           tags: dialog.tags,
                                           urgency: dialog.urgency,
                                           due: dialog.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                           trackedTime: "00:00:00",
                                           isCompleted: false
                                       });
                    });
                }
            }
            MenuItem {
                text: "Remove All Records"
                onClicked: {
                    listModel.clear()
                }
            }
        }

        Component.onCompleted: refreshTasks()
    }

    ButtonLayout {
        id: buttons
        anchors.bottom: parent.bottom
        width: parent.width

        Button {
            text: "today"
            onClicked: { currentMode = todayTasksMode; refreshTasks(); }
        }

        Button {
            text: "due sort"
            onClicked: { currentMode = dueTasksMode; refreshTasks(); }
        }

        Button {
            text: "urgency sort"
            onClicked: { currentMode = urgencyTasksMode; refreshTasks(); }
        }

        Button {
            text: "completed"
            onClicked: { currentMode = completedTasksMode; refreshTasks(); }
        }
    }
}
