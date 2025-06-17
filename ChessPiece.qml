import QtQuick

Item {
    id:root
    width: 64
    height: 64

    property real centerX: 0//设置棋子位置
    property real centerY: 0
    property bool selected: false//是否选中
    property string text: "兵"//棋子文字
    property bool isRed: true//是否红方
    property int size: 56

    //计算位置（使中心点位于交叉线）
    x: centerX - width / 2
    y: centerY - height / 2

    //棋子主体
    Image {
        id: _piece
        source: root.isRed ? "qrc:/images/red_chess.png" : "qrc:/images/black_chess.png"
        anchors.fill: parent
        width: 56
        height: 56

        Rectangle {
            radius: width / 2
            color: root.isRed ? "#FFC0C0" : "#E0E0E0"
            //border.color: selected ? "gold" : (root.isRed ? "#B22222" : "#333333")
            //border.width: selected ? 4 : 2
        }

        //棋子文字
        Text {
            id: pieceText
            anchors.centerIn: parent
            text: root.text
            font {
                family: root.isRed ? "FZKai-Z03" : "FZKai-Z03"//终端输入：fc-list : family查看可用字体
                pixelSize: 38
                bold: true
            }
            color: root.isRed ? "#B22222" : "#000000"
        }

        // TapHandler{
        //     onTapped:{
        //         root.clickPiece(text,centerX,centerY)
        //         console.log(root.text+"  centerX:"+root.centerX+";  "+"centerX:"+root.centerY)
        //     }
        // }

    }
}
