//主页面
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "initial.js" as Init

Item {
    id: _home
    width: 700
    height: 800
    anchors.fill: parent

    property var buttonStyle: QtObject {
        property int width: 200
        property int height: 50
        property int radius: 10
        property int fontSize: 24
        property string fontFamily: "FZMiaoWuS\-GB"
    }

    //signal gameModeSelected(string mode) //通知主窗口选择了游戏模式

    Rectangle{
        id: _homeBackground
        anchors.fill: parent
        radius: 4
        Image {
            anchors.fill:parent
            source: "qrc:/images/home_background.png"
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

    SequentialAnimation{
    }
}
