import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow{
    id:root
    width: 600
<<<<<<< HEAD
    height: 830
    minimumWidth: 600
    minimumHeight: 830
=======
    height: 800
    minimumWidth: 600
    minimumHeight: 800

    // height: 800
    // minimumWidth: 640
    // minimumHeight: 800

>>>>>>> CHN-Chess/main
    visible: true
    title: qsTr("中国象棋")
    // icon.source:"qrc:/images/icon.png"
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

    // 首页
    // HomePage {
    //     id: _home
    //     // width: 700
    //     // height: 800
    //     anchors.fill: parent
    //     visible: currentPage === "home"
    //     onGameModeSelected: function(mode) {
    //         root.currentPage = "game"
    //         root.currentGameMode = mode
    //     }
    // }

<<<<<<< HEAD
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
=======
    // //人机对战页面
    // PveGamePage{
    //     id:_pve
    //     // width:700
    //     // height: 800
    //     anchors.fill: parent
    //     visible: currentPage === "game" && currentGameMode === "pve"
    // }

    // //双人对战页面
    // PvpGamePage{
    //     id:_pvp
    //     // width:700
    //     // height: 800
    //     anchors.fill: parent
    //     visible: currentPage === "game" && currentGameMode === "pvp"
    // }
>>>>>>> CHN-Chess/main
}
