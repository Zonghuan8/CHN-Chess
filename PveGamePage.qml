import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: _pve
    width: stackView.width//parent是stackView
    height: stackView.height

    property var buttonStyle: QtObject {
        property int width: _pve.width/3
        property int height: width/3
        property int radius: 5
        property int fontSize:_pve.width/20

        property string fontFamily: "FZKai\-Z03"
    }

    Image {
        source: "qrc:/images/bg.png"
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        //返回按钮
        Button {
            id:_backButton
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 15
            Layout.topMargin: 20
            text:"返回首页"
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

        Text {
            text: "人机对战模式"
            font {
                family: "FZKai\-Z03"
                pixelSize: _pve.width/10
                bold: true
            }
            color: "#696969"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.bottomMargin: 20
        }

        //棋盘区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter

            //使用新的AI棋盘组件
            AIChessBoard {
                id: _aiBoard
                anchors.fill: parent
            }
        }

        //底部按钮区域
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 50
            spacing: _pve.width/12
            RoundButton {
                text: qsTr("重开")
                radius: buttonStyle.radius
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                font {
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    player.click.play()
                    _aiBoard.boardLogic.initGame();

                    stackView.pop()
                    stackView.push("PveGamePage.qml")

                }
            }
            RoundButton {
                text: qsTr("悔棋")
                radius: buttonStyle.radius
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                font {
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    // 悔棋逻辑
                    player.click.play()
                    _aiBoard.boardLogic.undoMove();
                }

            }
        }
    }
}
