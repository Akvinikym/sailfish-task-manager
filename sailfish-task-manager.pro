# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = sailfish-task-manager

CONFIG += sailfishapp

SOURCES += src/sailfish-task-manager.cpp

DISTFILES += qml/sailfish-task-manager.qml \
    qml/cover/CoverPage.qml \
    rpm/sailfish-task-manager.changes.in \
    rpm/sailfish-task-manager.changes.run.in \
    rpm/sailfish-task-manager.spec \
    rpm/sailfish-task-manager.yaml \
    translations/*.ts \
    sailfish-task-manager.desktop \
    qml/pages/TasksPage.qml \
    qml/pages/TaskDialog.qml \
    qml/db/Dao.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/sailfish-task-manager-de.ts
