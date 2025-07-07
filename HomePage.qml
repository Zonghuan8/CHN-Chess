//主页面
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Particles//提供了对粒子系统的支持
import "settings.js" as Controller

Item {
    id: _home
    width: stackView.width//parent是stackView
    height: stackView.height

    property var buttonStyle: QtObject {
        property int width: parent.width/2
        property int height: width/4
        property int radius: 5
        property int fontSize:_home.width/20
        property string fontFamily: "FZMiaoWuS\-GB"
    }

    property bool musicEnabled: true
    property bool soundEnabled: true

    Rectangle{
        id: _homeBackground
        anchors.fill: parent
        radius: 4
        Image {
            anchors.fill:parent
            source: "qrc:/images/home_background.png"
        }

        ToolButton {
            id: settingsButton
            anchors.left:parent.left
            anchors.top:parent.top
            anchors.leftMargin: 19
            anchors.topMargin: 35
            width: _home.width/12
            height:_home.width/12
            Image {
                anchors.fill:parent
                source: "qrc:/images/settings.png"//设置图标路径
            }
            //设置菜单
            Menu {
                id: settingsMenu
                y: parent.height//菜单显示在按钮下方
                x: parent.x//菜单与按钮左对齐

            //音乐控制项
            MenuItem {
                id: musicMenuItem
                text: "音乐"
                icon.name: musicEnabled ? "audio-volume-high" : "audio-volume-muted"
                onTriggered:{
                    player.click.play()
                    musicEnabled = !musicEnabled
                    Controller.toggleMusic(musicEnabled)
                }
            }

            //音效控制项
            MenuItem {
                id: soundMenuItem
                text:"音效"
                icon.name: soundEnabled ? "audio-volume-high" : "audio-volume-muted"
                onTriggered: {
                    player.click.play()
                    soundEnabled = !soundEnabled
                    Controller.toggleSound(soundEnabled)
                }
            }

            MenuItem{
                id: quitItem
                text: "退出"
                icon.name: "application-exit"
                onTriggered: {
                    player.click.play()
                    Qt.quit()
                }
            }
        }
        onClicked: {
            player.click.play()
            settingsMenu.popup()

        }
    }

        //竹叶粒子系统
        ParticleSystem {//逻辑粒子（不会自动渲染）：关联渲染器、发射器，管理共享时间线（对粒子系统的运行进行整体控制）
            id: _bamboo
            anchors.fill: parent

            //渲染器：可视化逻辑粒子
            ItemParticle {//无需指定颜色等，不用ImageParticle
                system: _bamboo
                delegate:
                    //竹叶精灵动画
                    SpriteSequence {
                    id: _bamboosa
                    width: _home.width/13
                    height: _home.width/13
                    interpolate: true
                    Sprite {
                        name: "leaf1"
                        source: "qrc:/images/bb1.png"
                        frameCount: 1
                        frameDuration: 1000
                        to: {"leaf2": 1}//只过渡到一个组，权重设置为1
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
                }
            }

            //发射器
            Emitter {
                id: leafEmitter
                system: _bamboo
                emitRate: 3//每秒发射3个粒子
                lifeSpan: 9000//粒子寿命9秒
                anchors.top: parent.top//从顶部随机位置发射竹叶粒子
                width: parent.width
                height: 1
                size: _home.width/20
                velocity: PointDirection { y: 40; xVariation: 20 }//设定发射速度：向下发射，但各个粒子间的x值可以不同（飘落并轻微水平摆动）
                acceleration: PointDirection { x: 0; y: 10 }//发射粒子的初始加速度
            }
        }//出于性能原因不使用影响器

        ColumnLayout{
            spacing: 20
            anchors.centerIn: parent
            RoundButton {
                width: 70
                text: qsTr("双人对战")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    player.click.play()
                    stackView.pop(stackView.currentItem)//先清除上一级界面
                    stackView.push("PvpGamePage.qml", {
                        width: stackView.width,
                        height: stackView.height
                    });
                }
            }
            RoundButton {
                width: 70
                text: qsTr("人机对战")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                     player.click.play()
                    stackView.pop(stackView.currentItem)
                    stackView.push("PveGamePage.qml")
                }
            }
            RoundButton {
                width: 70
                text: qsTr("网络对战")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    //player.click.play()
                    stackView.pop(stackView.currentItem)
                    stackView.push("NetworkChessBoard.qml")
                }
            }
            RoundButton {
                width: 70
                text: qsTr("游戏规则")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    player.click.play()
                    stackView.pop(stackView.currentItem)
                    stackView.push("RulesPage.qml")
                }
            }
            RoundButton {
                width: 70
                text: qsTr("联系我们")
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                radius: buttonStyle.radius
                font{
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    player.click.play()
                    stackView.pop(stackView.currentItem)
                    stackView.push("AboutPage.qml")
                }
            }
        }
    }
}
