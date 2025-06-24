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
            opacity: 0.2
        }
        color:"#FFFFFF"

        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 30

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
                    text: "   中国象棋是一种源于中国古代的传统棋类游戏，使用方形棋盘和红黑两色
圆形棋子进行对弈,以下是基本规则："
                    font {
                        family:"阿里巴巴普惠体 2.0 115 Black"
                        pixelSize: 17
                    }
                    wrapMode: Text.Wrap//换行
                }

                Text {
                    text: "棋盘结构："
                    font {
                        family: "FZKai-Z03"
                        pixelSize: 20
                        bold: true
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "  中国象棋棋盘由九道直线和十道横线交叉组成，"+
                          "棋盘中间有一条‘楚河汉界’
将双方分隔。"+
                    "棋子摆在交叉点上。"
                    font {
                        family: "阿里巴巴普惠体 2.0 115 Black"
                        pixelSize: 17
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "棋子介绍："
                    font {
                        family: "FZKai-Z03"
                        pixelSize: 20
                        bold: true
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text:"1.帅/将：只能在'米'字九宫格内活动，可上可下，可左可右，每次走动只能\n"+
                         "按竖线或横线走动一格来吃掉对方棋子。需要注意的是，帅与将不能在同一直\n"+
                         "线上直接对面，否则走方判负。\n"+
                         "2.仕/士：是帅（将）的贴身保镖，只能在九宫内米字线上走动，行棋路径是\n"+
                         "九宫内的斜线上,吃掉位于这些斜线上的对方棋子。\n"+
                         "3.相/象：走法是每次循对角线走两格，俗称“象走田”。活动范围限于“河界”\n"+
                         "以内的本方阵地，不能过河。如果“田”字中央有一个棋子，就不能走，俗称\n"+
                         "“塞象眼”。只能吃掉在本方田字对角上且未“塞象眼”位置的敌方棋子。\n"+
                         "4.车：威力最大，无论横线、竖线均可行走，只要无子阻拦，步数不受限制，\n"+
                         "可吃掉线上的敌方棋子，有“一车十子寒”之称。\n"+
                         "5.马：走“日”字，即可以在棋盘上横竖线组成的“日”字的对角上相互走，\n"+
                         "吃子也是在日字对角上的。但如果马要去的方向正前方有棋子挡住，俗称\n"+
                         "“别马腿”,则不能走到该位置吃子。\n"+
                         "6.炮：不吃子的时候，走动与车完全相同。吃子方式特殊，炮与被吃子之\n"+
                         "间必须隔一个棋子，进行跳吃，俗称“架炮”或“炮打隔子”。\n"+
                         "7.兵/卒：未过河前，只能向前一步步走，吃子只能吃前一步的棋子。过河\n"+
                         "以后，除不能后退外，允许左右移动，但也只能一次一步，吃子只能吃左\n"+
                         "右前方一步的棋子。\n"+
                         "在游戏中，一方的棋子攻击对方的帅/将，并在下一着要把它吃掉，称为\n"+
                         "“照将”，或简称“将”，被“照将”的一方必须立即“应将”，即用自己的着\n"+
                         "法去化解被“将”的状态,如果被“照将”而无法“应将”，就算被“将死”，\n"+
                         "则判负。除帅/将外，其他棋子都可以听任对方吃，或主动送吃。\n"
                    font {
                        family: "阿里巴巴普惠体 2.0 115 Black"
                        pixelSize: 17
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "游戏目标:"
                    font.bold: true
                    font {
                        family: "FZKai-Z03"
                        pixelSize: 20
                        bold: true
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "     吃掉对方的'将'或'帅'即为胜利。"
                    font {
                        family: "阿里巴巴普惠体 2.0 115 Black"
                        pixelSize: 17
                    }
                    wrapMode: Text.Wrap
                }

                Button {
                    text: "返回首页"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    onClicked: {
                        player.click.play()
                        stackView.pop()
                        stackView.push("HomePage.qml")
                    }
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




