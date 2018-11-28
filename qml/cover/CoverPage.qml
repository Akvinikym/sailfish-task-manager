import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import refresher.TaskManager 1.0

Cover {
    property var activeTasks: pageStack.currentPage.tasksWithTimerOn

    Label {
        id: nameLabel
        anchors.top: parent.top
        text: qsTr("Active Taks")
    }

    SilicaListView {
        id: mainView
        anchors { top: nameLabel.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }

        model: ListModel {
            id: coverListModel
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
                        Text {
                            color: "white"
                            text: model.name
                        }
                    }

                    Text {
                        id: trackedTimeText
                        anchors.right: parent.right
                        color: "white"
                        font.pointSize: 25
                        text: {
                            var milisec = model.trackedTime;
                            var seconds = parseInt((milisec/1000)%60),
                                    minutes = parseInt((milisec/(1000*60))%60),
                                    hours = parseInt((milisec/(1000*60*60))%24);
                            hours = (hours < 10) ? "0" + hours : hours;
                            minutes = (minutes < 10) ? "0" + minutes : minutes;
                            seconds = (seconds < 10) ? "0" + seconds : seconds;
                            return hours + ":" + minutes + ":" + seconds;
                        }
                    }
                }
            }
        }
    }

    Refresher {
        onSecondPassed: {
            coverListModel.clear();
            for (var i = 0; i < activeTasks.length; i++) {
                coverListModel.append(activeTasks[i]);
            }
        }
    }
}
