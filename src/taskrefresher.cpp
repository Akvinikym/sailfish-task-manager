#include "taskrefresher.h"
#include <QTimer>

TaskRefresher::TaskRefresher(QObject *parent) : QObject(parent) {
    QTimer *timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(emitSecond()));
    timer->start(1000);
}

void TaskRefresher::emitSecond() {
    emit secondPassed();
}
