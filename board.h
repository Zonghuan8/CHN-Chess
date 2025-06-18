#pragma once
#include <QObject>
#include <QVector>
#include "stone.h"
#include <QtQml/qqmlregistration.h>
#include <QPoint> // 在头文件中包含
class Board : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<Stone *> stones READ stones NOTIFY stonesChanged)
    QML_ELEMENT
public:
    explicit Board(QObject *parent = nullptr);

    QVector<Stone *> stones() const { return m_stones; }

    // 初始化所有棋子
    Q_INVOKABLE void initGame();

    Q_INVOKABLE QPoint clickPosition(int cellSize, qreal x, qreal y);
signals:
    void stonesChanged();
public slots:

private:
    QVector<Stone *> m_stones; // 存储所有棋子
};
