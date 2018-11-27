import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    anchors.fill: parent

    property string name
    property string description
    property variant tags
    property int urgency
    property date due

    Column {
        width: parent.width

        DialogHeader {
            title: "Creating the task"
            acceptText: "Save"
            cancelText: "Cancel"
        }

        TextField {
            id: nameField
            width: parent.width

            text: name
            validator: RegExpValidator { regExp: /^[a-z ,.'-]{1,24}$/i }
            placeholderText: "Go jogging..."
            label: "Task name"

            EnterKey.onClicked: descriptionField.focus = true
        }
        TextField {
            id: descriptionField
            width: parent.width

            text: description
            validator: RegExpValidator { regExp: /^[a-z ,.'-]+$/i }
            placeholderText: "Park running..."
            label: "Description"

            EnterKey.onClicked: tagsField.focus = true
        }
        TextField {
            id: tagsField
            width: parent.width

            text: tags
            validator: RegExpValidator { regExp: /^[a-z ,.'-]+$/i }
            placeholderText: "health, sport..."
            label: "Tags, splitted by comma"

            EnterKey.onClicked: urgencyField.focus = true
        }
        Slider {
            id: urgencyField
            width: parent.width

            minimumValue: 0
            maximumValue: 2
            value: urgency
            handleVisible: true
            label: "Urgency, from 0 (lowest) to 2 (highest)"
            stepSize: 1
        }
        ValueButton {
            id: dueFieldDate
            property date dueDate: {
                var theDate = new Date();
                theDate.setDate(due.getDate());
                theDate.setMonth(due.getMonth());
                theDate.setFullYear(due.getFullYear());
                return theDate;
            }

            property bool dueDateIsSet: dueDate !== null

            label: "Due date"
            value: dueDate.toDateString()

            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog")
                dialog.accepted.connect(function() {
                    dueDate = dialog.date
                    dueDateIsSet = true
                })
            }
        }
        ValueButton {
            id: dueFieldTime
            property date dueTime: {
                var theTime = new Date();
                theTime.setHours(due.getHours());
                theTime.setMinutes(due.getMinutes());
                theTime.setSeconds(due.getSeconds());
                return theTime;
            }

            property bool dueTimeIsSet: dueTime !== null

            label: "Due time"
            value: dueTime.toTimeString()

            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog")
                dialog.accepted.connect(function() {
                    dueTime = dialog.time
                    dueTimeIsSet = true
                })
            }
        }
    }

    canAccept: !nameField.errorHighlight &&
               !descriptionField.errorHighlight &&
               !tagsField.errorHighlight &&
               dueFieldDate.dueDateIsSet && dueFieldTime.dueTimeIsSet &&
               Date.fromLocaleString(Qt.locale(), dueFieldDate.value + " " + dueFieldTime.value, "ddd MMM d yyyy hh:mm:ss") > Date.now()

    onDone: {
        if (result == DialogResult.Accepted) {
            name = nameField.text
            description = descriptionField.text
            tags = tagsField.text
            urgency = urgencyField.sliderValue
            due = Date.fromLocaleString(Qt.locale(), dueFieldDate.value + " " + dueFieldTime.value, "ddd MMM d yyyy hh:mm:ss")
        }
    }
}
