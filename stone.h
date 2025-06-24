#pragma once
#include <QObject>
#include <QtQml/qqml.h>
#include <QtQml/qqmlregistration.h>

class Stone : public QObject
{
    Q_OBJECT

    QML_ELEMENT
public:
    Stone(QObject *parent = nullptr);
    ~Stone();

    enum TYPE { CHE, MA, XIANG, SHI, JIANG, PAO, BING };
    Q_ENUM(TYPE)

    //暴露属性给QML

    Q_PROPERTY(int row READ row WRITE setRow NOTIFY rowChanged)
    Q_PROPERTY(int col READ col WRITE setCol NOTIFY colChanged)
    Q_PROPERTY(bool dead READ dead WRITE setDead NOTIFY deadChanged)

    Q_PROPERTY(bool selected READ selected WRITE setSelected NOTIFY selectedChanged)
    Q_PROPERTY(int id READ id CONSTANT)
    Q_PROPERTY(int type READ type CONSTANT)
    Q_PROPERTY(bool isRed READ isRed CONSTANT)

public:
    int id() const { return m_id; }
    int row() const { return m_row; }
    int col() const { return m_col; }
    bool dead() const { return m_dead; }
    TYPE type() const { return m_type; }
    bool isRed() const { return m_red; }

    //确保声明正确
    bool selected() const { return m_selected; } //读取选中状态
    void setSelected(bool selected);             //设置选中状态

    void init(int id);
    void setRow(int row);
    void setCol(int col);
    void setDead(bool dead);

signals:
    void selectedChanged(); //选中状态改变信号
    void rowChanged();
    void colChanged();
    void deadChanged();

private:
    int m_id = -1;
    int m_row = 0;
    int m_col = 0;
    bool m_dead = false;
    bool m_selected = false; //选中状态
    TYPE m_type;
    bool m_red = false;
};
