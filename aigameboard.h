#pragma once
#include "board.h"
#include <QObject>
#include <QTimer>
#include <QVector>
#include "EleeyeEngine.h"

class Step;

class AIGameBoard : public Board
{
    Q_OBJECT
    Q_PROPERTY(bool aiIsRed READ aiIsRed WRITE setAiIsRed NOTIFY aiIsRedChanged)
    Q_PROPERTY(int aiLevel READ aiLevel WRITE setAiLevel NOTIFY aiLevelChanged)
    QML_ELEMENT
public:
    explicit AIGameBoard(QObject* parent = nullptr);
    ~AIGameBoard();

    bool aiIsRed() const;
    void setAiIsRed(bool isRed);

    int aiLevel() const;
    void setAiLevel(int level);

    Q_INVOKABLE void startNewGame();
    Q_INVOKABLE void computerMove();

    // FEN字符串生成函数
    Q_INVOKABLE QString getBoardFEN() const;

signals:
    void aiIsRedChanged();
    void aiLevelChanged();
    void computerMoved(int moveId, int fromCol, int fromRow, int toCol, int toRow, int killId);

private:
    Step* getBestMove();
    void getAllPossibleMove(QVector<Step*>& steps);
    int getMinScore(int level, int curMin);
    int getMaxScore(int level, int curMax);
    int score();
    void fakeMove(Step* step);
    void unfakeMove(Step* step);

    // FEN生成辅助函数
    QString pieceToFEN(int type, bool isRed) const;
    QString rowToFEN(int row) const;

    bool m_aiIsRed = false;
    int m_aiLevel = 3;
    EleeyeEngine* m_engine; // 声明引擎成员
};

class Step : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit Step(QObject* parent = nullptr);
    Step(int moveId, int killId, int rowFrom, int colFrom, int rowTo, int colTo, QObject* parent = nullptr);

    int moveId() const;
    int killId() const;
    int rowFrom() const;
    int colFrom() const;
    int rowTo() const;
    int colTo() const;

private:
    int m_moveId;
    int m_killId;
    int m_rowFrom;
    int m_colFrom;
    int m_rowTo;
    int m_colTo;
};
