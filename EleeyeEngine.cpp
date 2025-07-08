// EleeyeEngine.cpp
#include "EleeyeEngine.h"
#include <QCoreApplication>

EleeyeEngine::EleeyeEngine(QObject *parent) : QObject(parent), m_engineProcess(new QProcess(this)), m_engineReady(false)
{
    connect(m_engineProcess, &QProcess::readyReadStandardOutput, this, &EleeyeEngine::readStdout);
    connect(m_engineProcess, &QProcess::readyReadStandardError, this, &EleeyeEngine::readStderr);
    connect(m_engineProcess, &QProcess::errorOccurred, this, &EleeyeEngine::handleError);
}

EleeyeEngine::~EleeyeEngine()
{
    if (m_engineProcess->state() == QProcess::Running) {
        sendCommand("quit");
        m_engineProcess->waitForFinished(1000);
    }
}

void EleeyeEngine::startEngine(const QString &enginePath)
{
    if (m_engineProcess->state() == QProcess::Running) {
        emit engineError("Engine is already running");
        return;
    }

    m_engineProcess->start(enginePath);

    if (!m_engineProcess->waitForStarted(3000)) {
        emit engineError("Failed to start engine: " + enginePath);
        qCritical() << "Engine failed to start:" << enginePath;
        return;
    }
    // 初始化引擎
    sendCommand("ucci");
}

void EleeyeEngine::sendCommand(const QString &command)
{
    if (m_engineProcess->state() != QProcess::Running) {
        emit engineError("Engine not running");
        return;
    }

    qDebug() << "Sending command:" << command;
    m_engineProcess->write((command + "\n").toUtf8());
    m_engineProcess->waitForBytesWritten();
}

void EleeyeEngine::setPosition(const QString &fen)
{
    if (fen == "startpos") {
        sendCommand("position startpos");
        m_currentPosition = "startpos";
    } else {
        sendCommand("position fen " + fen);
        m_currentPosition = fen;
    }
}

void EleeyeEngine::think(int depth)
{
    // 设置攻击性参数
    sendCommand("setoption knowledge large");   // 使用最大知识库
    sendCommand("setoption pruning small");     // 减少裁剪，增加搜索广度
    sendCommand("setoption attack_weight 200"); // 增加攻击权重

    sendCommand("go depth " + QString::number(depth) + " attack");
}

void EleeyeEngine::stopThinking()
{
    sendCommand("stop");
}

void EleeyeEngine::quit()
{
    sendCommand("quit");
    m_engineProcess->waitForFinished(1000);
}

void EleeyeEngine::readStdout()
{
    while (m_engineProcess->canReadLine()) {
        QString line = QString::fromUtf8(m_engineProcess->readLine()).trimmed();
        qDebug() << "Engine output:" << line;

        if (line.startsWith("bestmove")) {
            parseBestMove(line);
        } else if (line == "ucciok") {
            m_engineReady = true;
            emit engineInfo("Engine ready");
        } else if (line.startsWith("id") || line.startsWith("option")) {
            // 引擎信息
            emit engineInfo(line);
        }
    }
}

void EleeyeEngine::readStderr()
{
    QString error = QString::fromUtf8(m_engineProcess->readAllStandardError());
    if (!error.isEmpty()) { emit engineError("Engine error: " + error); }
}

void EleeyeEngine::handleError(QProcess::ProcessError error)
{
    QString errorMsg;
    switch (error) {
    case QProcess::FailedToStart:
        errorMsg = "Engine failed to start";
        break;
    case QProcess::Crashed:
        errorMsg = "Engine crashed";
        break;
    case QProcess::Timedout:
        errorMsg = "Engine timed out";
        break;
    case QProcess::WriteError:
        errorMsg = "Write error";
        break;
    case QProcess::ReadError:
        errorMsg = "Read error";
        break;
    default:
        errorMsg = "Unknown error";
    }
    emit engineError(errorMsg);
}

bool EleeyeEngine::isReady() const
{
    return m_engineReady;
}

void EleeyeEngine::parseBestMove(const QString &line)
{
    // bestmove c3c4
    QStringList parts = line.split(' ');
    if (parts.size() < 2) return;

    QString move = parts[1];
    if (move.length() != 4) return; // 标准着法格式：c3c4

    int fromCol, fromRow, toCol, toRow;
    parseMove(move, fromCol, fromRow, toCol, toRow);

    // 检测将军状态
    bool isCheck = line.contains("check");
    if (isCheck) { qDebug() << "将军着法!"; }

    qDebug() << "最佳着法:" << move << "=> (" << fromCol << "," << fromRow << ")"
             << "-> (" << toCol << "," << toRow << ")" << (isCheck ? "将军" : "");

    emit bestMoveReceived(fromCol, fromRow, toCol, toRow, isCheck);
}

void EleeyeEngine::parseMove(const QString &move, int &fromCol, int &fromRow, int &toCol, int &toRow)
{
    fromCol = columnToIndex(move[0]);
    toCol = columnToIndex(move[2]);

    // 翻转行号：引擎0=棋盘9（红方底线），9=棋盘0（黑方底线）
    fromRow = 9 - move[1].digitValue();
    toRow = 9 - move[3].digitValue();

    qDebug() << "坐标转换: " << move << "=> (" << fromCol << "," << fromRow << ")"
             << "-> (" << toCol << "," << toRow << ")";
}

int EleeyeEngine::columnToIndex(QChar col) const
{
    // a=0, b=1, ..., i=8
    return col.toLatin1() - 'a';
}

int EleeyeEngine::rowToIndex(QChar row) const
{
    // '0'=0, '1'=1, ..., '9'=9
    return row.digitValue();
}
