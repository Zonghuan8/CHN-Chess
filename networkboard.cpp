// NetworkBoard.cpp
#include "networkboard.h"
#include <QNetworkInterface>
#include <QTimer>

NetworkBoard::NetworkBoard(QObject *parent)
    : Board(parent)
    , m_server(nullptr)
    , m_socket(nullptr)
    , m_isHost(false)
    , m_connectionStatus("未连接")
    , m_myColorIsRed(true)
{
    connect(this, &Board::stonesChanged, this, [this]() {
        if (m_socket && m_socket->state() == QAbstractSocket::ConnectedState) {
        }
    });

    // 添加回合变化的信号连接
    connect(this, &Board::redTurnChanged, this, &NetworkBoard::myTurnChanged);
}

NetworkBoard::~NetworkBoard()
{
    disconnectGame();
}

void NetworkBoard::createGame()
{
    if (m_server || m_socket) return;

    m_server = new QTcpServer(this);
    connect(m_server, &QTcpServer::newConnection, this, &NetworkBoard::onNewConnection);

    m_isHost = true;
    setMyColor(true); // 主机为红方

    if (m_server->listen(QHostAddress::Any, 12345)) {
        m_isHost = true;
        emit isHostChanged();
        setConnectionStatus("等待对手连接...");
        setMyColor(true); // 主机默认为红方

        // 获取本机IP地址
        QString ipAddress;
        QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();
        for (const QHostAddress &address : ipAddressesList) {
            if (address != QHostAddress::LocalHost && address.toIPv4Address()) {
                ipAddress = address.toString();
                break;
            }
        }
        if (ipAddress.isEmpty()) { ipAddress = QHostAddress(QHostAddress::LocalHost).toString(); }

        emit gameReady();
    } else {
        setConnectionStatus("创建游戏失败: " + m_server->errorString());
    }
}

void NetworkBoard::joinGame(const QString &address)
{
    // 1. 安全检查：避免重复连接
    if (m_socket != nullptr) {
        qDebug() << "警告：已存在Socket连接，请先断开当前连接";
        return;
    }

    // 2. 初始化客户端状态
    m_isHost = false;     // 明确标记为客户端（非主机）
    setMyColor(false);    // 强制客户端为黑方
    emit isHostChanged(); // 通知QML属性更新
    qDebug() << "[客户端] 颜色设置为:" << (m_myColorIsRed ? "红方" : "黑方");

    // 3. 创建Socket并连接信号槽
    m_socket = new QTcpSocket(this);
    connect(m_socket, &QTcpSocket::readyRead, this, &NetworkBoard::onReadyRead);
    connect(m_socket, &QTcpSocket::disconnected, this, &NetworkBoard::onDisconnected);
    connect(m_socket, &QTcpSocket::errorOccurred, this, [this](QAbstractSocket::SocketError error) {
        qDebug() << "Socket错误:" << error << m_socket->errorString();
        onErrorOccurred(error);
    });

    // 4. 更新UI状态
    setConnectionStatus("正在连接...");
    qDebug() << "正在连接到主机:" << address;

    // 5. 连接成功后的处理
    connect(m_socket, &QTcpSocket::connected, this, [this]() {
        setConnectionStatus("已连接");
        qDebug() << "成功连接到主机";

        // 发送初始化消息（可选）
        QByteArray initMsg;
        QDataStream out(&initMsg, QIODevice::WriteOnly);
        out << QString("CLIENT_READY") << m_myColorIsRed;
        m_socket->write(initMsg);

        emit gameReady(); // 通知QML游戏准备就绪
    });

    // 6. 开始连接（端口需与主机一致）
    const quint16 port = 12345;
    m_socket->connectToHost(address, port);
}

void NetworkBoard::disconnectGame()
{
    if (m_server) {
        m_server->close();
        m_server->deleteLater();
        m_server = nullptr;
    }

    if (m_socket) {
        m_socket->disconnectFromHost();
        if (m_socket->state() != QAbstractSocket::UnconnectedState) { m_socket->waitForDisconnected(1000); }
        m_socket->deleteLater();
        m_socket = nullptr;
    }

    m_isHost = false;
    emit isHostChanged();
    setConnectionStatus("已断开连接");
}

