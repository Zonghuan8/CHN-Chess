import QtQuick
import QtQuick.Window

Window {
    width: 800
    height: 700
    visible: true
    title: "中国象棋"
    // color: "#f0e0d0"

    ChessBoard{
        id:_board
        ChessPiece{
            id:_piece
            size:_board.width/9
            text:"车"
            centerX:0
            centerY:0
        }
        ChessPiece{
            id:_piece1
            size:_board.width/9
            text:"车"
            isRed:false
            centerX:0
            centerY:_board.height
        }
    }


}
