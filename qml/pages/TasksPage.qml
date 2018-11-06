import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1

Page {
    id: mainPage

    property int todayTasksMode: 0
    property int dueTasksMode: 1
    property int urgencyTasksMode: 2
    property int currentMode: todayTasksMode

    readonly property int urgencyLow: 0
    property int urgencyMedium: 1
    property int urgencyHigh: 2

    SilicaListView {
        id: mainView
        anchors.fill: parent

        header: PageHeader { title:
                switch (mainPage.currentMode) {
                    case mainPage.todayTasksMode: return "Tasks for today";
                    case mainPage.dueTasksMode: return "Tasks by due date";
                    case mainPage.urgencyTasksMode: return "Tasks by urgency";
            }
        }
        model: ListModel {
            id: listModel

            ListElement {
                name: "Make project"
                description: "Make a QML project"
                tags: "studying"
                urgency: 0
                due: "28-11-18 12:00:00"
                trackedTime: "01:52:03"
            }
            ListElement {
                name: "Cook dinner"
                description: "Make a QML project"
                tags: "cooking"
                urgency: 2
                due: "29-11-18 20:00:00"
                trackedTime: "00:12:03"
            }
            ListElement {
                name: "Make assignment"
                description: "Make a QML project"
                tags: "studying"
                urgency: 1
                due: "27-11-18 13:00:00"
                trackedTime: "02:43:03"
            }
        }

        delegate: ListItem {
            width: ListView.view.width
            Label {
                anchors.fill: parent
                RowLayout {
                    spacing: 20
                    Rectangle {
                        // urgency
                        id: urgencyRect
                        Layout.preferredHeight: 100
                        Layout.preferredWidth: parent.width * 0.2
                        color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            font.pointSize: 50
                            text:
                                switch (model.urgency) {
                                    case mainPage.urgencyLow: return "L";
                                    case mainPage.urgencyMedium: return "M";
                                    case mainPage.urgencyHigh: return "H";
                                }
                        }
                    }
                    Rectangle {
                        // task's body
                        id: taskRect
                        Layout.preferredHeight: 100
                        Layout.preferredWidth: dueDateText.width
                        color: "transparent"
                        ColumnLayout {
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
                    }
                    Rectangle {
                        // time tracked
                        id: timeRect
                        Layout.preferredHeight: 100
                        Layout.preferredWidth: parent.width - urgencyRect.width - taskRect.width
                        color: "transparent"
                        Text {
                            color: "white"
                            font.pointSize: 50
                            text: model.trackedTime
                        }
                    }
                }
            }

            menu: ContextMenu {
                MenuItem {
                    text: "Edit Record"
//                    onClicked: {
//                        var dialog = pageStack.push("AddEntryDialog.qml",
//                                                    {"name": "Tell us some information"})
//                        dialog.firstName = model.firstName
//                        dialog.lastName = model.lastName
//                        dialog.birthDate = model.birthDate
//                        dialog.bio = model.bio
//                        dialog.accepted.connect(function() {
//                            listModel[model.index] = {
//                                "firstName": dialog.firstName,
//                                "lastName": dialog.lastName,
//                                "birthDate": dialog.birthDate,
//                                "bio": dialog.bio
//                            }
//                            dialog.close()
//                        })
//                    }
                }
                MenuItem {
                    text: "Remove Record"
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
                        listModel.append({
                                             name: dialog.name,
                                             description: dialog.description,
                                             tags: dialog.tags,
                                             urgency: dialog.urgency,
                                             due: dialog.due,
                                             trackedTime: "00:00:00"
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
    }
}
