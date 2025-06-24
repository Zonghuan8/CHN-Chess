import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "settings.js" as Controller

ApplicationWindow{
    id:root
    width: (height/10)*6
    height: Screen.height
    minimumWidth: width
    minimumHeight: height
    maximumWidth: width
    maximumHeight: height
    visible: true
    title: qsTr("中国象棋")


    StackView {//StackView会将加载的页面作为其子项
        id: stackView
        // width:parent.width //StackView的内容区域会自动匹配窗口大小，因此无需直接绑定到root。
        // height: parent.height
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

    MusicPlayer {
       id: player
    }

    Component.onCompleted: {
      Controller.initial(true,true);//开始时音乐默认为开
    }
}
