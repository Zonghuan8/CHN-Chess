import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Item {
    id: _rulesPage
    width: stackView.width//parent是stackView
    height: stackView.height

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
            anchors.margins: _rulesPage.width/30
            clip: true

            ColumnLayout {
                spacing: _rulesPage.width/21
                width: parent.width
                Text {
                    text: "中国象棋规则"
                    font {
                        family: "FZKai-Z03"
                        pixelSize: _rulesPage.width/10
                        bold: true
                    }
                    Layout.alignment: Qt.AlignHCenter
                    color: "#8B4513"
                }


                //规则内容
                Text {
                    text: "  中国象棋是一种源于中国古代的传统棋类游戏，
  使用方形棋盘和红黑两色圆形棋子进行对弈，
  以下是基本规则："
                    font {
                        family:"阿里巴巴普惠体 2.0 115 Black"
                        pixelSize: _rulesPage.width/22
                    }
                    wrapMode: Text.Wrap//换行
                    //Layout.fillWidth: true
                }

                Text {
                    text: "棋盘结构："
                    font {
                        family: "FZKai-Z03"
                        pixelSize:  _rulesPage.width/22
                        bold: true
                    }
                    //wrapMode: Text.Wrap
                }

                Text {
                    text: "  中国象棋棋盘由九道直线和十道横线交叉组成。
  棋盘中间有一条‘楚河汉界’将双方分隔。
  棋子摆在交叉点上。"
                    font {
                        family: "阿里巴巴普惠体 2.0 115 Black"
                        pixelSize:  _rulesPage.width/22
                    }
                    wrapMode: Text.Wrap
                    //Layout.fillWidth: true
                }

                Text {
                    text: "棋子介绍："
                    font {
                        family: "FZKai-Z03"
                        pixelSize:  _rulesPage.width/22
                        bold: true
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "1. 将/帅：只能在九宫格内活动，可以上下左右
 移动一格。
2. 士/仕：只能在九宫格内斜线移动一格。
3. 象/相：不能过河，走'田'字格，但如果'田'字
 中间有棋子（绊象腿）则不能走。
4. 马：走'日'字格，有'蹩马腿'的限制。
5. 车：可以沿直线任意移动。
6. 炮：移动方式与车相同，但吃子时必须跳过
 一个棋子（炮架）。
7. 兵/卒：未过河时只能前进一格，过河后可以
 左右移动。"
                    font {
                        family: "阿里巴巴普惠体 2.0 115 Black"
                        pixelSize:  _rulesPage.width/22
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "游戏目标:"
                    font.bold: true
                    font {
                        family: "FZKai-Z03"
                        pixelSize:  _rulesPage.width/22
                        bold: true
                    }
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "     吃掉对方的'将'或'帅'即为胜利。"
                    font {
                        family: "阿里巴巴普惠体 2.0 115 Black"
                        pixelSize:  _rulesPage.width/22
                    }
                    wrapMode: Text.Wrap
                }

                Button {
                    id:_backButton
                    text: "返回首页"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin:  _rulesPage.width/22
                    onClicked: {
                        clickAnim.start()//点击动画
                        player.click.play()
                        stackView.pop()
                        stackView.push("HomePage.qml")
                    }
                  background: Rectangle {
                      id:btnBg
                      color: _backButton.down ? "#696969":"#808080"
                      radius: 5
                      border.color: "#696969"
                      border.width: 2
                    }
                    font {
                        family: "FZKai-Z03"
                        pixelSize:  _rulesPage.width/22
                    }
                }
                SequentialAnimation {
                    id: clickAnim
                    PropertyAnimation {
                        target: _backButton
                        property: "scale"
                        to: 1.0
                        duration: 500
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
    }
}




