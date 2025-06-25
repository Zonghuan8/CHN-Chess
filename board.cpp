#include "board.h"

// #include <QTime>
// #include <QtGlobal>

#include <QPoint>
#include <QDebug>
Board::Board(QObject *parent) : QObject(parent)
{
    //创建32个棋子对象
    for (int i = 0; i < 32; i++) {
        Stone *stone = new Stone(this);
        stone->init(i);
        m_stones.append(stone);
    }
    for (Stone *stone : m_stones) {
        qDebug() << "验证棋子 ID:" << stone->id() << "位置: (" << stone->col() << "," << stone->row() << ")"
                 << "类型:" << stone->type() << "颜色:" << (stone->isRed() ? "红" : "黑");
    }
}

void Board::initGame()
{
    //清空历史记录
    m_steps.clear();
    qDebug() << "游戏初始化: 清空历史记录";

    //重置所有棋子状态
    for (Stone *stone : m_stones) {
        stone->init(stone->id());
    }

    //重置游戏状态
    m_bRedTurn = true;
    m_gameOver = false;
    m_selectid = -1;

    qDebug() << "游戏初始化完成";

    emit stonesChanged();
}

Stone *Board::getStoneById(int id) const
{
    for (Stone *stone : m_stones) {
        if (stone->id() == id) { return stone; }
    }
    qWarning() << "无效的棋子ID:" << id;
    return nullptr;
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
        if (st->col() == x && st->row() == y) {
            //qDebug("这是棋子");
            return true;
        }
    }
    return false;
}

int Board::getPieceId(int col, int row)
{
    //qDebug() << "查询位置: (" << col << "," << row << ")";

    //边界检查
    if (row < 0 || row > 9 || col < 0 || col > 8) {
        // qDebug() << "位置超出边界";
        return -1;
    }

    //遍历所有棋子
    for (Stone *stone : m_stones) {
        if (stone->dead()) continue;

        if (stone->col() == col && stone->row() == row) { return stone->id(); }
    }
    return -1;
}

bool Board::trySelectStone(int row, int col)
{
    int id = getPieceId(row, col);
    if (id == -1) return false;

    //检查是否可以选中（轮到该方走棋）
    if (m_bRedTurn != m_stones[id]->isRed()) { return false; }

    m_selectid = id;
    emit stonesChanged();
    return true;
}

bool Board::moveStone(int fromCol, int fromRow, int toCol, int toRow)
{
    int moveid = getPieceId(fromCol, fromRow);
    int killid = getPieceId(toCol, toRow);

    if (moveid == -1) { return false; }

    //检查是否可以走棋
    if (!canMove(moveid, killid, toCol, toRow)) { return false; }

    //保存原始位置
    int originalCol = m_stones[moveid]->col();
    int originalRow = m_stones[moveid]->row();

    //移动当前棋子到新位置
    m_stones[moveid]->setCol(toCol);
    m_stones[moveid]->setRow(toRow);

    MoveRecord record(moveid, fromRow, fromCol, toRow, toCol, killid, (killid != -1) ? m_stones[killid]->dead() : false);

    //存储移动记录到步骤列表
    m_steps.append(record);
    qDebug() << "记录移动：" << record.toString() << "总步数:" << m_steps.size();
    //处理吃棋
    if (killid != -1) {
        //标记被吃棋子为死亡状态
        m_stones[killid]->setDead(true);

        //检查是否吃掉将/帅
        if (m_stones[killid]->type() == Stone::JIANG) {
            QString winner = m_stones[moveid]->isRed() ? "红方" : "黑方";
            m_gameOver = true;
            emit gameOver(winner);
        }
    }

    //切换回合
    m_bRedTurn = !m_bRedTurn;
    m_selectid = -1;

    //发送信号通知移动完成
    emit stonesChanged();
    clearSelection();
    return true;
}

void Board::setSelectedPieceId(int id)
{
    if (m_selectedPieceId != id) {
        //清除原选中状态
        if (m_selectedPieceId != -1) {
            Stone *oldStone = getStoneById(m_selectedPieceId);
            if (oldStone) { oldStone->setSelected(false); }
        }

        //设置新选中状态
        m_selectedPieceId = id;
        if (id != -1) {
            Stone *newStone = getStoneById(id);
            if (newStone) { newStone->setSelected(true); }
        }
    }
}

