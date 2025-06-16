import QtQuick

Item {
    id:root
    width: size
    height: size

    property real centerX: 0//设置棋子位置
    property real centerY: 0
    property bool selected: false//是否选中
    property string text: "兵"//棋子文字
    property bool isRed: true//是否红方
    property real size: 40//棋子尺寸

    signal clickPiece(var text,var centerX,var centerY);

    //计算位置（使中心点位于交叉线）
    x: centerX - width / 2
    y: centerY - height / 2

    //棋子主体
    Rectangle {
        id: _piece
        //source: root.isRed ? "qrc:/image/red_chess.PNG" : "qrc:/image/black_chess.PNG"
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: width
        radius: width / 2
        color: root.isRed ? "#FFC0C0" : "#E0E0E0"
        border.color: selected ? "gold" : (root.isRed ? "#B22222" : "#333333")
        border.width: selected ? 4 : 2

        /*Component.onCompleted: {
            console.log("Image width:", width, "height:", height)
        }*/

        //棋子文字
        Text {
            id: pieceText
            anchors.centerIn: parent
            text: root.text
            font {
                family: parent.isRed ? "隶书" : "SimSun"
                pixelSize: parent.height * 0.6
                bold: true
            }
            color: root.isRed ? "#B22222" : "#000000"
        }
        TapHandler{
            onTapped:{
                root.selected = !root.selected //切换选中状态
                root.clickPiece(text,centerX,centerY)
                console.log(root.text+"  centerX:"+root.centerX+";  "+"centerX:"+root.centerY)
            }
        }
    }
}
