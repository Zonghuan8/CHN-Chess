import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtCore

Item {

    property alias about: _about
    property alias rules: _rules

    // 关于对话框（开发者信息）
    Dialog {
        id: _about
        title: "关于中国象棋"
        width: 600
        height: 400
        modal: true

        ScrollView {
            anchors.fill: parent
            anchors.margins: 10
            clip: true

            ColumnLayout {
                width: _about.width - 20
                spacing: 15

                Text {
                    text: "中国象棋 v1.0"
                    font.bold: true
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "这是一款中国象棋游戏，中国象棋是起源于中国的传统两人对战棋类游戏，拥有2000多年历史。"
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Text {
                    text: "开发者信息:"
                    font.bold: true
                    font.pixelSize: 16
                }

                Text {
                    text: "张键  2023051604093\n张慧芝2023051604088\n李露露2023051604116"
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Text {
                    text: "指导老师: 龚伟"
                    Layout.fillWidth: true
                }

                Text {
                    text: "联系我们:chessgame@example.com"
                    Layout.fillWidth: true
                }

                Text {
                    text: "Copyright © 2025"
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "返回"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: _about.close()
                }
            }
        }
    }

   // 规则对话框
    Dialog {
        id: _rules
        title: "中国象棋规则说明"
        width: 800
        height: 600
        modal: true

        ScrollView {
            id: scrollView
            anchors.fill: parent
            anchors.margins: 10
            clip: true

        Column {
            id: rulesContent
            width: scrollView.width - 20
            spacing: 20
            padding: 20

            Text {
                text: "中国象棋规则"
                font.pointSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            // 规则内容
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
                text: "返回"
                width:120
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: _rules.close()
            }
        }
        }
    }
}
