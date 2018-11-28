import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    property var db;

    function initTasksDatabase() {
        db.transaction(function (tx) {
            tx.executeSql("DROP TABLE tasks");
            tx.executeSql("CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT NOT NULL,
                tags TEXT NOT NULL,
                urgency INTEGER NOT NULL,
                due TEXT NOT NULL,
                trackedTime INTEGER NOT NULL,
                forToday BOOLEAN,
                isTimerOn BOOLEAN,
                timerLastMeasure INT NOT NULL,
                notified BOOLEAN,
                isCompleted BOOLEAN
            );");
        });
    }

    function getTasks(callback) {
        var database = LocalStorage.openDatabaseSync("tasks", "1.0");
        database.readTransaction(function (tx) {
            var result = tx.executeSql("SELECT * FROM tasks;");
            var tasks = []
            for (var i = 0; i < result.rows.length; i++) {
                tasks.push(result.rows.item(i));
            }
            callback(tasks);
        });
    }
    function insertTask(task, callback) {
        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO tasks
                (name, description, tags, urgency, due, trackedTime, forToday, isTimerOn, timerLastMeasure, isCompleted, notified)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [task.name, task.description, task.tags, task.urgency, task.due,
                 task.trackedTime, task.forToday, task.isTimerOn, task.timerLastMeasure, task.isCompleted, task.notified]);
        });
        callback(task);
    }

    function removeTask(task, callback) {
        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM tasks WHERE name = ?", [task.name]);
        });
        callback();
    }

    function updateTask(task, callback) {
        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM tasks WHERE name = ?", [task.name]);
            insertTask(task, callback);
        });
    }

    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("tasks", "1.0"); initTasksDatabase();
    }
}
