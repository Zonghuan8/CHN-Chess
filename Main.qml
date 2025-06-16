import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "initial.js" as Init

ApplicationWindow{
    id:root
    width: 800
    height: 700
    visible: true
    title: qsTr("中国象棋")
    color: "#f0e0d0"

    ChessBoard{
        id: board
        //创建棋子
        Component.onCompleted: {
            var cw = root.width*0.1
            var ch = root.height*0.1
            Init.initializeBoard(board, cw, ch)
        }
    }
}