void Board::clearSelection()
{
    setSelectedPieceId(-1);
}

bool Board::canMove(int moveid, int killid, int col, int row)
{
    //不能吃同色棋子
    if (killid != -1 && m_stones[moveid]->isRed() == m_stones[killid]->isRed()) { return false; }

    //根据棋子类型调用具体的走法规则
    switch (m_stones[moveid]->type()) {
    case Stone::CHE:
        return canMoveChe(moveid, killid, col, row);
    case Stone::MA:
        return canMoveMa(moveid, killid, col, row);
    case Stone::PAO:
        return canMovePao(moveid, killid, col, row);
    case Stone::BING:
        return canMoveBing(moveid, killid, col, row);
    case Stone::JIANG:
        return canMoveJiang(moveid, killid, col, row);
    case Stone::SHI:
        return canMoveShi(moveid, killid, col, row);
    case Stone::XIANG:
        return canMoveXiang(moveid, killid, col, row);
    default:
        return false;
    }
}

//车
bool Board::canMoveChe(int moveid, int killid, int col, int row)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    //检查目标位置是否在棋盘范围内
    if (row < 0 || row > 9 || col < 0 || col > 8) {
        // qDebug() << "兵移动：目标位置超出棋盘范围";

        return false;
    }

    //同行或同列
    if (fromRow != row && fromCol != col) {
        // qDebug() << "车移动：必须同行或同列";
        return false;
    }

    //检查路径是否有阻挡
    if (fromRow == row) { //水平移动：检查列
        int minCol = qMin(fromCol, col);
        int maxCol = qMax(fromCol, col);
        for (int c = minCol + 1; c < maxCol; c++) {
            if (getPieceId(c, row) != -1) return false;
        }
    } else { //垂直移动：检查行
        int minRow = qMin(fromRow, row);
        int maxRow = qMax(fromRow, row);
        for (int r = minRow + 1; r < maxRow; r++) {
            if (getPieceId(fromCol, r) != -1) return false;
        }
    }
    return true;
}

bool Board::canMoveMa(int moveid, int, int targetCol, int targetRow)
{
    //检查目标位置是否合法
    if (targetRow < 0 || targetRow > 9 || targetCol < 0 || targetCol > 8) {
        qDebug() << "目标位置超出棋盘范围";
        return false;
    }

    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();
    Stone *movingStone = m_stones[moveid];

    //定义八个可能的方向：先直走一步，再斜走一步
    const int directionCount = 8;
    const int dx[directionCount] = {1, 2, 2, 1, -1, -2, -2, -1};
    const int dy[directionCount] = {2, 1, -1, -2, -2, -1, 1, 2};
    const int legDx[directionCount] = {0, 1, 1, 0, 0, -1, -1, 0}; //马腿的x偏移
    const int legDy[directionCount] = {1, 0, 0, -1, -1, 0, 0, 1}; //马腿的y偏移

    //遍历八个方向
    for (int i = 0; i < directionCount; i++) {
        int toCol = fromCol + dx[i];
        int toRow = fromRow + dy[i];

        //检查是否是目标位置
        if (toCol == targetCol && toRow == targetRow) {
            //计算马腿位置
            int legCol = fromCol + legDx[i];
            int legRow = fromRow + legDy[i];

            //检查马腿位置是否有棋子
            if (getPieceId(legCol, legRow) != -1) {
                // qDebug() << "马腿被绊，位置:(" << legCol << "," << legRow << ")";

                return false;
            }

            //检查目标位置是否有己方棋子
            int targetId = getPieceId(targetCol, targetRow);
            if (targetId != -1 && m_stones[targetId]->isRed() == movingStone->isRed()) {
                // qDebug() << "尝试吃己方棋子，移动失败";

                return false;
            }

            return true; //找到合法路径
        }
    }

    //没有找到通往目标位置的合法路径

    // qDebug() << "不符合马的走法规则";

    return false;
}

