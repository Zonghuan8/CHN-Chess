// NetworkBoard.h
#pragma once
#include "board.h"
#include <QTcpServer>
#include <QTcpSocket>
#include <QDataStream>

class NetworkBoard : public Board
{
    Q_OBJECT
    Q_PROPERTY(bool isHost READ isHost NOTIFY isHostChanged)
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)
    Q_PROPERTY(bool myColorIsRed READ myColorIsRed NOTIFY myColorIsRedChanged)
    Q_PROPERTY(bool myTurn READ myTurn NOTIFY myTurnChanged) // 添加这个属性
    Q_PROPERTY(bool operationLocked READ operationLocked NOTIFY operationLockedChanged) // 新增操作锁定状态
    QML_ELEMENT

public:
    explicit NetworkBoard(QObject *parent = nullptr);
    ~NetworkBoard();

    bool myTurn() const
    {
        // 当前玩家颜色与回合状态匹配时才能操作
        return (m_myColorIsRed && isRedTurn()) || (!m_myColorIsRed && !isRedTurn());
    }

    friend QDataStream &operator<<(QDataStream &out, const NetworkBoard *board);
    friend QDataStream &operator>>(QDataStream &in, NetworkBoard *board);

    bool operationLocked() const { return m_operationLocked; }
    Q_INVOKABLE void createGame();
    Q_INVOKABLE void joinGame(const QString &address);
    Q_INVOKABLE void disconnectGame();
    Q_INVOKABLE void setMyColor(bool isRed)
    {
        m_myColorIsRed = isRed;
        emit myColorIsRedChanged();
        emit myTurnChanged();
    }

    bool isHost() const { return m_isHost; }
    QString connectionStatus() const { return m_connectionStatus; }
    bool myColorIsRed() const { return m_myColorIsRed; }

    Q_INVOKABLE void sendMove(int fromCol, int fromRow, int toCol, int toRow);
    Q_INVOKABLE void sendMessage(const QString &message);

signals:
    void operationLockedChanged();

    void myTurnChanged();
    void isHostChanged();
    void connectionStatusChanged();
    void myColorIsRedChanged();
    void opponentMoveReceived(int fromCol, int fromRow, int toCol, int toRow);
    void messageReceived(const QString &message);
    void gameReady();

private slots:
    void lockOperations()
    { // 锁定操作
        m_operationLocked = true;
        emit operationLockedChanged();
    }

    void unlockOperations()
    { // 解锁操作
        m_operationLocked = false;
        emit operationLockedChanged();
    }
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();
    void onErrorOccurred(QAbstractSocket::SocketError error);

private:
    bool m_operationLocked = false; // 新增操作锁定状态
    void setConnectionStatus(const QString &status);

    QTcpServer *m_server;
    QTcpSocket *m_socket;
    bool m_isHost;
    QString m_connectionStatus;
    bool m_myColorIsRed = true; // 默认红色
};
