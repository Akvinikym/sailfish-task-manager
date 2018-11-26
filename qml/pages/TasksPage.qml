import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1

Page {
    id: mainPage

    property int todayTasksMode: 0
    property int dueTasksMode: 1
    property int urgencyTasksMode: 2
    property int completedTasksMode: 3
    property int currentMode: todayTasksMode

    readonly property int urgencyLow: 0
    readonly property int urgencyMedium: 1
    readonly property int urgencyHigh: 2

    property var allTasks: [{name: "Make projecttttttttttttt",
                             description: "Make a QML project",
                             tags: "studying",                       // TODO: must be a list
                             urgency: 0,
                             due: "28-11-2018 12:00:00",
                             trackedTime: "01:52:03",
                             forToday: true,
                             isTimerOn: false,
                             isCompleted: false},
                            {name: "Make assignment",
                             description: "Make a QML project",
                             tags: "studying",
                             urgency: 1,
                             due: "27-11-2018 11:00:00",
                             trackedTime: "02:43:03",
                             forToday: true,
                             isTimerOn: false,
                             isCompleted: false},
                            {name: "Cook dinner",
                             description: "Prepare macorones",
                             tags: "cooking",
                             urgency: 2,
                             due: "29-11-2018 20:00:00",
                             forToday: false,
                             trackedTime: "00:12:03",
                             isCompleted: true
                            }]

    function showTasks() {
        listModel.clear();
        // TODO: Dao.getAllTasks() instead of using property allTasks
        switch (currentMode) {
            case mainPage.todayTasksMode:
                var todayTasks = allTasks.filter(function (task) { return task.forToday && !task.isCompleted});
                listModel.append(todayTasks);
                break;
            case mainPage.dueTasksMode:
                var sortedByDue = allTasks
                  .filter(function (task) { return !task.isCompleted})
                  .sort(function (t1, t2) {
                    var dateT1 = Date.fromLocaleString(Qt.locale(), t1.due, "dd-MM-yyyy hh:mm:ss");
                    var dateT2 = Date.fromLocaleString(Qt.locale(), t2.due, "dd-MM-yyyy hh:mm:ss")
                    if (dateT1 > dateT2) {
                        return 1;
                    } else if (dateT1 < dateT2) {
                        return -1;
                    }
                    return 0;
                });
                listModel.append(sortedByDue);
                break;
            case mainPage.urgencyTasksMode:
                var sortedByUrgency = allTasks
                  .filter(function (task) { return !task.isCompleted})
                  .sort(function (t1, t2) {
                    if (t1.urgency < t2.urgency) {
                        return 1;
                    } else if (t1.urgency > t2.urgency) {
                        return -1;
                    }
                    return 0;
                });
                listModel.append(sortedByUrgency);
                break;
            case mainPage.completedTasksMode:
                var completedTasks = allTasks.filter(function (task) { return task.isCompleted});
                listModel.append(completedTasks);
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
                                         isTimerOn: model.isTimerOn,
                                         isCompleted: model.isCompleted
                                     });
                    listModel.remove(model);
                })
            }

            menu: ContextMenu {
                MenuItem {
                    text: "Start Timer"
                    onClicked: {

                    }
                }
                MenuItem {
                    text: "Complete Task"
                    onClicked: listModel.remove(model) // Dao.completeTask()
                }

                MenuItem {
                    text: "Remove Task"
                    onClicked: listModel.remove(model.index) // Dao.removeTask()
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
                        // TODO: Dao.createNewTask(...)
                        listModel.append({
                                             name: dialog.name,
                                             description: dialog.description,
                                             tags: dialog.tags,
                                             urgency: dialog.urgency,
                                             due: dialog.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                             trackedTime: "00:00:00",
                                             isTimerOn: false,
                                             isCompleted: false
                                         });
                    })
                }
            }
            MenuItem {
                text: "Remove All Records"
                onClicked: {
                    listModel.clear()
                }
            }
        }

        Component.onCompleted: showTasks()
    }

    ButtonLayout {
        id: buttons
        anchors {bottom: parent.bottom; bottomMargin: 20}
        width: parent.width

        Button {
            text: "today"
            onClicked: { currentMode = todayTasksMode; showTasks(); }
        }

        Button {
            text: "due sort"
            onClicked: { currentMode = dueTasksMode; showTasks(); }
        }

        Button {
            text: "urgency sort"
            onClicked: { currentMode = urgencyTasksMode; showTasks(); }
        }

        Button {
            text: "completed"
            onClicked: { currentMode = completedTasksMode; showTasks(); }
        }
    }
}