bool Board::canMovePao(int moveid, int killid, int col, int row)
{
    //检查目标位置是否合法
    if (row < 0 || row > 9 || col < 0 || col > 8) {
        //qDebug() << "炮移动：目标位置超出棋盘范围";

        return false;
    }

    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();
    Stone *movingStone = m_stones[moveid];

    //炮只能直行
    if (fromRow != row && fromCol != col) {
        // qDebug() << "炮移动：只能直行";

        return false;
    }

    //计算路径上的棋子数
    int stoneCount = 0;

    if (fromRow == row) { //水平移动
        int startCol = qMin(fromCol, col) + 1;
        int endCol = qMax(fromCol, col);

        for (int c = startCol; c < endCol; c++) {
            //col在前，row在后
            if (getPieceId(c, row) != -1) {
                // qDebug() << "发现中间棋子，位置:(" << c << "," << row << ")";

                stoneCount++;
            }
        }
    } else { //垂直移动
        int startRow = qMin(fromRow, row) + 1;
        int endRow = qMax(fromRow, row);

        for (int r = startRow; r < endRow; r++) {
            //修正参数顺序：col在前，row在后
            if (getPieceId(col, r) != -1) {
                // qDebug() << "发现中间棋子，位置:(" << col << "," << r << ")";
                stoneCount++;
            }
        }
    }

    //炮的走法规则
    if (killid == -1) { //移动
        if (stoneCount != 0) {
            // qDebug() << "炮移动：路径上有" << stoneCount << "个棋子，必须为0";

            return false;
        }

        //目标位置必须为空
        int targetId = getPieceId(col, row);
        if (targetId != -1) {
            // qDebug() << "炮移动：目标位置有棋子，ID=" << targetId;

            return false;
        }

        return true;
    } else { //吃子
        if (stoneCount != 1) {
            // qDebug() << "炮吃子：路径上有" << stoneCount << "个棋子，必须为1";

            return false;
        }

        //验证killid有效性
        if (killid < 0 || killid > 32) {
            // qDebug() << "炮吃子：无效的killid=" << killid;

            return false;
        }

        if (m_stones[killid] == nullptr) {
            // qDebug() << "炮吃子：m_stones[" << killid << "]为空指针";

            return false;
        }

        //目标位置必须是对方棋子
        if (m_stones[killid]->col() != col || m_stones[killid]->row() != row) {
            // qDebug() << "炮吃子：killid位置与目标位置不匹配";

            return false;
        }

        if (m_stones[killid]->isRed() == movingStone->isRed()) {
            // qDebug() << "炮吃子：不能吃己方棋子";

            return false;
        }

        return true;
    }
}

bool Board::canMoveBing(int moveid, int, int col, int row)
{
    int fromRow = m_stones[moveid]->row();
    int fromCol = m_stones[moveid]->col();

    //检查目标位置是否在棋盘范围内
    if (row < 0 || row > 9 || col < 0 || col > 8) {
        // qDebug() << "兵移动：目标位置超出棋盘范围";

        return false;
    }

    //兵只能走一步
    if (qAbs(row - fromRow) + qAbs(col - fromCol) != 1) { return false; }

    bool isRed = m_stones[moveid]->isRed();

    // 红棋在下（行号大），黑棋在上（行号小）
    if (isRed) {
        // 红兵只能向上走（行号减小）
        if (row > fromRow) return false; // 不能向下

        // 红兵过河前（行 > 4）不能横走
        if (fromRow > 4 && col != fromCol) return false;
    } else {
        // 黑卒只能向下走（行号增加）
        if (row < fromRow) return false; // 不能向上

        // 黑卒过河前（行 < 5）不能横走
        if (fromRow < 5 && col != fromCol) return false;
    }

    return true;
}

