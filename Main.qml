import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "settings.js" as Controller

ApplicationWindow{
    id:root
    width: 600
    height: 800
    minimumWidth: 600
    minimumHeight: 800
    visible: true
    title: qsTr("中国象棋")

    property string currentPage: "home"//当前页面
    property string currentGameMode: "pvp"//当前游戏模式

    StackView {
        id: stackView
        initialItem: "HomePage.qml"
        anchors.fill: parent
    }

    Component.onCompleted: {
      Controller.initial(true,true);    //开始时音乐默认为开
    }
}
