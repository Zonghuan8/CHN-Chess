import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow{
    id:root
    width: 600
    height: 800
    minimumWidth: 600
    minimumHeight: 800
    visible: true
    title: qsTr("中国象棋")
    color: "#f0e0d0"

    property string currentPage: "home"//当前页面
    property string currentGameMode: "pvp"//当前游戏模式

    StackView {
        id: stackView
        initialItem: "HomePage.qml"
        anchors.fill: parent
    }

    Image {
        anchors.fill: parent
        source: "qrc:/images/background.png"
        opacity: 0.3
    }
}
