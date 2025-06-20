#include "aigameboard.h"
#include <QtMath>
#include <QRandomGenerator>
#include <QDebug>

AIGameBoard::AIGameBoard(QObject* parent) : Board(parent) {}

bool AIGameBoard::aiIsRed() const
{
    return m_aiIsRed;
}

void AIGameBoard::setAiIsRed(bool isRed)
{
    if (m_aiIsRed != isRed) {
        m_aiIsRed = isRed;
        emit aiIsRedChanged();
    }
}

int AIGameBoard::aiLevel() const
{
    return m_aiLevel;
}

void AIGameBoard::setAiLevel(int level)
{
    if (m_aiLevel != level) {
        m_aiLevel = level;
        emit aiLevelChanged();
    }
}

void AIGameBoard::startNewGame()
{
    initGame();
}

void AIGameBoard::computerMove()
{
    if (isGameOver()) return;
    if (m_bRedTurn != m_aiIsRed) return;

    Step* step = getBestMove();
    if (step) {
        //保存移动信息
        int fromCol = step->colFrom();
        int fromRow = step->rowFrom();
        int toCol = step->colTo();
        int toRow = step->rowTo();
        int moveId = step->moveId();
        int killId = step->killId();

        delete step;

        //延迟执行移动
        QTimer::singleShot(500, this, [=]() {
            moveStone(fromCol, fromRow, toCol, toRow);
            emit computerMoved(moveId, fromCol, fromRow, toCol, toRow, killId);
        });
    }
}

Step* AIGameBoard::getBestMove()
{
    Step* ret = nullptr;
    QVector<Step*> steps;
    getAllPossibleMove(steps);
    int maxInAllMinScore = -300000;

    while (steps.count()) {
        Step* step = steps.last();
        steps.removeLast();

        fakeMove(step);
        int minScore = getMinScore(m_aiLevel - 1, maxInAllMinScore);
        unfakeMove(step);

        if (minScore > maxInAllMinScore) {
            if (ret) delete ret;
            ret = step;
            maxInAllMinScore = minScore;
        } else {
            delete step;
        }
    }
    return ret;
}

void AIGameBoard::getAllPossibleMove(QVector<Step*>& steps)
{
    int min, max;
    if (m_aiIsRed != isRedTurn()) {
        min = 0;
        max = 16;
    } else {
        min = 16;
        max = 32;
    }

    for (int i = min; i < max; i++) {
        Stone* stoneObj = getStoneById(i);
        if (!stoneObj || stoneObj->dead()) continue;

        for (int row = 0; row <= 9; ++row) {
            for (int col = 0; col <= 8; ++col) {
                int killid = getPieceId(col, row);

                if (killid != -1) {
                    Stone* killStoneObj = getStoneById(killid);
                    if (killStoneObj && stoneObj->isRed() == killStoneObj->isRed()) continue;
                }

                if (canMove(i, killid, col, row)) {
                    Step* step = new Step(i, killid, stoneObj->row(), stoneObj->col(), row, col);
                    steps.append(step);
                }
            }
        }
    }
}

int AIGameBoard::score()
{
    //棋子价值表
    static int s[] = {1000, 499, 501, 200, 15000, 100, 100};
    int scoreRed = 0;
    int scoreBlack = 0;

    for (int i = 0; i < 32; ++i) {
        Stone* stoneObj = getStoneById(i);
        if (!stoneObj || stoneObj->dead()) continue;

        int value = s[stoneObj->type()];
        if (stoneObj->isRed()) {
            scoreRed += value;
        } else {
            scoreBlack += value;
        }
    }

    //根据AI执方返回分数
    return m_aiIsRed ? (scoreRed - scoreBlack) : (scoreBlack - scoreRed);
}

int AIGameBoard::getMinScore(int level, int curMin)
{
    if (level == 0) return score();

    QVector<Step*> steps;
    getAllPossibleMove(steps);
    int minInAllMaxScore = 300000;

    while (steps.count()) {
        Step* step = steps.last();
        steps.removeLast();

        fakeMove(step);
        int maxScore = getMaxScore(level - 1, minInAllMaxScore);
        unfakeMove(step);
        delete step;

        if (maxScore <= curMin) {
            while (steps.count()) {
                Step* step = steps.last();
                steps.removeLast();
                delete step;
            }
            return maxScore;
        }

        if (maxScore < minInAllMaxScore) { minInAllMaxScore = maxScore; }
    }
    return minInAllMaxScore;
}

int AIGameBoard::getMaxScore(int level, int curMax)
{
    if (level == 0) return score();

    QVector<Step*> steps;
    getAllPossibleMove(steps);
    int maxInAllMinScore = -300000;

    while (steps.count()) {
        Step* step = steps.last();
        steps.removeLast();

        fakeMove(step);
        int minScore = getMinScore(level - 1, maxInAllMinScore);
        unfakeMove(step);
        delete step;

        if (minScore >= curMax) {
            while (steps.count()) {
                Step* step = steps.last();
                steps.removeLast();
                delete step;
            }
            return minScore;
        }

        if (minScore > maxInAllMinScore) { maxInAllMinScore = minScore; }
    }
    return maxInAllMinScore;
}

void AIGameBoard::fakeMove(Step* step)
{
    if (step->killId() != -1) { getStoneById(step->killId())->setDead(true); }

    Stone* movingStone = getStoneById(step->moveId());
    movingStone->setRow(step->rowTo());
    movingStone->setCol(step->colTo());

    setRedTurn(!isRedTurn());
}

void AIGameBoard::unfakeMove(Step* step)
{
    if (step->killId() != -1) { getStoneById(step->killId())->setDead(false); }

    Stone* movingStone = getStoneById(step->moveId());
    movingStone->setRow(step->rowFrom());
    movingStone->setCol(step->colFrom());

    //使用基类的 setRedTurn 方法
    setRedTurn(!isRedTurn());
}

//Step类实现
Step::Step(QObject* parent) : QObject(parent) {}

Step::Step(int moveId, int killId, int rowFrom, int colFrom, int rowTo, int colTo, QObject* parent)
    : QObject(parent)
    , m_moveId(moveId)
    , m_killId(killId)
    , m_rowFrom(rowFrom)
    , m_colFrom(colFrom)
    , m_rowTo(rowTo)
    , m_colTo(colTo)
{}

int Step::moveId() const
{
    return m_moveId;
}
int Step::killId() const
{
    return m_killId;
}
int Step::rowFrom() const
{
    return m_rowFrom;
}
int Step::colFrom() const
{
    return m_colFrom;
}
int Step::rowTo() const
{
    return m_rowTo;
}
int Step::colTo() const
{
    return m_colTo;
}
