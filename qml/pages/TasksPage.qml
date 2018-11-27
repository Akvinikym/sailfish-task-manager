import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import "../db"
import refresher.TaskManager 1.0

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
    
    Dao {
        id: dao
    }
    
    function showTasks() {
        listModel.clear();
        dao.getTasks(function(allTasks) {

            // show tasks
            switch (currentMode) {
            case mainPage.todayTasksMode:
                var todayTasks = allTasks
                    .filter(function (task) { return task.forToday && !task.isCompleted; });
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

        });
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
            
            onClicked: {
                var dialog = pageStack.push(Qt.resolvedUrl("TaskDialog.qml"))
                dialog.name = model.name
                dialog.description = model.description
                dialog.tags = model.tags
                dialog.urgency = model.urgency
                dialog.due = Date.fromLocaleString(Qt.locale(), model.due, "dd-MM-yyyy hh:mm:ss")
                dialog.accepted.connect(function() {
                    dao.updateTask({
                                       name: dialog.name,
                                       description: dialog.description,
                                       tags: dialog.tags,
                                       urgency: dialog.urgency,
                                       due: dialog.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                       trackedTime: model.trackedTime,
                                       forToday: model.forToday,
                                       isTimerOn: model.isTimerOn,
                                       timerLastMeasure: model.timerLastMeasure,
                                       isCompleted: model.isCompleted
                                   },
                                   function (task) {
                                        showTasks();
                                   });
                })
            }
            
            menu: ContextMenu {
                MenuItem {
                    text: model.isTimerOn ? "Stop Timer" : "Start Timer"
                    onClicked: {
                        dao.updateTask({
                                           name: model.name,
                                           description: model.description,
                                           tags: model.tags,
                                           urgency: model.urgency,
                                           due: model.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                           trackedTime: model.trackedTime,
                                           forToday: false,
                                           isTimerOn: !model.isTimerOn,
                                           timerLastMeasure: Date.now(),
                                           isCompleted: model.isCompleted
                                       },
                                       function (task) {
                                            showTasks();
                                       });
                    }
                }
                MenuItem {
                    text: model.forToday ? "Remove from Today Tasks" : "Set for Today"
                    onClicked: {
                        if (model.forToday) {
                            dao.updateTask({
                                               name: model.name,
                                               description: model.description,
                                               tags: model.tags,
                                               urgency: model.urgency,
                                               due: model.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                               trackedTime: model.trackedTime,
                                               forToday: false,
                                               isTimerOn: model.isTimerOn,
                                               timerLastMeasure: model.timerLastMeasure,
                                               isCompleted: model.isCompleted
                                           },
                                           function (task) {
                                                showTasks();
                                           });
                        } else {
                            dao.updateTask({
                                               name: model.name,
                                               description: model.description,
                                               tags: model.tags,
                                               urgency: model.urgency,
                                               due: model.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                               trackedTime: model.trackedTime,
                                               forToday: true,
                                               isTimerOn: model.isTimerOn,
                                               timerLastMeasure: model.timerLastMeasure,
                                               isCompleted: model.isCompleted
                                           },
                                           function (task) {
                                                showTasks();
                                           });
                        }
                    }
                }

                MenuItem {
                    text: "Complete Task"
                    onClicked:
                        dao.updateTask({
                                           name: model.name,
                                           description: model.description,
                                           tags: model.tags,
                                           urgency: model.urgency,
                                           due: model.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                           trackedTime: model.trackedTime,
                                           forToday: false,
                                           isTimerOn: false,
                                           timerLastMeasure: model.timerLastMeasure,
                                           isCompleted: true
                                       },
                                       function (task) {
                                            showTasks();
                                       });
                }
                MenuItem {
                    text: "Remove Task"
                    onClicked:
                        dao.removeTask(model,
                                       function (task) {
                                            showTasks();
                                       });
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
                                           trackedTime: 0,
                                           forToday: false,
                                           isTimerOn: false,
                                           timerLastMeasure: Date.now(),
                                           isCompleted: false
                                       },
                                       function(task) {
                                           showTasks();
                                       });
                    });
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

    Refresher {
        onSecondPassed: {
            for (var i = 0; i < listModel.count; i++) {
                var t = listModel.get(i);
                if (t.isTimerOn) {
                    var measure = t.timerLastMeasure;
                    t.trackedTime += Date.now() - measure;
                    t.timerLastMeasure = Date.now();

                    dao.updateTask({
                                       name: t.name,
                                       description: t.description,
                                       tags: t.tags,
                                       urgency: t.urgency,
                                       due: t.due.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm:ss"),
                                       trackedTime: t.trackedTime,
                                       forToday: t.forToday,
                                       isTimerOn: t.isTimerOn,
                                       timerLastMeasure: t.timerLastMeasure,
                                       isCompleted: t.isCompleted
                                   },
                                   function (task) {});
                }
            }
        }
    }
}
