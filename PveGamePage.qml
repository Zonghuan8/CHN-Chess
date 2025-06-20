// //人机对战
// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// import Chess

// Item {
//     id: _pve
//     width: 600
//     height: 800

//     property var buttonStyle: QtObject {
//         property int width: 200
//         property int height: 50
//         property int radius: 5
//         property int fontSize:28
//         property string fontFamily: "FZKai\-Z03"
//     }

//     Image {
//         source: "qrc:/images/bg.png"
//         anchors.fill: parent
//     }

//     ColumnLayout {
//         anchors.fill: parent
//         spacing: 5

//         //返回按钮
//         Button {
//             Layout.alignment: Qt.AlignLeft
//             Layout.topMargin: 5
//             Layout.leftMargin: 5
//             text:"返回首页"
//             onClicked: {
//                 stackView.pop()
//                 stackView.push("HomePage.qml")
//             }
//             background: Rectangle {
//                 color: "#808080"
//                 radius: 5
//                 border.color: "#696969"
//             }
//         }

//         Text {
//             text: "人机对战模式"
//             font {
//                 family: "FZKai\-Z03"
//                 pixelSize: 40
//                 bold: true
//             }
//             color: "#696969"
//             Layout.alignment: Qt.AlignHCenter
//         }

//         //棋盘区域
//         Item {
//             Layout.fillWidth: true
//             Layout.fillHeight: true
//             Layout.alignment: Qt.AlignCenter
//             width: Math.min(parent.width, 600)
//             height: Math.min(parent.height, 660)

//             AIGameBoard {
//                 id: chess
//                 aiIsRed: false // AI执黑方
//                 aiLevel: 3     // AI难度

//                 // 监听AI移动信号
//                 onComputerMoved: (moveId, fromCol, fromRow, toCol, toRow, killId) => {
//                     // 创建移动动画
//                     createMoveAnimation(moveId, fromCol, fromRow, toCol, toRow, killId);
//                 }

//                 // 创建移动动画函数
//                 function createMoveAnimation(moveId, fromCol, fromRow, toCol, toRow, killId) {
//                     // 查找移动的棋子
//                     var piece = null;
//                     for (var i = 0; i < chess.stones.length; i++) {
//                         if (chess.stones[i].id === moveId) {
//                             piece = chess.stones[i];
//                             break;
//                         }
//                     }
//                     if (!piece) return;

//                     // 创建动画
//                     var anim = moveAnimation.createObject(boardBackground, {
//                         piece: piece,
//                         fromX: (fromCol + 1) * square,
//                         fromY: (fromRow + 1) * square,
//                         toX: (toCol + 1) * square,
//                         toY: (toRow + 1) * square,
//                         killId: killId
//                     });
//                     anim.start();
//                 }
//             }

//             Component {
//                 id: moveAnimation

//                 Item {
//                     property Stone piece
//                     property real fromX
//                     property real fromY
//                     property real toX
//                     property real toY
//                     property int killId

//                     NumberAnimation on fromX {
//                         id: xAnim
//                         from: fromX
//                         to: toX
//                         duration: 500
//                     }

//                     NumberAnimation on fromY {
//                         id: yAnim
//                         from: fromY
//                         to: toY
//                         duration: 500
//                     }

//                     function start() {
//                         xAnim.start();
//                         yAnim.start();
//                     }

//                     onToXChanged: {
//                         piece.col = toCol;
//                         piece.row = toRow;

//                         // 处理吃子
//                         if (killId !== -1) {
//                             var killedPiece = chess.getStoneById(killId);
//                             if (killedPiece) {
//                                 killedPiece.dead = true;
//                             }
//                         }

//                         // 切换回合
//                         chess.setRedTurn(!chess.isRedTurn);

//                         // 销毁动画对象
//                         destroy(1000);
//                     }
//                 }
//             }

//             ChessBoard {
//                 id: _board
//                 anchors.centerIn: parent

//                 //胜利动画组件
//                 Rectangle {
//                     id: victoryOverlay
//                     anchors.fill: parent
//                     color: "#80000000"//半透明黑色
//                     visible: false
//                     z: 100//确保在最上层

//                     property string winnerText: ""
//                     property color winnerColor: winnerText === "红方" ? "#ff0000" : "#0000ff"

//                     //胜利文本容器
//                     Item {
//                         anchors.centerIn: parent

//                         //发光效果：使用多个文本层
//                         Text {
//                             id: glowText
//                             anchors.centerIn: parent
//                             text: victoryOverlay.winnerText + "胜利!"
//                             font.pixelSize: 60
//                             font.bold: true
//                             color: victoryOverlay.winnerColor
//                             opacity: 0.7
//                         }

