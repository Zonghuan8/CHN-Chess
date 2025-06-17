import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow{
    id:root
    width: 600
    height: 800
    minimumWidth: 640
    minimumHeight: 800
    visible: true
    title: qsTr("中国象棋")
    //icon.source:"qrc:/images/icon.png"
    color: "#f0e0d0"

    //property string currentPage: "home"//当前页面
    //property string currentGameMode: "pvp"//当前游戏模式

    StackView {
        id: stackView
        initialItem: "HomePage.qml"
        anchors.fill: parent
    }

    /*
    // 首页
    HomePage {
        id: _home
        width: 700
        height: 800
        anchors.fill: parent
        visible: currentPage === "home"
        onGameModeSelected: function(mode) {
            root.currentPage = "game"
            root.currentGameMode = mode
        }
    }

    //人机对战页面
    PveGamePage{
        id:_pve
        width:700
        height: 800
        anchors.fill: parent
        visible: currentPage === "game" && currentGameMode === "pve"
    }

    //双人对战页面
    PvpGamePage{
        id:_pvp
        width:700
        height: 800
        anchors.fill: parent
        visible: currentPage === "game" && currentGameMode === "pvp"
    }
    */
    ChessBoard{
        id: board
        width: 560
        height: 630
        anchors.centerIn: parent
    }

}