void NetworkBoard::onNewConnection()
{
    if (!m_server || m_socket) return;

    m_socket = m_server->nextPendingConnection();
    connect(m_socket, &QTcpSocket::readyRead, this, &NetworkBoard::onReadyRead);
    connect(m_socket, &QTcpSocket::disconnected, this, &NetworkBoard::onDisconnected);
    connect(m_socket,
            QOverload<QAbstractSocket::SocketError>::of(&QTcpSocket::errorOccurred),
            this,
            &NetworkBoard::onErrorOccurred);

    setConnectionStatus("已连接");

    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_5_15);
    out << QString("INIT");
    out << this; // 序列化整个棋盘（包含回合状态）

    m_socket->write(block);

    emit gameReady();
}

void NetworkBoard::onReadyRead()
{
    if (!m_socket) return;

    QDataStream in(m_socket);
    in.setVersion(QDataStream::Qt_5_15);

    while (m_socket->bytesAvailable() > 0) {
        QString messageType;
        in >> messageType;

        if (messageType == "MOVE") {
            int netFromCol, netFromRow, netToCol, netToRow;
            bool receivedTurnState;
            in >> netFromCol >> netFromRow >> netToCol >> netToRow >> receivedTurnState;

            // 同步回合状态
            setRedTurn(receivedTurnState);

            // 执行移动
            moveStone(netFromCol, netFromRow, netToCol, netToRow);

            // 解锁操作权限
            unlockOperations();
        } else if (messageType == "CHAT") {
            QString chatMessage;
            in >> chatMessage;
            emit messageReceived(chatMessage);
        } else if (messageType == "INIT") {
            in >> this; // 反序列化整个棋盘
        }
    }
}

void NetworkBoard::onDisconnected()
{
    setConnectionStatus("对手已断开");
    QTimer::singleShot(3000, this, [this]() { disconnectGame(); });
}

void NetworkBoard::onErrorOccurred(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error)
    setConnectionStatus("连接错误: " + m_socket->errorString());
    disconnectGame();
}

void NetworkBoard::sendMove(int fromCol, int fromRow, int toCol, int toRow)
{
    // 添加状态断言
    if (m_isHost && !m_myColorIsRed && isRedTurn()) {
        qCritical() << "错误：主机为红方，但回合状态为黑方！强制纠正";
        setRedTurn(true); // 强制同步
    }

    bool correctNewTurn = !isRedTurn();
    qDebug() << "[主机] 严格校验：移动前=" << isRedTurn() << "发送的回合状态=" << correctNewTurn;

    // 锁定操作权限
    lockOperations();

    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out << QString("MOVE") << fromCol << fromRow << toCol << toRow << correctNewTurn;
    m_socket->write(block);

    // 立即切换回合状态
    setRedTurn(correctNewTurn);

    // 启动超时检测（可选）
    QTimer::singleShot(30000, this, [this]() {
        if (m_operationLocked) {
            qWarning() << "对手响应超时！";
            unlockOperations();
            setConnectionStatus("对手响应超时");
        }
    });
}

void NetworkBoard::sendMessage(const QString &message)
{
    if (!m_socket || m_socket->state() != QAbstractSocket::ConnectedState) return;

    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_5_15);

    out << QString("CHAT") << message;
    m_socket->write(block);
}

void NetworkBoard::setConnectionStatus(const QString &status)
{
    if (m_connectionStatus != status) {
        m_connectionStatus = status;
        emit connectionStatusChanged();
    }
}

// 在文件末尾添加
QDataStream &operator<<(QDataStream &out, const NetworkBoard *board)
{
    out << board->isRedTurn(); // 序列化回合状态
    out << static_cast<const Board *>(board);
    return out;
}

QDataStream &operator>>(QDataStream &in, NetworkBoard *board)
{
    bool redTurn;
    in >> redTurn;
    board->setRedTurn(redTurn);

    in >> static_cast<Board *>(board);
    return in;
}
