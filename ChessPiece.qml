//棋子
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id:root
    width: stackView.width*0.1
    height: root.width

    property real centerX: 0//设置棋子位置
    property real centerY: 0
    property bool selected: false//是否选中
    property string text: "兵"//棋子文字
    property bool isRed: true//是否红方
    property int size: root.width*0.1
    //计算位置（使中心点位于交叉线）
    x: centerX - width / 2
    y: centerY - height / 2

    //棋子主体
    Image {
        id: _piece
        source: root.isRed ? "qrc:/images/red_chess.png" : "qrc:/images/black_chess.png"
        smooth: true
        BrightnessContrast{//高度对比度
            anchors.fill:_piece
            source: _piece
            brightness: 0.01
            contrast: -0.01
        }
        anchors.fill: parent
        width: parent.width
        height: parent.height

        Rectangle {
            id: glowEffect
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            visible: root.selected

            //发光边框，使用径向渐变
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.isRed ? "#FFFF0080" : "#00FFFF80" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            //color: root.isRed ? "#FFC0C0" : "#E0E0E0"
        }

        //棋子文字
        Text {
            id: pieceText
            anchors.centerIn: parent
            text: root.text
            font {
                family: root.isRed ? "FZKai-Z03" : "FZKai-Z03"//终端输入：fc-list : family查看可用字体
                pixelSize: _piece.width*0.68
                bold: true
            }
            color: root.isRed ? "#B22222" : "#000000"
        }
    }
    //选中时的缩放效果
    scale: selected ? 1.1 : 1.0
        Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    //棋子阴影效果
    DropShadow{
        anchors.fill: _piece
        source: _piece
        horizontalOffset: 5
        verticalOffset: 5
        radius:8
        samples: parent.width*0.02
        color: "#80000000"
    }
}

