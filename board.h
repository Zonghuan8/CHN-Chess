//棋盘逻辑类
#pragma once
#include <QObject>
#include <QVector>
#include "stone.h"
#include "moverecord.h"
#include <QStack>
#include <QDebug>
#include <QtQml/qqmlregistration.h>
#include <QPoint>
class Board : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<Stone *> stones READ stones NOTIFY stonesChanged)
    Q_PROPERTY(bool isRedTurn READ isRedTurn NOTIFY redTurnChanged)
    QML_ELEMENT
public:
    explicit Board(QObject *parent = nullptr);

    QVector<Stone *> stones() const { return m_stones; }

    Q_INVOKABLE bool isRedTurn() { return m_bRedTurn; }

    //初始化所有棋子
    Q_INVOKABLE void initGame();

    Q_INVOKABLE Stone *getStoneById(int id);
    Q_INVOKABLE QPoint clickPosition(int cellSize, qreal x, qreal y);

    Q_INVOKABLE bool isPiece(int x, int y); //判断是否为棋子

    Q_INVOKABLE int getPieceId(int x, int y); //获取棋子id
    Q_INVOKABLE void setSelectedPieceId(int id);
    Q_INVOKABLE void clearSelection();
    //走棋和吃棋方法
    Q_INVOKABLE bool moveStone(int fromRow, int fromCol, int toCol, int toRow);
    Q_INVOKABLE bool trySelectStone(int col, int row);

    Q_INVOKABLE bool canMove(int moveid, int killid, int col, int row);
    Q_INVOKABLE void undoMove();

    Q_INVOKABLE bool isGameOver() const { return m_gameOver; }
    void setRedTurn(bool turn)
    {
        if (m_bRedTurn != turn) {
            m_bRedTurn = turn;
            emit redTurnChanged();
        }
    }
    void reliveStone(int id);
    void backOne();
    bool checkJiangFaceOff(int moveid, int killid);
    bool canMoveChe(int moveid, int killid, int col, int row);
    bool canMoveMa(int moveid, int killid, int col, int row);
    bool canMovePao(int moveid, int killid, int col, int row);
    bool canMoveBing(int moveid, int killid, int col, int row);
    bool canMoveJiang(int moveid, int killid, int col, int row);
    bool canMoveShi(int moveid, int killid, int col, int row);
    bool canMoveXiang(int moveid, int killid, int col, int row);
    int m_selectedPieceId = -1; //当前选中的棋子ID
    bool m_gameOver = false;    //游戏是否结束
    QVector<Stone *> m_stones;  //存储所有棋子
    int m_selectid = -1;
    bool m_bRedTurn = true;
    bool m_bSide = false;
    QList<MoveRecord> m_steps;
signals:
    void gameOver(QString winner);
    void redTurnChanged();
    void stonesChanged();
    void undoPerformed();
    void selectionCleared();
public slots:
};
