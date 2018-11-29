import QtQuick 2.4
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import "../db"
import refresher.TaskManager 1.0
import Nemo.Notifications 1.0
import org.nemomobile.dbus 2.0

Page {
    id: mainPage

    property var tasksWithTimerOn: []
    
    property int todayTasksMode: 0
    property int completedTasksMode: 1
    property int allTasksMode: 2
    
    readonly property int urgencyLow: 0
    readonly property int urgencyMedium: 1
    readonly property int urgencyHigh: 2

    property var listModels: [todayListModel, completedListModel, allListModel]
    ListModel {
        id: completedListModel
    }
    ListModel {
        id: todayListModel
    }
    ListModel {
        id: allListModel
    }
    
    Dao {
        id: dao
    }


    Item {
        id: alarmControl

        function setAlarm() {
            alarm.call('newAlarm', undefined);
        }

        DBusInterface {
            id: alarm
            service: 'com.jolla.clock'
            path: '/'
            iface: 'com.jolla.clock'
        }
    }
    
    function showTasks() {
        dao.getTasks(function(allTasks) {
            listModels[0].clear();
            listModels[0].append(allTasks.filter(function (task) { return task.forToday && !task.isCompleted; }));

            listModels[1].clear();
            listModels[1].append(allTasks.filter(function (task) { return task.isCompleted}));

            listModels[2].clear();
            listModels[2].append(allTasks.filter(function (task) { return !task.isCompleted}));
        });
    }
    
    SlideshowView {
        id: slideshowView
        anchors { left: parent.left; right: parent.right }

        model: 3
        delegate: SilicaListView {
            id: listView
            width: mainPage.width
            height: mainPage.height

            header: PageHeader {
                id: listHeader
                title:
                    switch (index) {
                    case mainPage.todayTasksMode: return "Tasks for today";
                    case mainPage.completedTasksMode: return "Completed tasks";
                    case mainPage.allTasksMode: return "All tasks"
                    }
            }

            model: listModels[index]

            delegate: ListItem {
                width: ListView.view.width
                Label {
                    id: listLabel
                    anchors.fill: parent

                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin

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
                                           isCompleted: model.isCompleted,
                                           notified: model.notified
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
                                               isCompleted: model.isCompleted,
                                               notified: model.notified
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
                                                   isCompleted: model.isCompleted,
                                                   notified: model.notified
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
                                                   isCompleted: model.isCompleted,
                                                   notified: model.notified
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
                                               isCompleted: true,
                                               notified: model.notified
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

            PullDownMenu {
                quickSelect: true
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
                                               isCompleted: false,
                                               notified: false
                                           },
                                           function(task) {
                                               if (task.urgency == urgencyHigh) {
                                                   alarmControl.setAlarm();
                                               }
                                               showTasks();
                                           });
                        });
                    }
                }
            }

            PushUpMenu {
                MenuItem {
                    id: urgency
                    text: "urgency"

                    onClicked: {
                        sortModel(function (t1, t2) {
                            if (t1.urgency < t2.urgency) {
                                return 1;
                            } else if (t1.urgency > t2.urgency) {
                                return -1;
                            }
                            return 0;
                        }, index);
                    }
                }

                MenuItem {
                    id: due
                    text: "due"

                    onClicked: {
                        sortModel(function (t1, t2) {
                            var dateT1 = Date.fromLocaleString(Qt.locale(), t1.due, "dd-MM-yyyy hh:mm:ss");
                            var dateT2 = Date.fromLocaleString(Qt.locale(), t2.due, "dd-MM-yyyy hh:mm:ss")
                            if (dateT1 > dateT2) {
                                return 1;
                            } else if (dateT1 < dateT2) {
                                return -1;
                            }
                            return 0;
                        }, index);
                    }
                }
            }

            Component.onCompleted: showTasks()
        }
    }

    function sortModel(comparator, index) {
        var tasks = []
        for (var i = 0; i < listModels[index].count; i++) {
            tasks.push(JSON.parse(JSON.stringify(listModels[index].get(i))));
        }

        var sorted = tasks.sort(comparator);
        for (var i = 0; i < listModels[index].count; i++) {
            listModels[index].set(i, sorted[i]);
        }
    }

    Notification {
        id: notification

        onClicked: console.log("Clicked")
    }

    function checkDueTime() {
        dao.getTasks(function (tasks) {
            for (var i = 0; i < tasks.length; i++) {
                var t = tasks[i]
                var dueTime = Date.fromLocaleString(Qt.locale(), t.due, "dd-MM-yyyy hh:mm:ss");
                var day = 86400000
                if (!t.notified && !t.isCompleted && dueTime - Date.now() < day) {
                    notification.summary = t.name + " is due soon!";
                    notification.body = "deadline: " + t.due;
                    notification.publish();
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
                                       isCompleted: t.isCompleted,
                                       notified: true
                                   }, function (tasks) {});
                }
            }
        });
    }

    Refresher {
        onSecondPassed: {
            checkDueTime();
            tasksWithTimerOn = [];
            for (var i = 0; i < listModels[0].count; i++) {
                var t = listModels[0].get(i);

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
                                       isCompleted: t.isCompleted,
                                       notified: t.notified
                                   },
                                   function (task) {});
                    tasksWithTimerOn.push(t);
                }
            }
            for (var i = 0; i < listModels[1].count; i++) {
                var t = listModels[1].get(i);

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
                                       isCompleted: t.isCompleted,
                                       notified: t.notified
                                   },
                                   function (task) {});
                    tasksWithTimerOn.push(t);
                }
            }
            for (var i = 0; i < listModels[2].count; i++) {
                var t = listModels[2].get(i);

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
                                       isCompleted: t.isCompleted,
                                       notified: t.notified
                                   },
                                   function (task) {});
                    tasksWithTimerOn.push(t);
                }
            }
        }
    }
}
