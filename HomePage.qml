//主页面
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Particles

Item {
    id: _home
    width: parent.width
    height: parent.height
    // anchors.fill: parent

    property var buttonStyle: QtObject {
        property int width: 200
        property int height: 50
        property int radius: 10
        property int fontSize: 24
        property string fontFamily: "FZMiaoWuS\-GB"
    }

    signal gameModeSelected(string mode)//通知主窗口选择了游戏模式

    Rectangle{
        id: _homeBackground
        anchors.fill: parent
        radius: 4
        Image {
            anchors.fill:parent
            source: "qrc:/images/home_background.png"
        }

        //竹叶粒子系统
        ParticleSystem {
            id: _bamboo
            anchors.fill: parent

            //发射器：从顶部随机位置发射竹叶
            Emitter {
                id: leafEmitter
                system: _bamboo
                anchors.top: parent.top
                width: parent.width
                height: 1
                emitRate: 3//每秒发射0.5片叶子
                lifeSpan: 9000//叶子生命周期10秒
                size: 30
                velocity: PointDirection { y: 40; xVariation: 20 }//向下飘落并轻微水平摆动
                acceleration: PointDirection { x: 0; y: 10 }//缓慢下落
            }

            //竹叶精灵动画
            ItemParticle {
                system: _bamboo
                delegate: SpriteSequence {
                    id: _bamboosa
                    width: 40
                    height: 40
                    interpolate: true
                    Sprite {
                        name: "leaf1"
                        source: "qrc:/images/bb1.png"
                        frameCount: 1
                        frameDuration: 1000
                        to: {"leaf2": 1}
                    }
                    Sprite {
                       name: "leaf2"
                       source: "qrc:/images/bb2.png"
                       frameCount: 1
                       frameDuration: 1000
                       to: {"leaf3": 1}
                    }
                    Sprite {
                        name: "leaf3"
                        source: "qrc:/images/bb3.png"
                        frameCount: 1
                        frameDuration: 1000
                        to: {"leaf1": 1}
                    }

                    //旋转动画
                    RotationAnimation on rotation {
                        from: -10
                        to: 10
                        duration: 3000
                        loops: Animation.Infinite
                        direction: RotationAnimation.Alternate
                   }
               }
           }
        }

        ColumnLayout{
            spacing: 20
            anchors.centerIn: parent
            RoundButton {
                text: qsTr("双人对战")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                //onClicked: gameModeSelected("pvp")
                onClicked: {
                    stackView.pop(stackView.currentItem)//先清除上一级界面
                    stackView.push("PvpGamePage.qml")
                }
            }
            RoundButton {
                text: qsTr("人机对战")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                //onClicked: gameModeSelected("pve")
                onClicked: {
                    stackView.pop(stackView.currentItem)
                    stackView.push("PveGamePage.qml")
                }
            }
            RoundButton {
                text: qsTr("游戏规则")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    stackView.pop(stackView.currentItem)
                    stackView.push("")
                }
            }
            RoundButton {
                text: qsTr("联系我们")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    stackView.pop(stackView.currentItem)
                    stackView.push("")
                }
            }
        }
    }
}
