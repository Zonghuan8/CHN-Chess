#pragma once
#include <QObject>
#include <QProcess>
#include <QString>
#include <QDebug>
#include <QtQml/qqmlregistration.h>

class EleeyeEngine : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit EleeyeEngine(QObject *parent = nullptr);
    ~EleeyeEngine();

    // 启动引擎
    Q_INVOKABLE void startEngine(const QString &enginePath);

    // 发送命令
    Q_INVOKABLE void sendCommand(const QString &command);

    // 设置棋盘位置
    Q_INVOKABLE void setPosition(const QString &fen = "startpos");

    // 让引擎思考
    Q_INVOKABLE void think(int depth = 12);

    // 停止思考
    Q_INVOKABLE void stopThinking();

    // 退出引擎
    Q_INVOKABLE void quit();

    Q_INVOKABLE bool isReady() const;
signals:
    // 引擎最佳着法信号
    void bestMoveReceived(int moveId, int fromCol, int fromRow, int toCol, int toRow, int killId);

    // 引擎信息信号
    void engineInfo(const QString &info);

    // 引擎错误信号
    void engineError(const QString &error);

private slots:
    void readStdout();
    void readStderr();
    void handleError(QProcess::ProcessError error);

private:
    QProcess *m_engineProcess;
    bool m_engineReady;
    QString m_currentPosition;

    // 解析最佳着法
    void parseBestMove(const QString &line);

    // 解析着法格式
    void parseMove(const QString &move, int &fromCol, int &fromRow, int &toCol, int &toRow);

    // 坐标转换
    int columnToIndex(QChar col) const;
    int rowToIndex(QChar row) const;
};
