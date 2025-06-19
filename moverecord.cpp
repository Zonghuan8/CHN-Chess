// moverecord.cpp
#include "moverecord.h"
#include <QDebug>

MoveRecord::MoveRecord(QObject *parent)
    : QObject(parent)
    , m_moveId(-1)
    , m_fromRow(-1)
    , m_fromCol(-1)
    , m_toRow(-1)
    , m_toCol(-1)
    , m_killId(-1)
    , m_wasDead(false)
{}

MoveRecord::MoveRecord(int moveId,
                       int fromRow,
                       int fromCol,
                       int toRow,
                       int toCol,
                       int killId,
                       bool wasDead,
                       QObject *parent)
    : QObject(parent)
    , m_moveId(moveId)
    , m_fromRow(fromRow)
    , m_fromCol(fromCol)
    , m_toRow(toRow)
    , m_toCol(toCol)
    , m_killId(killId)
    , m_wasDead(wasDead)
{}

MoveRecord::MoveRecord(const MoveRecord &other)
    : QObject(other.parent())
    , m_moveId(other.m_moveId)
    , m_fromRow(other.m_fromRow)
    , m_fromCol(other.m_fromCol)
    , m_toRow(other.m_toRow)
    , m_toCol(other.m_toCol)
    , m_killId(other.m_killId)
    , m_wasDead(other.m_wasDead)
{}

MoveRecord &MoveRecord::operator=(const MoveRecord &other)
{
    if (this != &other) {
        setParent(other.parent());
        m_moveId = other.m_moveId;
        m_fromRow = other.m_fromRow;
        m_fromCol = other.m_fromCol;
        m_toRow = other.m_toRow;
        m_toCol = other.m_toCol;
        m_killId = other.m_killId;
        m_wasDead = other.m_wasDead;
    }
    return *this;
}

bool MoveRecord::operator==(const MoveRecord &other) const
{
    return m_moveId == other.m_moveId && m_fromRow == other.m_fromRow && m_fromCol == other.m_fromCol
           && m_toRow == other.m_toRow && m_toCol == other.m_toCol && m_killId == other.m_killId
           && m_wasDead == other.m_wasDead;
}

int MoveRecord::moveId() const
{
    return m_moveId;
}

int MoveRecord::fromRow() const
{
    return m_fromRow;
}

int MoveRecord::fromCol() const
{
    return m_fromCol;
}

int MoveRecord::toRow() const
{
    return m_toRow;
}

int MoveRecord::toCol() const
{
    return m_toCol;
}

int MoveRecord::killId() const
{
    return m_killId;
}

bool MoveRecord::wasDead() const
{
    return m_wasDead;
}

QString MoveRecord::toString() const
{
    return QString("MoveRecord: ID=%1, From=(%2,%3), To=(%4,%5), KillID=%6, WasDead=%7")
        .arg(m_moveId)
        .arg(m_fromCol)
        .arg(m_fromRow)
        .arg(m_toCol)
        .arg(m_toRow)
        .arg(m_killId)
        .arg(m_wasDead ? "true" : "false");
}
