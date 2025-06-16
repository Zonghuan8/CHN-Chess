import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "initial.js" as Init

ApplicationWindow{
    id:root
    width: 700
    height: 800
    minimumWidth: 640
    minimumHeight: 800
    visible: true
    title: qsTr("中国象棋")
    color: "#f0e0d0"

    //窗口过大时填充背景
    Rectangle {
           anchors.fill: parent
           color: "#f0e0d0"
    }

    ChessBoard{
        id: board
        width: 540
        height: 600
        anchors.centerIn: parent

        //创建棋子
        Component.onCompleted: {
            var cw = board.width/8
            var ch = board.height/9
            Init.initializeBoard(board, cw, ch)
        }
    }
}
