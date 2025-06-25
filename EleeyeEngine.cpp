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
        qCritical() << "Engine failed to start:" << enginePath; // 添加日志
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
    sendCommand("go depth " + QString::number(depth));
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

    int moveId = -1; // 需要根据实际位置计算
    int killId = -1; // 需要根据目标位置计算

    emit bestMoveReceived(moveId, fromCol, fromRow, toCol, toRow, killId);
}

// EleeyeEngine.cpp
void EleeyeEngine::parseMove(const QString &move, int &fromCol, int &fromRow, int &toCol, int &toRow)
{
    // 着法格式示例：c3c4
    // 引擎坐标系：左下角(0,0)是黑方底线，右上角(8,9)是红方底线
    // 项目坐标系：左上角(0,0)是黑方底线，右下角(8,9)是红方底线

    // 列转换：a=0, b=1, ..., i=8（相同）
    fromCol = columnToIndex(move[0]);
    toCol = columnToIndex(move[2]);

    // 行转换：翻转Y轴（9 - 引擎行号）
    fromRow = 9 - rowToIndex(move[1]);
    toRow = 9 - rowToIndex(move[3]);
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
