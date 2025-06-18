#include "board.h"
#include <QPoint>
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

QPoint Board::clickPosition(int size, qreal x, qreal y)
{
    QPoint result;
    const int cellSize = size;
    //const int margin = 15;

    int col = qRound(x / cellSize);
    int row = qRound(y / cellSize);

    return {col, row};
}

bool Board::isPiece(int x, int y)
{
    for (Stone *st : m_stones) {
        if (st->col() == x && st->row() == y) return true;
    }
    return false;
}

int Board::getPieceId(int x, int y)
{
    for (Stone *st : m_stones) {
        if (st->col() == x && st->row() == y) return st->id();
    }
}

bool Board::trySelectStone(int row, int col)
{
    int id = getPieceId(row, col);
    if (id == -1) return false;

    // 检查是否可以选中（轮到该方走棋）
    if (m_bRedTurn != m_stones[id]->isRed()) { return false; }

    m_selectid = id;
    emit stonesChanged(); // 通知界面更新
    return true;
}

bool Board::moveStone(int fromRow, int fromCol, int toRow, int toCol)
{
    int moveid = getPieceId(fromRow, fromCol);
    int killid = getPieceId(toRow, toCol);

    if (moveid == -1) return false;

    // 检查是否可以走棋
    if (!canMove(moveid, killid, toRow, toCol)) { return false; }

    // 执行走棋
    m_stones[moveid]->setRow(toRow);
    m_stones[moveid]->setCol(toCol);

    // 处理吃棋
    bool isCapture = false;
    if (killid != -1) {
        m_stones[killid]->setDead(true);
        isCapture = true;
    }

    // 切换回合
    m_bRedTurn = !m_bRedTurn;
    m_selectid = -1;

    // 发送信号通知移动完成
    //emit moveMade(fromRow, fromCol, toRow, toCol, isCapture);
    emit stonesChanged();

    return true;
}

bool Board::canMove(int moveid, int killid, int row, int col)
{
    // 不能吃同色棋子
    if (killid != -1 && m_stones[moveid]->isRed() == m_stones[killid]->isRed()) { return false; }

    // 根据棋子类型调用具体的走法规则
    switch (m_stones[moveid]->type()) {
    case Stone::CHE:
        return canMoveChe(moveid, killid, row, col);
    case Stone::MA:
        return canMoveMa(moveid, killid, row, col);
    case Stone::PAO:
        return canMovePao(moveid, killid, row, col);
    case Stone::BING:
        return canMoveBing(moveid, killid, row, col);
    case Stone::JIANG:
        return canMoveJiang(moveid, killid, row, col);
    case Stone::SHI:
        return canMoveShi(moveid, killid, row, col);
    case Stone::XIANG:
        return canMoveXiang(moveid, killid, row, col);
    default:
        return false;
    }
}

bool Board::canMoveChe(int moveid, int, int row, int col)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    // 车只能直行
    if (fromRow != row && fromCol != col) { return false; }

    // 检查路径上是否有其他棋子
    if (fromRow == row) {
        int min = qMin(fromCol, col);
        int max = qMax(fromCol, col);
        for (int c = min + 1; c < max; c++) {
            if (getPieceId(row, c) != -1) { return false; }
        }
    } else {
        int min = qMin(fromRow, row);
        int max = qMax(fromRow, row);
        for (int r = min + 1; r < max; r++) {
            if (getPieceId(r, fromCol) != -1) { return false; }
        }
    }

    return true;
}

bool Board::canMoveMa(int moveid, int, int row, int col)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    // 马走"日"字
    int dr = qAbs(row - fromRow);
    int dc = qAbs(col - fromCol);

    if (!((dr == 2 && dc == 1) || (dr == 1 && dc == 2))) { return false; }

    // 检查马腿
    if (dr == 2) {
        int blockRow = (fromRow + row) / 2;
        if (getPieceId(blockRow, fromCol) != -1) { return false; }
    } else {
        int blockCol = (fromCol + col) / 2;
        if (getPieceId(fromRow, blockCol) != -1) { return false; }
    }

    return true;
}

bool Board::canMovePao(int moveid, int killid, int row, int col)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    // 炮只能直行
    if (fromRow != row && fromCol != col) { return false; }

    // 计算路径上的棋子数
    int stoneCount = 0;
    if (fromRow == row) {
        int min = qMin(fromCol, col);
        int max = qMax(fromCol, col);
        for (int c = min + 1; c < max; c++) {
            if (getPieceId(row, c) != -1) { stoneCount++; }
        }
    } else {
        int min = qMin(fromRow, row);
        int max = qMax(fromRow, row);
        for (int r = min + 1; r < max; r++) {
            if (getPieceId(r, fromCol) != -1) { stoneCount++; }
        }
    }

    // 炮的走法规则
    if (killid == -1) { // 移动
        return stoneCount == 0;
    } else { // 吃子
        return stoneCount == 1;
    }
}

bool Board::canMoveBing(int moveid, int, int row, int col)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    // 兵只能走一步
    if (qAbs(row - fromRow) + qAbs(col - fromCol) != 1) { return false; }

    bool isRed = m_stones[moveid]->isRed();

    // 兵不能后退
    if (isRed) {
        if (row < fromRow) return false;
    } else {
        if (row > fromRow) return false;
    }

    // 兵过河前不能横走
    if (isRed && fromRow < 5) {
        if (col != fromCol) return false;
    } else if (!isRed && fromRow > 4) {
        if (col != fromCol) return false;
    }

    return true;
}

bool Board::canMoveJiang(int moveid, int killid, int row, int col)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    // 将/帅只能走一步
    if (qAbs(row - fromRow) + qAbs(col - fromCol) != 1) {
        // 检查是否是将帅对脸
        if (killid != -1 && m_stones[killid]->type() == Stone::JIANG) { return canMoveChe(moveid, killid, row, col); }
        return false;
    }

    // 将/帅不能出九宫
    if (col < 3 || col > 5) return false;

    bool isRed = m_stones[moveid]->isRed();
    if (isRed) {
        if (row < 7) return false;
    } else {
        if (row > 2) return false;
    }

    return true;
}

bool Board::canMoveShi(int moveid, int, int row, int col)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    // 士只能斜走一步
    if (qAbs(row - fromRow) != 1 || qAbs(col - fromCol) != 1) { return false; }

    // 士不能出九宫
    if (col < 3 || col > 5) return false;

    bool isRed = m_stones[moveid]->isRed();
    if (isRed) {
        if (row < 7) return false;
    } else {
        if (row > 2) return false;
    }

    return true;
}

bool Board::canMoveXiang(int moveid, int, int row, int col)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    // 相/象走田字
    if (qAbs(row - fromRow) != 2 || qAbs(col - fromCol) != 2) { return false; }

    // 检查象眼
    int eyeRow = (fromRow + row) / 2;
    int eyeCol = (fromCol + col) / 2;
    if (getPieceId(eyeRow, eyeCol) != -1) { return false; }

    // 相/象不能过河
    bool isRed = m_stones[moveid]->isRed();
    if (isRed) {
        if (row < 5) return false;
    } else {
        if (row > 4) return false;
    }

    return true;
}
