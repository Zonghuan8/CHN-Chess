import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "setting.js" as Controller

ApplicationWindow {
    id: window
    title: "中国象棋"
    width: 800
    height: 600
    visible: true


    // 背景音乐
    MediaPlayer {
        id: bgMusic
        source: "qrc:/sound/bgm.mp3"   //背景音乐
        loops: MediaPlayer.Infinite
    }

    // 音效
    SoundEffect {
        id: moveSound
        source: "qrc:/sound/move.wav"     //移动音效
    }

    SoundEffect {
        id: captureSound
        source: "qrc:/sound/capture.wav"     //吃子音效
    }

    menuBar: MenuBar {
      Menu {
        title: qsTr("设置")
        MenuItem { action: actions.music }
        MenuItem { action: actions.sound }
        MenuItem { action: actions.quit }
      }
      Menu {
        title: qsTr("Help")
        MenuItem { action: actions.rules }
        MenuItem { action: actions.about }

      }
    }

    Actions {
      id: actions

      about.onTriggered: content.dialogs.about.open()
      rules.onTriggered: content.dialogs.rules.open()
    }

    //Content Area
    Content {
      id:content
      anchors.fill: parent
    }

    Component.onCompleted: {
      Controller.initial(true,true); //开始时音乐默认为开,播放音乐
      Controller.playBgMusic()
      Controller.playMoveSound()
      Controller.playCaptureSound()

    }
}



