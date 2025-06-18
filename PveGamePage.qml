//人机对战
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: _pve
    // width: parent.width
    // height: parent.height
    anchors.fill: parent

    property var buttonStyle: QtObject {
        property int width: 200
        property int height: 50
        property int radius: 5
        property int fontSize:28
        property string fontFamily: "FZKai\-Z03"
    }

    //窗口过大时填充背景
    Rectangle {
        anchors.fill: parent
        color: "#f0e0d0"
    }

    ChessBoard{
        id:_board
        width: 600
        height: 660
        anchors.centerIn: parent

        //创建棋子
        Component.onCompleted: {
            var cw = _board.width/8
            var ch = _board.height/9
            //Init.initializeBoard(_board, cw, ch)
        }
    }

    Button {
        text: "返回首页"
        anchors {
            top: parent.top
            left: parent.left
            margins: 5
        }
        onClicked: {
            stackView.pop(stackView.currentItem)//先清除上一级界面
            stackView.push("HomePage.qml")
        }
        background: Rectangle{
            color: "#808080"
            radius: 5
            border.color:"#696969"
        }
    }

    Text {
        text: "人机对战模式"
        font {
            family:"FZKai\-Z03"
            pixelSize: 40
            bold: true
        }
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 20
        }
        color: "#696969"
    }

    RowLayout{
        anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                margins: 12
            }
            spacing: 50
            RoundButton {
                text: qsTr("重开")
                radius: buttonStyle.radius
                anchors {
                    bottom: parent.bottom
                    //horizontalCenter: parent.horizontalCenter
                    margins: 12
                }
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    stackView.pop(stackView.currentItem)//先清除上一级界面
                    stackView.push("PveGamePage.qml")
                }
            }
            RoundButton {
                text: qsTr("悔棋")
                radius: buttonStyle.radius
                anchors {
                    bottom: parent.bottom
                   // leftMargin:parent.leftMargin
                    margins: 12
                }
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                }
            }
        }
}
