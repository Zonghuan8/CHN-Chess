import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtCore

Item {
    id: _aboutPage
    width: stackView.width//parent是stackView
    height: stackView.height

    Rectangle {
        anchors.fill: parent
        Image {
            source: "qrc:/images/bg.png"
            anchors.fill: parent
            opacity: 0.3
        }
        color:"#f0e0d0"

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.8
            spacing: 20

            Text {
                text: "中国象棋"
                font {
                    family: "FZKai-Z03"
                    pixelSize: _aboutPage.width/10
                    bold: true
                }
                Layout.alignment: Qt.AlignHCenter
                color: "#8B4513"
            }

            Text {
                text: "版本: 1.0.0"
                font {
                    family: "FZKai-Z03"
                    pixelSize: _aboutPage.width/20
                }
                Layout.alignment: Qt.AlignHCenter
                color: "#696969"
            }

            Text {
                text: "中国象棋作为中华民族传统文化的瑰宝，承载着数千年的历史与智慧，其蕴含的战略思维、"+
                      "逻辑推理和博弈艺术，深受各年龄段人群喜爱。开发中国象棋游戏项目，"+
                      "旨在让更多人体验象棋的魅力。"
                font {
                    family: "FZKai-Z03"
                    pixelSize: _aboutPage.width/20
                }
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Text {
                text: "开发者团队:"
                font {
                    family: "FZKai-Z03"
                    pixelSize: _aboutPage.width/20
                    bold: true
                }
                Layout.alignment: Qt.AlignLeft
                color: "#8B4513"
            }

            Text {
                text: "• 张键 (2023051604093)\n• 张慧芝 (2023051604088)\n• 李露露 (2023051604116)"
                font {
                    family: "FZKai-Z03"
                    pixelSize: _aboutPage.width/20
                }
                Layout.alignment: Qt.AlignLeft
                color: "#696969"
            }

            Text {
                text: "指导老师: 龚伟"
                font {
                    family: "FZKai-Z03"
                    pixelSize: _aboutPage.width/20
                }
                Layout.alignment: Qt.AlignLeft
                color: "#696969"
            }

            Text {
                text: "联系我们: open-src@qq.com"
                font {
                    family: "FZKai-Z03"
                    pixelSize: _aboutPage.width/20
                }
                Layout.alignment: Qt.AlignLeft
                color: "#1E90FF"
            }

            Button {
                id:_backButton
                text: "返回首页"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin:_aboutPage.width/20
                onClicked: {
                    clickAnim.start()//点击动画
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
                  pixelSize: _aboutPage.width/20
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
