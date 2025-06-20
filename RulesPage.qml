import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Item {
    id: _rulesPage
    width: 600
    height: 800

    Rectangle{
        anchors.fill: parent
        Image {
            source: "qrc:/images/bg.png"
            anchors.fill: parent
            opacity: 0.3
        }
        color:"#f0e0d0"

        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 15

                Text {
                    text: "中国象棋规则"
                    font {
                        family: "FZKai-Z03"
                        pixelSize: 28
                        bold: true
                    }
                    Layout.alignment: Qt.AlignHCenter
                    color: "#8B4513"
                }


                //规则内容
                Text {
                    text: "中国象棋是一种源于中国古代的传统棋类游戏，使用方形棋盘和红黑两色圆形棋子进行对弈。
                             以下是基本规则："
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "棋盘结构：\n
                    中国象棋棋盘由九道直线和十道横线交叉组成，
                       棋盘中间有一条‘楚河汉界’将双方分隔。
                       棋子摆在交叉点上。"
                    wrapMode: Text.Wrap
                }
                Text {
                    text: "1. 将/帅：只能在九宫格内活动，可以上下左右移动一格。\n" +
                          "2. 士/仕：只能在九宫格内斜线移动一格。\n" +
                          "3. 象/相：不能过河，走'田'字格，但如果'田'字中间有棋子（绊象腿）则不能走。\n" +
                          "4. 马：走'日'字格，有'蹩马腿'的限制。\n" +
                          "5. 车：可以沿直线任意移动。\n" +
                          "6. 炮：移动方式与车相同，但吃子时必须跳过一个棋子（炮架）。\n" +
                          "7. 兵/卒：未过河时只能前进一格，过河后可以左右移动。"
                    width: parent.width
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "游戏目标:"
                    font.bold: true
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "吃掉对方的'将'或'帅'即为胜利。"
                    width: parent.width
                    wrapMode: Text.Wrap
                }

                Button {
                    text: "返回首页"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    onClicked: stackView.pop()
                    background: Rectangle {
                        color: "#808080"
                        radius: 5
                        border.color: "#696969"
                    }
                    font {
                        family: "FZKai-Z03"
                        pixelSize: 18
                    }
                }
            }
        }
    }
}





