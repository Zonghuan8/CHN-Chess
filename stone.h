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
    bool isPiece() { return _isPiece; }
    bool isSeleceted() { return _isSelected; }

    // Setter方法
    void setRow(int row);
    void setCol(int col);
    void setDead(bool dead);
    void setIsSelected(bool isSelected);

    TYPE name() const;
    void init(int id);
signals:
    void rowChanged();
    void colChanged();
    void deadChanged();
    void isSelectedChanged();

private:
    int _row;         //行
    int _col;         //列
    TYPE _type;       //棋子类型
    bool _red;        //是否红方
    bool _dead;       //是否被吃
    int _id;          //棋子id
    bool _isPiece;    //是否为棋子
    bool _isSelected; //是否被选择
};
