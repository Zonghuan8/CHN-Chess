#pragma once
#include <QObject>
#include <QVector>
#include "stone.h"
#include <QtQml/qqmlregistration.h>
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

signals:
    void stonesChanged();
public slots:
    void handlePieceClick(const QString &pieceText, qreal centerX, qreal centerY)
    {
        qDebug() << "棋子被点击:" << pieceText << "位置: (" << centerX << "," << centerY << ")";
    }

private:
    QVector<Stone *> m_stones; // 存储所有棋子
};

// int _r;
// bool _bSide;
//QVector<Step*> _steps;

/* game status */
// int _selectid;
// bool _bRedTurn;

// void init(bool bRedSide);

/* function for coordinate */
// QPoint center(int row, int col) const;
// QPoint center(int id) const;

// /* help function */
// QString name(int id) const;
// bool red(int id) const;
// bool sameColor(int id1, int id2) const;
// int getStoneId(int row, int col) const;
// void killStone(int id);
// void reliveStone(int id);
// void moveStone(int moveid, int row, int col);
// bool isDead(int id) const;
// Stone* stone(int id); // 添加获取棋子指针的方法

/* move stone */
// void click(int row, int col);
// void trySelectStone(int id);
// void tryMoveStone(int killid, int row, int col);
// void moveStone(int moveid, int killid, int row, int col);
// void saveStep(int moveid, int killid, int row, int col, QVector<Step*>& steps);
// void backOne();
// void back(Step* step);
// void back();

/* rule */
// bool canMove(int moveid, int killid, int row, int col) const;
// bool canMoveChe(int moveid, int killid, int row, int col) const;
// bool canMoveMa(int moveid, int killid, int row, int col) const;
// bool canMovePao(int moveid, int killid, int row, int col) const;
// bool canMoveBing(int moveid, int killid, int row, int col) const;
// bool canMoveJiang(int moveid, int killid, int row, int col) const;
// bool canMoveShi(int moveid, int killid, int row, int col) const;
// bool canMoveXiang(int moveid, int killid, int row, int col) const;

// bool canSelect(int id) const;

// /* rule helper */
// int getStoneCountAtLine(int row1, int col1, int row2, int col2) const;
// int relation(int row1, int col1, int row, int col) const;
// bool isBottomSide(int id) const;
