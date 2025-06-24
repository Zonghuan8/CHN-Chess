//AnimationEffect.qml
import QtQuick 6.0

Rectangle {
    property real centerX: 0
    property real centerY: 0
    property color effectColor: "#ff0000"
    property int square: 50
    property int delay: 0

    id:_animEff
    width: square
    height: square
    radius: _animEff.width / 2
    color: "transparent"
    border.color: effectColor
    border.width: 3
    opacity: 0.8

    x: centerX - _animEff.width / 2
    y: centerY - _animEff.height / 2

    //并行动画
    ParallelAnimation {
        id: anim
        running: true
        NumberAnimation {
            target: parent
            property: "scale"
            from: 1.0
            to: 3.0
            duration: 800
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: parent
            property: "opacity"
            from: 0.8
            to: 0.0
            duration: 800
            easing.type: Easing.OutQuad
        }
        onFinished: parent.destroy()
    }

    //定时器
    Timer {
        id: timer
        interval: delay
        running: true
        onTriggered: parent.opacity = 0.8
    }

    //组件销毁时停止动画
    Component.onDestruction: {
        anim.running = false
        timer.running = false
    }
}
