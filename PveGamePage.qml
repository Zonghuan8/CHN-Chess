//人机对战
import QtQuick
import QtQuick.Controls

Item {
    id: _pve
    // width: parent.width
    // height: parent.height
    anchors.fill: parent

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
}
