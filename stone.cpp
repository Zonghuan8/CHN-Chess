#include "stone.h"
#include <QDebug>

Stone::Stone(QObject *parent) : QObject(parent) {}

Stone::~Stone() {}

Stone::TYPE Stone::name() const
{
    return _type;
}

void Stone::init(int id)
{
    struct
    {
        int row, col;
        Stone::TYPE type;
    } pos[16] = {
        {0, 0, Stone::CHE},
        {0, 1, Stone::MA},
        {0, 2, Stone::XIANG},
        {0, 3, Stone::SHI},
        {0, 4, Stone::JIANG},
        {0, 5, Stone::SHI},
        {0, 6, Stone::XIANG},
        {0, 7, Stone::MA},
        {0, 8, Stone::CHE},

        {2, 1, Stone::PAO},
        {2, 7, Stone::PAO},
        {3, 0, Stone::BING},
        {3, 2, Stone::BING},
        {3, 4, Stone::BING},
        {3, 6, Stone::BING},
        {3, 8, Stone::BING},
    };

    if (id < 16) {
        this->_col = pos[id].col;
        this->_row = pos[id].row;
        this->_type = pos[id].type;
    } else {
        this->_col = 8 - pos[id - 16].col;
        this->_row = 9 - pos[id - 16].row;
        this->_type = pos[id - 16].type;
    }

    this->_dead = false;
    this->_red = id < 16;
    this->_id = id;
    this->_isPiece = true;
    this->_isSelected = false;
}

void Stone::setRow(int row)
{
    if (_row != row) {
        _row = row;
        emit rowChanged();
    }
}

void Stone::setCol(int col)
{
    if (_col != col) {
        _col = col;
        emit colChanged();
    }
}

void Stone::setDead(bool dead)
{
    if (_dead != dead) {
        _dead = dead;
        emit deadChanged();
    }
}
