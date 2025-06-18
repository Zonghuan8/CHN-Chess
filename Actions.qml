import QtQuick
import QtQuick.Controls
import "setting.js" as Controller

Item {

    property alias music: _music
    property  alias sound:_sound
    property alias quit: _quit

    property  alias rules:_rules
    property alias about: _about

    property bool musicEnabled: true
    property bool soundEnabled: true
    // 动作
    Action {
        id: _music
        text:"音乐"
        icon.name: musicEnabled ? "audio-volume-high" : "audio-volume-muted"
        onTriggered: {
            musicEnabled = !musicEnabled
            Controller.toggleMusic(musicEnabled)
            Controller.playBgMusic()
        }
    }

    Action {
        id: _sound
        text: "音效"
        icon.name: soundEnabled ? "audio-volume-high" : "audio-volume-muted"
        onTriggered: {
            soundEnabled = !soundEnabled
            Controller.toggleSound(soundEnabled)
            Controller.playMoveSound()
            Controller.playCaptureSound()
        }
    }

    Action {
        id: _quit
        text: "退出"
        icon.name: "application-exit"
        shortcut: StandardKey.Quit
        onTriggered: Qt.quit()
    }

    Action {
        id: _rules
        text: "游戏规则"
        icon.name: "help-contents"
    }

    Action {
        id: _about
        text: "关于"
        icon.name: "help-about"
    }
}


