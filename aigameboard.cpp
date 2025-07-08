// aigameboard.cpp
#include "aigameboard.h"
#include <QtMath>
#include <QDebug>
#include <QCoreApplication>

AIGameBoard::AIGameBoard(QObject* parent) : Board(parent), m_engine(new EleeyeEngine(this))
{
    m_aiIsRed = false; // 明确设置为黑方

    // 连接带将军状态的信号
    connect(m_engine,
            &EleeyeEngine::bestMoveReceived,
            this,
            [=](int fromCol, int fromRow, int toCol, int toRow, bool isCheck) {
                int moveId = getPieceId(fromCol, fromRow);
                Stone* stone = getStoneById(moveId);

                // 验证棋子属于AI方
                if (!stone || stone->isRed() != m_aiIsRed) {
                    qDebug() << "AI移动错误：尝试移动" << (stone ? (stone->isRed() ? "红方" : "黑方") : "无效")
                             << "棋子，但AI执" << (m_aiIsRed ? "红" : "黑");
                    return;
                }

                // 检查是否可以攻击帅
                if (isCheck) {
                    qDebug() << "AI将军!";
                    emit checkWarning(!m_aiIsRed); // 发送将军警告
                }

                int killId = getPieceId(toCol, toRow);
                moveStone(fromCol, fromRow, toCol, toRow);
                emit computerMoved(moveId, fromCol, fromRow, toCol, toRow, killId);
            });

    // 使用应用程序目录作为基础路径
    QString appDir = QCoreApplication::applicationDirPath();
    QString enginePath = "../../engines/eleeye";
    m_engine->startEngine(enginePath);
}

AIGameBoard::~AIGameBoard()
{
    if (m_engine) { m_engine->deleteLater(); }
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

    // 确保AI只走自己的颜色
    if (isRedTurn() != m_aiIsRed) {
        qDebug() << "AI跳过：当前回合为" << (isRedTurn() ? "红方" : "黑方") << "但AI执" << (m_aiIsRed ? "红" : "黑");
        return;
    }

    // 1. 优先检查是否有立即将军的机会
    if (hasImmediateCheckmateMove()) {
        qDebug() << "发现直接将军机会，优先执行将军移动";
        performCheckmateMove();
        return;
    }

    // 2. 使用引擎计算最佳移动
    if (m_engine && m_engine->isReady()) {
        QString fen = getBoardFEN();
        qDebug() << "AI执" << (m_aiIsRed ? "红" : "黑") << "，发送FEN:" << fen;

        // 设置攻击性参数
        m_engine->sendCommand("setoption knowledge large");
        m_engine->sendCommand("setoption pruning small");

        // 设置位置并思考
        m_engine->setPosition(fen);
        m_engine->think(m_aiLevel * 9); // 增加思考深度
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

    // 调试输出棋盘状态
    qDebug() << "当前棋盘状态:";
    for (int row = 0; row < 10; row++) {
        QString rowStr;
        for (int col = 0; col < 9; col++) {
            rowStr += board[row][col];
        }
        qDebug() << "行" << row << ":" << rowStr;
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

    // 添加轮到谁走（红方w，黑方b）
    fen += (m_bRedTurn ? " w" : " b");

    qDebug() << "完整FEN字符串: " << fen;
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

// aigameboard.cpp
bool AIGameBoard::canAttackKing(Stone* attacker, int kingId)
{
    Stone* king = getStoneById(kingId);
    if (!attacker || !king || attacker->dead() || king->dead()) { return false; }

    // 获取攻击者和帅的位置
    int aCol = attacker->col();
    int aRow = attacker->row();
    int kCol = king->col();
    int kRow = king->row();

    // 检查是否在同一条线上
    if (aCol != kCol && aRow != kRow) {
        return false; // 不在同一条直线
    }

    int count = 0; // 中间棋子计数
    int min, max;

    // 检查横向攻击
    if (aRow == kRow) {
        min = qMin(aCol, kCol);
        max = qMax(aCol, kCol);
        for (int c = min + 1; c < max; c++) {
            if (getPieceId(c, aRow) != -1) { count++; }
        }
    }
    // 检查纵向攻击
    else if (aCol == kCol) {
        min = qMin(aRow, kRow);
        max = qMax(aRow, kRow);
        for (int r = min + 1; r < max; r++) {
            if (getPieceId(aCol, r) != -1) { count++; }
        }
    }

    // 根据棋子类型判断攻击条件
    switch (attacker->type()) {
    case Stone::CHE: // 车：需要无遮挡
        return count == 0;
    case Stone::PAO: // 炮：需要正好一个炮架
        return count == 1;
    case Stone::MA: // 马：特殊移动规则
        // 马走日，这里简化处理
        return (qAbs(aCol - kCol) == 1 && qAbs(aRow - kRow) == 2) || (qAbs(aCol - kCol) == 2 && qAbs(aRow - kRow) == 1);
    case Stone::BING: // 兵：只能向前攻击
        if (attacker->isRed()) {
            return (aCol == kCol && aRow - kRow == 1) || (aRow == kRow && qAbs(aCol - kCol) == 1);
        } else {
            return (aCol == kCol && kRow - aRow == 1) || (aRow == kRow && qAbs(aCol - kCol) == 1);
        }
    default:
        return false;
    }
}

bool AIGameBoard::hasImmediateCheckmateMove()
{
    int kingId = m_aiIsRed ? 4 : 20; // 红方AI攻击黑将(4)，黑方AI攻击红帅(20)

    // 检查所有AI方棋子是否能攻击对方将帅
    for (int i = 0; i < 32; i++) {
        Stone* stone = getStoneById(i);
        if (stone && !stone->dead() && stone->isRed() == m_aiIsRed) {
            if (canAttackKing(stone, kingId)) {
                qDebug() << "发现将军机会! 棋子ID:" << i << "类型:" << stone->type() << "位置:(" << stone->col() << ","
                         << stone->row() << ")";
                return true;
            }
        }
    }
    return false;
}

void AIGameBoard::performCheckmateMove()
{
    int kingId = m_aiIsRed ? 4 : 20; // 确定攻击目标

    // 查找所有可以将军的移动
    for (int i = 0; i < 32; i++) {
        Stone* stone = getStoneById(i);
        if (stone && !stone->dead() && stone->isRed() == m_aiIsRed) {
            if (canAttackKing(stone, kingId)) {
                Stone* king = getStoneById(kingId);

                // 执行将军移动
                int fromCol = stone->col();
                int fromRow = stone->row();
                int toCol = king->col();
                int toRow = king->row();

                emit checkWarning(!m_aiIsRed); // 对方被将军

                qDebug() << "执行将军移动: 棋子" << i << "从(" << fromCol << "," << fromRow << ")"
                         << "到(" << toCol << "," << toRow << ")";

                int killId = getPieceId(toCol, toRow);
                moveStone(fromCol, fromRow, toCol, toRow);
                emit computerMoved(i, fromCol, fromRow, toCol, toRow, killId);
                return;
            }
        }
    }
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
