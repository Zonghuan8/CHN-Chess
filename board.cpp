#include "board.h"
#include <QDebug>
Board::Board(QObject *parent) : QObject(parent)
{
    // 创建32个棋子对象
    for (int i = 0; i < 32; i++) {
        //qDebug("qqq");
        Stone *stone = new Stone(this);
        stone->init(i);
        m_stones.append(stone);
    }
}

void Board::initGame()
{
    // 重置所有棋子状态
    for (Stone *stone : m_stones) {
        stone->init(stone->id());
    }
    emit stonesChanged();
}
