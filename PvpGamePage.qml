//双人对战
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: _pvp
    width: 600
    height: 800

    property var buttonStyle: QtObject {
        property int width: 200
        property int height: 50
        property int radius:5
        property int fontSize:28
        property string fontFamily: "FZKai\-Z03"
    }

    //窗口过大时填充背景
    Rectangle {
        anchors.fill: parent
        color: "#f0e0d0"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        //返回按钮
        Button {
            Layout.alignment: Qt.AlignLeft
            Layout.topMargin: 5
            Layout.leftMargin: 5
            text:"返回首页"
            onClicked: {
                stackView.pop()
                stackView.push("HomePage.qml")
            }
            background: Rectangle {
                color: "#808080"
                radius: 5
                border.color: "#696969"
            }
        }

        Text {
            text: "双人对战模式"
            font {
                family: "FZKai\-Z03"
                pixelSize: 40
                bold: true
            }
            color: "#696969"
            Layout.alignment: Qt.AlignHCenter
        }

        //棋盘区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            width: Math.min(parent.width, 600)
            height: Math.min(parent.height, 660)

            ChessBoard {
                id: _board
                anchors.centerIn: parent
            }
        }

        //底部按钮区域
        RowLayout{
            Layout.fillWidth: true
            Layout.bottomMargin: 10
            Layout.alignment: Qt.AlignHCenter
            spacing: 50
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
                    stackView.pop()
                    stackView.push("PvpGamePage.qml")
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
                    //悔棋逻辑
                }
            }
        }
    }
}
