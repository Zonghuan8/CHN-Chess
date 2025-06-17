import QtQuick
import QtQuick.Window
import QtQuick.Controls

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
        width: 560
        height: 630
        anchors.centerIn: parent
    }


}
