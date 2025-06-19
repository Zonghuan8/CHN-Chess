// moverecord.h
#pragma once
#include <QObject>
#include <QtQml/qqmlregistration.h>
class Stone; // 前置声明

class MoveRecord : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    // 默认构造函数
    explicit MoveRecord(QObject *parent = nullptr);

    // 带参数的构造函数
    MoveRecord(int moveId,
               int fromRow,
               int fromCol,
               int toRow,
               int toCol,
               int killId,
               bool wasDead,
               QObject *parent = nullptr);

    // 拷贝构造函数
    MoveRecord(const MoveRecord &other);

    // 赋值运算符
    MoveRecord &operator=(const MoveRecord &other);

    // 比较运算符
    bool operator==(const MoveRecord &other) const;

    // 获取移动的棋子ID
    int moveId() const;

    // 获取起始行
    int fromRow() const;

    // 获取起始列
    int fromCol() const;

    // 获取目标行
    int toRow() const;

    // 获取目标列
    int toCol() const;

    // 获取被吃的棋子ID
    int killId() const;

    // 获取被吃棋子之前的状态
    bool wasDead() const;

    QString toString() const;

private:
    int m_moveId;   // 移动的棋子ID
    int m_fromRow;  // 起始行
    int m_fromCol;  // 起始列
    int m_toRow;    // 目标行
    int m_toCol;    // 目标列
    int m_killId;   // 被吃的棋子ID（-1表示没有吃子）
    bool m_wasDead; // 被吃棋子之前的状态
};
