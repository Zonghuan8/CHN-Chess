import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "initial.js" as Init

Window {
    id:window
    width: 800
    height: 700
    visible: true
    title: "中国象棋"
    color: "#f0e0d0"

    ChessBoard{
        id: board
        // 创建棋子
        Component.onCompleted: {
            var cw = window.width*0.1
            var ch = window.height*0.1
            Init.initializeBoard(board, cw, ch)
        }
    }
}
