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
                isCompleted BOOLEAN
            );");
        });
    }

    function getTasks(callback) {
        var database = LocalStorage.openDatabaseSync("tasks", "1.0");
        database.readTransaction(function (tx) {
            var result = tx.executeSql("SELECT * FROM tasks;");
            callback(result.rows);
        });
    }
    //function retrieveBooks(callback) {...}
    function insertTask(task) {
        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO tasks (name, descripton, tags, urgency, due, trackedTime)
                VALUES (?, ?, ?, ?, ?, ?)",
                [task.name, task.description, task.tags, task.urgency, task.due, task.trackedTime]);
        });
    }
    //function updateBook(id, author, title) {...}
    //function deleteBook(id) {...}
    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("tasks", "1.0"); initTasksDatabase();
    }
}
