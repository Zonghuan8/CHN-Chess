import QtQuick
import QtQuick.Window

Window {
    width: 800
    height: 700
    visible: true
    title: "中国象棋"
    // color: "#f0e0d0"

    ChessBoard{
        id:board
    }
}
