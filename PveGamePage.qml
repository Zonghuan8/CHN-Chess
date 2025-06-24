import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: _pve
    width: parent.width
    height: parent.height

    property var buttonStyle: QtObject {
        property int width: parent.width/3
        property int height: width/3
        property int radius: 5
        property int fontSize:_pve.width/20

        property string fontFamily: "FZKai\-Z03"
    }

    Image {
        source: "qrc:/images/bg.png"
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        spacing: _pve.width/120

        //返回按钮
        Button {
            Layout.alignment: Qt.AlignLeft

            text:"返回首页"
            Layout.leftMargin: 15
            Layout.topMargin: 20

            onClicked: {
                stackView.pop()
                stackView.push("HomePage.qml")
            }
            background: Rectangle {
                color: "#808080"
                radius: 5
                border.color: "#696969"
            }
        }

        Text {
            text: "人机对战模式"
            font {
                family: "FZKai\-Z03"
                pixelSize: _pve.width/10
                bold: true
            }
            color: "#696969"
            Layout.alignment: Qt.AlignHCenter
        }

        //棋盘区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            width: parent.width
            height: parent.height

            //使用新的AI棋盘组件
            AIChessBoard {
                id: _aiBoard
                anchors.centerIn: parent
            }
        }

        //底部按钮区域
        RowLayout {
            Layout.bottomMargin: 50
            Layout.margins: 0
            Layout.topMargin: 0
            Layout.leftMargin: 0
            clip: false
            Layout.fillHeight: false
            Layout.maximumHeight: 65533
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: _pve.width/12
            RoundButton {
                text: qsTr("重开")
                radius: buttonStyle.radius
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                font {
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {

                    _aiBoard.boardLogic.initGame();

                    stackView.pop()
                    stackView.push("PveGamePage.qml")

                }
            }
            RoundButton {
                text: qsTr("悔棋")
                radius: buttonStyle.radius
                Layout.preferredWidth: buttonStyle.width
                Layout.preferredHeight: buttonStyle.height
                font {
                    pixelSize: buttonStyle.fontSize
                    family: buttonStyle.fontFamily
                }
                onClicked: {
                    // 悔棋逻辑
                    _aiBoard.boardLogic.undoMove();
                }
            }
        }
    }
}
