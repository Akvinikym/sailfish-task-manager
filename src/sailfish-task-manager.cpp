#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include "taskrefresher.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<TaskRefresher>("refresher.TaskManager", 1, 0, "Refresher");
    return SailfishApp::main(argc, argv);
}
