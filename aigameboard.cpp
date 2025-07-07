#include "aigameboard.h"
#include <QtMath>
#include <QDebug>

#include <QCoreApplication>

AIGameBoard::AIGameBoard(QObject* parent) : Board(parent), m_engine(new EleeyeEngine(this))
{
    connect(m_engine,
            &EleeyeEngine::bestMoveReceived,
            this,
            [=](int moveId, int fromCol, int fromRow, int toCol, int toRow, int killId) {
                // 计算实际棋子ID
                int actualMoveId = getPieceId(fromCol, fromRow);
                int actualKillId = getPieceId(toCol, toRow);

                QTimer::singleShot(500, this, [=]() {
                    moveStone(fromCol, fromRow, toCol, toRow);
                    emit computerMoved(actualMoveId, fromCol, fromRow, toCol, toRow, actualKillId);
                });
            });

    // 使用应用程序目录作为基础路径
    QString appDir = QCoreApplication::applicationDirPath();
    QString enginePath = "../../engines/eleeye";
    m_engine->startEngine(enginePath);
}

AIGameBoard::~AIGameBoard()
{
    if (m_engine) {
        //m_engine->quitEngine();
        m_engine->deleteLater();
    }
}

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
    if (m_engine) { m_engine->startEngine("../../engines/eleeye"); }
}

void AIGameBoard::computerMove()
{
    if (isGameOver()) return;
    if (isRedTurn() != m_aiIsRed) return;

    if (m_engine && m_engine->isReady()) {
        // 使用引擎
        QString fen = getBoardFEN();
        m_engine->setPosition(fen);
        m_engine->think(m_aiLevel * 9); // 思考深度基于AI等级
    } else {
        // 备选方案：Minimax算法
        Step* step = getBestMove();
        if (step) {
            int fromCol = step->colFrom();
            int fromRow = step->rowFrom();
            int toCol = step->colTo();
            int toRow = step->rowTo();
            int moveId = step->moveId();
            int killId = step->killId();

            delete step;

            QTimer::singleShot(500, this, [=]() {
                moveStone(fromCol, fromRow, toCol, toRow);
                emit computerMoved(moveId, fromCol, fromRow, toCol, toRow, killId);
            });
        }
    }
}

QString AIGameBoard::getBoardFEN() const
{
    // 棋子类型到字母的映射
    QMap<Stone::TYPE, QChar> pieceMap = {{Stone::CHE, 'r'},
                                         {Stone::MA, 'n'},
                                         {Stone::XIANG, 'b'},
                                         {Stone::SHI, 'a'},
                                         {Stone::JIANG, 'k'},
                                         {Stone::PAO, 'c'},
                                         {Stone::BING, 'p'}};

    // 初始化10行9列的空棋盘
    QVector<QVector<QChar>> board(10, QVector<QChar>(9, '-'));

    // 填充棋盘
    for (int i = 0; i < 32; i++) {
        Stone* stone = getStoneById(i);
        if (stone && !stone->dead()) {
            QChar pieceChar = pieceMap[stone->type()];
            if (stone->isRed()) pieceChar = pieceChar.toUpper();
            board[stone->row()][stone->col()] = pieceChar;
        }
    }

    // 构建FEN字符串
    QString fen;
    for (int row = 0; row < 10; row++) {
        int emptyCount = 0;
        for (int col = 0; col < 9; col++) {
            if (board[row][col] == '-') {
                emptyCount++;
            } else {
                if (emptyCount > 0) {
                    fen += QString::number(emptyCount);
                    emptyCount = 0;
                }
                fen += board[row][col];
            }
        }
        if (emptyCount > 0) { fen += QString::number(emptyCount); }
        if (row < 9) fen += '/';
    }

    // 添加轮到谁走
    fen += (m_bRedTurn ? " w" : " b");

    return fen;
}

QString AIGameBoard::pieceToFEN(int type, bool isRed) const
{
    static const QString redPieces = "KABNRCP";
    static const QString blackPieces = "kabnrcp";

    if (type >= 0 && type < redPieces.length()) {
        return isRed ? QString(redPieces[type]) : QString(blackPieces[type]);
    }
    return "";
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
                    steps.append(new Step(i, killid, stoneObj->row(), stoneObj->col(), row, col));
                }
            }
        }
    }
}

int AIGameBoard::score()
{
    // 简单的评价函数
    static int pieceValues[] = {10000, 900, 900, 500, 1000, 200, 200};
    int redScore = 0;
    int blackScore = 0;

    for (int i = 0; i < 32; ++i) {
        Stone* stone = getStoneById(i);
        if (!stone || stone->dead()) continue;

        int value = pieceValues[stone->type()];
        if (stone->isRed()) {
            redScore += value;
            // 红方棋子位置加分（靠近对方底线加分）
            value += (9 - stone->row()) * 5;
        } else {
            blackScore += value;
            // 黑方棋子位置加分（靠近对方底线加分）
            value += stone->row() * 5;
        }
    }

    return m_aiIsRed ? (redScore - blackScore) : (blackScore - redScore);
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

// Step类实现
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
