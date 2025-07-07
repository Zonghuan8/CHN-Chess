//stone.cpp
#include "stone.h"
#include <QDebug>

Stone::Stone(QObject *parent) : QObject(parent) {}

Stone::~Stone() {}

// stone.cpp
QDataStream &operator<<(QDataStream &out, const Stone *stone)
{
    out << stone->id() << stone->row() << stone->col() << stone->dead() << stone->selected()
        << static_cast<qint32>(stone->type()) << stone->isRed();
    return out;
}

QDataStream &operator>>(QDataStream &in, Stone *&stone)
{
    int id, row, col, type;
    bool dead, selected, isRed;

    in >> id >> row >> col >> dead >> selected >> type >> isRed;

    // 假设 stone 已经创建
    stone->setRow(row);
    stone->setCol(col);
    stone->setDead(dead);
    stone->setSelected(selected);
    // 类型和颜色在初始化时已设置，不需要修改

    return in;
}

void Stone::setSelected(bool selected)
{
    if (m_selected != selected) {
        m_selected = selected;
        emit selectedChanged(); //触发信号
    }
}

void Stone::init(int id)
{
    m_id = id;

    struct Position
    {
        int row;
        int col;
        TYPE type;
    };

    static const Position pos[16] = {{0, 0, CHE},
                                     {0, 1, MA},
                                     {0, 2, XIANG},
                                     {0, 3, SHI},
                                     {0, 4, JIANG},
                                     {0, 5, SHI},
                                     {0, 6, XIANG},
                                     {0, 7, MA},
                                     {0, 8, CHE},
                                     {2, 1, PAO},
                                     {2, 7, PAO},
                                     {3, 0, BING},
                                     {3, 2, BING},
                                     {3, 4, BING},
                                     {3, 6, BING},
                                     {3, 8, BING}};

    if (id < 16) {
        m_row = pos[id].row;
        m_col = pos[id].col;
        m_type = pos[id].type;
    } else {
        m_row = 9 - pos[id - 16].row;
        m_col = 8 - pos[id - 16].col;
        m_type = pos[id - 16].type;
    }

    m_dead = false;
    m_selected = false;
    m_red = (id >= 16);

    //qDebug() << "初始化棋子 ID:" << m_id << "位置: (" << m_col << "," << m_row << ")"
    //          << "类型:" << m_type << "颜色:" << (m_red ? "红" : "黑");
}

void Stone::setRow(int row)
{
    if (m_row != row) {
        m_row = row;
        emit rowChanged();
    }
}

void Stone::setCol(int col)
{
    if (m_col != col) {
        m_col = col;
        emit colChanged();
    }
}

void Stone::setDead(bool dead)
{
    if (m_dead != dead) {
        m_dead = dead;
        emit deadChanged();
    }
}