bool Board::canMoveJiang(int moveid, int killid, int col, int row)
{
    // 检查目标位置是否在棋盘范围内
    if (col < 0 || col > 8 || row < 0 || row > 9) { return false; }

    Stone *movingStone = m_stones[moveid];
    int fromRow = movingStone->row();
    int fromCol = movingStone->col();
    bool isRed = movingStone->isRed();

    // 计算移动距离
    int rowDiff = qAbs(row - fromRow);
    int colDiff = qAbs(col - fromCol);
    int distance = rowDiff + colDiff;

    // 情况1：普通移动（移动一格）
    if (distance == 1) {
        // 检查列是否在九宫范围内（3-5列）
        if (col < 3 || col > 5) { return false; }

        // 红方帅在棋盘下方（7-9行）
        if (isRed) {
            if (row < 7 || row > 9) { return false; }
        }
        // 黑方将在棋盘上方（0-2行）
        else {
            if (row < 0 || row > 2) { return false; }
        }

        // 检查吃子规则
        if (killid != -1) {
            Stone *targetStone = m_stones[killid];
            // 目标必须是对方棋子
            if (targetStone->isRed() == isRed) { return false; }
        }

        return true;
    }
    // 情况2：将帅对脸特殊吃法
    else {
        // 必须是吃子且目标是对方将/帅
        if (killid == -1 || m_stones[killid]->type() != Stone::JIANG) { return false; }

        // 必须同一列
        if (col != fromCol) { return false; }

        // 检查中间是否有棋子
        int minRow = qMin(row, fromRow);
        int maxRow = qMax(row, fromRow);
        for (int r = minRow + 1; r < maxRow; r++) {
            if (getPieceId(col, r) != -1) { return false; }
        }

        return true;
    }
}

bool Board::canMoveShi(int moveid, int killid, int col, int row)
{
    Stone *stone = m_stones[moveid];
    int fromRow = stone->row();
    int fromCol = stone->col();
    bool isRed = stone->isRed();

    // 士只能斜走一步（行和列各变化1格）
    if (qAbs(row - fromRow) != 1 || qAbs(col - fromCol) != 1) { return false; }

    // 士不能出九宫（列3-5）
    if (col < 3 || col > 5) { return false; }

    // 红士在棋盘下方（7-9行）
    if (isRed) {
        if (row < 7 || row > 9) { return false; }
    }
    // 黑士在棋盘上方（0-2行）
    else {
        if (row < 0 || row > 2) { return false; }
    }

    // 检查是否吃子
    if (killid != -1) {
        Stone *target = m_stones[killid];
        if (target->isRed() == isRed) { return false; }
    }

    return true;
}

bool Board::canMoveXiang(int moveid, int killid, int col, int row)
{
    Stone *stone = m_stones[moveid];
    int fromRow = stone->row();
    int fromCol = stone->col();
    bool isRed = stone->isRed();

    // 相/象走田字（对角线移动两格）
    if (qAbs(row - fromRow) != 2 || qAbs(col - fromCol) != 2) { return false; }

    // 检查象眼（田字中心位置）
    int eyeRow = (fromRow + row) / 2;
    int eyeCol = (fromCol + col) / 2;
    if (getPieceId(eyeCol, eyeRow) != -1) { return false; }

    // 红相在棋盘下方（5-9行）
    if (isRed) {
        if (row < 5) { return false; }
    }
    // 黑象在棋盘上方（0-4行）
    else {
        if (row > 4) { return false; }
    }

    // 检查吃子规则
    if (killid != -1) {
        Stone *target = m_stones[killid];
        if (target->isRed() == isRed) { return false; }
    }

    return true;
}

void Board::reliveStone(int id)
{
    if (id != -1) {
        Stone *stone = getStoneById(id);
        if (stone) { stone->setDead(false); }
    }
}

void Board::backOne()
{
    if (m_steps.size() == 0) {
        // qDebug() << "无法悔棋: 没有历史记录";

        return;
    }

    //获取最后一步记录
    MoveRecord record = m_steps.last();
    m_steps.removeLast();

    qDebug() << "悔棋：" << record.toString();

    //复活被吃的棋子
    reliveStone(record.killId());

    //移动棋子回原位置
    Stone *movedStone = getStoneById(record.moveId());
    if (movedStone) {
        movedStone->setRow(record.fromRow());
        movedStone->setCol(record.fromCol());
        // qDebug() << "恢复棋子" << record.moveId() << "到位置(" << record.fromCol() << "," << record.fromRow() << ")";
    }

    //恢复游戏状态
    m_bRedTurn = !m_bRedTurn; //切换回之前的玩家回合
    m_gameOver = false;       //取消游戏结束状态

    //更新界面
    emit stonesChanged();
    clearSelection();
    emit undoPerformed();
}

void Board::undoMove()
{
    qDebug() << "尝试悔棋...";
    qDebug() << "历史记录数:" << m_steps.size();
    qDebug() << "游戏结束状态:" << m_gameOver;

    if (m_gameOver) { qDebug() << "游戏已结束，允许悔棋..."; }

    backOne();
}
