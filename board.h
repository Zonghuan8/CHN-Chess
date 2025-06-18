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

    Q_INVOKABLE void initGame();

    Q_INVOKABLE QPoint clickPosition(int cellSize, qreal x, qreal y);

    Q_INVOKABLE bool isPiece(int x, int y); //判断是否为棋子

    Q_INVOKABLE int getPieceId(int x, int y); //获取棋子id

    // 走棋和吃棋方法
    Q_INVOKABLE bool moveStone(int fromRow, int fromCol, int toRow, int toCol);
    Q_INVOKABLE bool trySelectStone(int row, int col);

    // Q_INVOKABLE void isSelected(int id); //选中一个棋子

    // Q_INVOKABLE void move(int id, int x, int y);

    // Q_INVOKABLE void deselectPiece(); //取消选中
signals:
    void stonesChanged();
    void selectionCleared();
public slots:

private:
    bool canMove(int moveid, int killid, int row, int col);
    bool canMoveChe(int moveid, int killid, int row, int col);
    bool canMoveMa(int moveid, int killid, int row, int col);
    bool canMovePao(int moveid, int killid, int row, int col);
    bool canMoveBing(int moveid, int killid, int row, int col);
    bool canMoveJiang(int moveid, int killid, int row, int col);
    bool canMoveShi(int moveid, int killid, int row, int col);
    bool canMoveXiang(int moveid, int killid, int row, int col);
    int m_selectedPieceId = -1; // 当前选中的棋子ID
    QVector<Stone *> m_stones; // 存储所有棋子
    int m_selectid = -1;
    bool m_bRedTurn = true;
    bool m_bSide = true; // true为红方在下
};
