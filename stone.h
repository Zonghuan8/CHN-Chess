//棋子类 stone.h
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

    // 暴露属性给QML
    Q_PROPERTY(int row READ row NOTIFY rowChanged)
    Q_PROPERTY(int col READ col NOTIFY colChanged)
    Q_PROPERTY(TYPE type READ type CONSTANT)
    Q_PROPERTY(bool red READ isRed CONSTANT)
    Q_PROPERTY(bool dead READ isDead WRITE setDead NOTIFY deadChanged)
    Q_PROPERTY(int id READ id CONSTANT)

    // Getter方法
    int row() const { return _row; }
    int col() const { return _col; }
    TYPE type() const { return _type; }
    bool isRed() const { return _red; }
    bool isDead() const { return _dead; }
    int id() const { return _id; }

    // Setter方法
    void setRow(int row);
    void setCol(int col);
    void setDead(bool dead);

    TYPE name() const;
    void init(int id);
signals:
    void rowChanged();
    void colChanged();
    void deadChanged();

private:
    int _row;
    int _col;
    TYPE _type;
    bool _red;
    bool _dead;
    int _id;
    bool _isPiece;
    bool _isSelected;
};