//                         //主文本
//                         Text {
//                             id: victoryText
//                             anchors.centerIn: parent
//                             text: victoryOverlay.winnerText + "胜利!"
//                             font.pixelSize: 60
//                             font.bold: true
//                             color: "white"
//                             style: Text.Outline
//                             styleColor: "#40000000"
//                         }
//                     }

//                     //进入动画
//                     SequentialAnimation {
//                         id: victoryAnimation
//                         running: false

//                         //淡入
//                         NumberAnimation {
//                             target: victoryOverlay
//                             property: "opacity"
//                             from: 0
//                             to: 1
//                             duration: 1000
//                         }

//                         //文字跳动
//                         ParallelAnimation {
//                             loops: Animation.Infinite
//                             SequentialAnimation {
//                                 NumberAnimation {
//                                     target: victoryText
//                                     property: "scale"
//                                     from: 1.0
//                                     to: 1.1
//                                     duration: 500
//                                     easing.type: Easing.InOutQuad
//                                 }
//                                 NumberAnimation {
//                                     target: victoryText
//                                     property: "scale"
//                                     from: 1.1
//                                     to: 1.0
//                                     duration: 500
//                                     easing.type: Easing.InOutQuad
//                                 }
//                             }

//                             //颜色变化
//                             SequentialAnimation {
//                                 ColorAnimation {
//                                     targets: [victoryText, glowText]
//                                     property: "color"
//                                     from: "white"
//                                     to: victoryOverlay.winnerColor
//                                     duration: 1000
//                                 }
//                                 ColorAnimation {
//                                     targets: [victoryText, glowText]
//                                     property: "color"
//                                     from: victoryOverlay.winnerColor
//                                     to: "white"
//                                     duration: 1000
//                                 }
//                             }
//                         }
//                     }
//                 }

//                 TapHandler {
//                     onTapped: (event) => {
//                     //如果游戏结束，不允许操作
//                     if (victoryOverlay.visible) {
//                         return;
//                     }

//                     // 如果是AI回合，不允许玩家操作
//                     if (!chess.isRedTurn && chess.aiIsRed ||
//                         chess.isRedTurn && !chess.aiIsRed) {
//                         return;
//                     }
//                     }
//                 }
//             }
//         }
//         //底部按钮区域
//         RowLayout{
//             Layout.fillWidth: true
//             Layout.bottomMargin: 10
//             Layout.alignment: Qt.AlignHCenter
//             spacing: 50
//             RoundButton {
//                 text: qsTr("重开")
//                 radius: buttonStyle.radius
//                 Layout.preferredWidth: buttonStyle.width
//                 Layout.preferredHeight: buttonStyle.height
//                 font {
//                     pixelSize: buttonStyle.fontSize
//                     family: buttonStyle.fontFamily
//                 }
//                 onClicked: {
//                     stackView.pop()
//                     stackView.push("PveGamePage.qml")
//                 }
//             }
//             RoundButton {
//                 text: qsTr("悔棋")
//                 radius: buttonStyle.radius
//                 Layout.preferredWidth: buttonStyle.width
//                 Layout.preferredHeight: buttonStyle.height
//                 font {
//                     pixelSize: buttonStyle.fontSize
//                     family: buttonStyle.fontFamily
//                 }
//                 onClicked: {
//                     //悔棋逻辑
//                     _board.boardLogic.undoMove()
//                 }
//             }
//         }
//     }
// }

// 人机对战
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: _pve
    width: 600
    height: 800

    property var buttonStyle: QtObject {
        property int width: 200
        property int height: 50
        property int radius: 5
        property int fontSize: 28
        property string fontFamily: "FZKai\-Z03"
    }

    Image {
        source: "qrc:/images/bg.png"
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        // 返回按钮
        Button {
            Layout.alignment: Qt.AlignLeft
            Layout.topMargin: 5
            Layout.leftMargin: 5
            text: "返回首页"
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
                pixelSize: 40
                bold: true
            }
            color: "#696969"
            Layout.alignment: Qt.AlignHCenter
        }

        // 棋盘区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            width: Math.min(parent.width, 600)
            height: Math.min(parent.height, 660)

            // 使用新的AI棋盘组件
            AIChessBoard {
                id: _aiBoard
                anchors.centerIn: parent
            }
        }

        // 底部按钮区域
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10
            Layout.alignment: Qt.AlignHCenter
            spacing: 50
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
                    _aiBoard.chess.initGame();
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
