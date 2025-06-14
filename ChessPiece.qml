import QtQuick

Item {
    id:root

    // 基本属性
    property string text: "兵"   // 棋子文字
    property bool isRed: true   // 是否红方
    property real size: 40       // 棋子尺寸

    width: size
    height: size

    // 位置属性（外部控制）
    property real centerX: 0//在主qml中设置棋子位置
    property real centerY: 0

    // 计算位置（使中心点位于交叉线）
    x: centerX - width / 2
    y: centerY - height / 2

    // 棋子主体
    Rectangle {
        id: piece
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: width
        radius: width / 2
        color: root.isRed ? "#FFC0C0" : "#E0E0E0"
        border.color: root.isRed ? "#B22222" : "#333333"
        border.width: 2

        // 棋子文字
        Text {
            id: pieceText
            anchors.centerIn: parent
            text: root.text
            font {
                family: root.isRed ? "楷体" : "宋体"
                pixelSize: parent.height * 0.6
                bold: true
            }
            color: root.isRed ? "#B22222" : "#000000"
        }
    }
}
