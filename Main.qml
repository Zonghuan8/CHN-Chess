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
    maximumHeight: 800
    maximumWidth: 600
    visible: true
    title: qsTr("中国象棋")

    StackView {
        id: stackView
        initialItem: "HomePage.qml"
        anchors.fill: parent

        //推送和弹出操作的简单淡出式过渡
        pushEnter: Transition {
             PropertyAnimation {
                 property: "opacity"
                 from: 0
                 to:1
                 duration: 150
             }
         }
         pushExit: Transition {
             PropertyAnimation {
                 property: "opacity"
                 from: 1
                 to:0
                 duration: 150
             }
         }
         popEnter: Transition {
             PropertyAnimation {
                 property: "opacity"
                 from: 0
                 to:1
                 duration:150
             }
         }
         popExit: Transition {
             PropertyAnimation {
                 property: "opacity"
                 from: 1
                 to:0
                 duration:150
             }
         }
    }

    Player {
       id: musicPlayer
    }

    Component.onCompleted: {
      Controller.initial(true,true);//开始时音乐默认为开
    }
}
