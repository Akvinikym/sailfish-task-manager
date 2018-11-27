import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    property var db;

    function initTasksDatabase() {
        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT NOT NULL,
                tags TEXT NOT NULL,
                urgency INTEGER NOT NULL,
                due TEXT NOT NULL,
                trackedTime TEXT NOT NULL,
                forToday BOOLEAN,
                isTimerOn BOOLEAN,
                timerStartedAt TEXT NOT NULL,
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
                (name, description, tags, urgency, due, trackedTime, forToday, isTimerOn, timerStartedAt, isCompleted)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [task.name, task.description, task.tags, task.urgency, task.due,
                 task.trackedTime, task.forToday, task.isTimerOn, task.timerStartedAt, task.isCompleted]);
        });
        callback(task);
    }

    function updateTask(task, callback) {
        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM tasks WHERE name = ?", [task.name]);
            insertTask(task, callback);
        });
    }

    function startTimer(taskname) {
        db.transaction(function (tx) {
            tx.executeSql("UPDATE tasks
                SET isTimerOn = true, timerStartedAt = ?
                WHERE name = ?", [Date.now(), taskname]);
        });
    }

    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("tasks", "1.0"); initTasksDatabase();
    }
}
