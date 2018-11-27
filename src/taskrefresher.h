#ifndef TASKREFRESHER_H
#define TASKREFRESHER_H
#include <QObject>

class TaskRefresher : public QObject
{
    Q_OBJECT

public:
    explicit TaskRefresher(QObject *parent = nullptr);

signals:
    void secondPassed();

public slots:
    void emitSecond();

};

#endif // TASKREFRESHER_H
