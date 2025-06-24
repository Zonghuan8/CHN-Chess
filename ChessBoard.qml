// ChessBoard.qml
import QtQuick
import QtQuick.Controls
import Chess 1.0
import Qt5Compat.GraphicalEffects

Item {
    id: _board
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    property int square: width/10
    property alias boardLogic: chess
    //胜利动画组件
    Rectangle {
        id: victoryOverlay
        anchors.fill: parent
        color: "#80000000"//半透明黑色
        visible: false
        z: 100//确保在最上层

        property string winnerText: ""
        property color winnerColor: winnerText === "红方" ? "#ff0000" : "#0000ff"

        //胜利文本容器
        Item {
            anchors.centerIn: parent

            //发光效果：使用多个文本层
            Text {
                id: glowText
                anchors.centerIn: parent
                text: victoryOverlay.winnerText + "胜利!"
                font.pixelSize: 60
                font.bold: true
                color: victoryOverlay.winnerColor
                opacity: 0.7
            }

            //主文本
            Text {
                id: victoryText
                anchors.centerIn: parent
                text: victoryOverlay.winnerText + "胜利!"
                font.pixelSize: 60
                font.bold: true
                color: "white"
                style: Text.Outline
                styleColor: "#40000000"
            }
        }

        //进入动画
        SequentialAnimation {
            id: victoryAnimation
            running: false

            //淡入
            NumberAnimation {
                target: victoryOverlay
                property: "opacity"
                from: 0
                to: 1
                duration: 1000
            }

            //文字跳动
            ParallelAnimation {
                loops: Animation.Infinite
                SequentialAnimation {
                    NumberAnimation {
                        target: victoryText
                        property: "scale"
                        from: 1.0
                        to: 1.1
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: victoryText
                        property: "scale"
                        from: 1.1
                        to: 1.0
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }

                //颜色变化
                SequentialAnimation {
                    ColorAnimation {
                        targets: [victoryText, glowText]
                        property: "color"
                        from: "white"
                        to: victoryOverlay.winnerColor
                        duration: 1000
                    }
                    ColorAnimation {
                        targets: [victoryText, glowText]
                        property: "color"
                        from: victoryOverlay.winnerColor
                        to: "white"
                        duration: 1000
                    }
                }
            }
        }
    }

    //棋盘背景
    Rectangle {
        id: boardBackground
        height: parent.height
        width:parent.width
        anchors.fill: parent
        color: "#f0e0d0"
        radius: 50
        //设置图片为圆角
        clip:true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: boardBackground.width
                height: boardBackground.height
                radius: boardBackground.radius
            }
        }

        Image {
            id:_bbg
            //anchors.fill: boardBackground
            source: "qrc:/images/background.png"
            opacity: 0.2
        }

        Component {
            id: captureAnimation

            Rectangle {
                id: captureEffect
                property point startPos
                property bool isGeneral: false//是否是将/帅

                width: _board.square
                height: _board.square
                radius: width / 2
                color: "transparent"
                border.color: isGeneral ? "#FFFF00" : "#FF0000"//将军特殊颜色
                border.width: isGeneral ? 5 : 3
                opacity: 0.8

                //将军特殊效果：使用旋转矩形
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -5
                    radius: parent.radius
                    color: "transparent"
                    visible: isGeneral
                    border.color: "#FFFFFF"
                    border.width: 2

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: isGeneral
                    }
                }

                SequentialAnimation {
                    id: anim
                    running: true

                    ParallelAnimation {
                        NumberAnimation {
                            target: captureEffect
                            property: "scale"
                            from: 1.0
                            to: isGeneral ? 2.0 : 1.5//将军放大更多
                            duration: isGeneral ? 500 : 300
                        }
                        NumberAnimation {
                            target: captureEffect
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: isGeneral ? 500 : 300
                        }
                    }
                    ScriptAction {
                        script: captureEffect.destroy()
                    }
                }

                Component.onCompleted: {
                    x = startPos.x - width / 2
                    y = startPos.y - height / 2
                }
            }
        }

        Board {
            id: chess

            //监听游戏结束信号
            onGameOver: (winner) => {
                victoryOverlay.winnerText = winner;
                victoryOverlay.visible = true;
                victoryAnimation.start();
            }

            onStonesChanged: {
                //当棋子状态改变时，检查是否有棋子被吃
                for (var i = 0; i < chess.stones.length; i++) {
                    var stone = chess.stones[i];
                    if (stone.dead && !stone._handledDead) {
                        stone._handledDead = true;

                        //创建吃子动画效果
                        var startX = (stone.col + 1) * _board.square
                        var startY = (stone.row + 1) * _board.square
                        var anim = captureAnimation.createObject(boardBackground, {
                            startPos: Qt.point(startX, startY),
                            isGeneral: (stone.type === Stone.JIANG)//标记是否是将/帅
                        });

                        //如果是将/帅，添加额外效果
                        if (stone.type === Stone.JIANG) {

                            createGeneralCaptureEffect(startX, startY, stone.isRed);
                        }
                    }
                }
            }

            //创建将军被吃的特殊效果
            function createGeneralCaptureEffect(x, y, isRed) {
                //创建多个圆形扩散效果
                for (var i = 0; i < 3; i++) {
                    (function(index) {
                        var delay = index * 200;

                        //创建AnimationEffect实例
                        var effect = Qt.createComponent("AnimationEffect.qml");
                        if (effect.status === Component.Ready) {
                            var obj = effect.createObject(boardBackground, {
                                centerX: x,
                                centerY: y,
                                effectColor: isRed ? "#ff0000" : "#0000ff",
                                square: _board.square,
                                delay: delay
                            });

                            if (!obj) {
                                console.error("Failed to create AnimationEffect object");
                            }
                        } else {
                            console.error("Component not ready:", effect.errorString());
                        }
                    })(i);
                }

            }
        }

        Canvas {
            id: boardCanvas
            width: parent.width
            height:parent.height
            onPaint: {
                var ctx = getContext("2d")
                var cellSize = width / 9

                //清空画布
                ctx.clearRect(0, 0, width, height)

                //绘制网格线
                ctx.strokeStyle = "#000000"
                ctx.lineWidth = 1

                //横线
                for (var row = 1; row <= 10; row++) {
                ctx.beginPath()
                ctx.moveTo(_board.square, _board.square*(row))
                ctx.lineTo(width-_board.square,_board.square*(row))
                ctx.stroke()
                }

                //竖线
                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _board.square, _board.square)
                    ctx.lineTo(col * _board.square, _board.square * 5)//上半部分
                    ctx.stroke()
                }

                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _board.square, 6*_board.square)
                    ctx.lineTo(col * _board.square, 10*_board.square)
                    ctx.stroke()
                }

                ctx.beginPath()
                ctx.moveTo( _board.square, _board.square * 5)
                ctx.lineTo( _board.square, 6*_board.square)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo( 9*_board.square, _board.square * 5)
                ctx.lineTo( 9*_board.square, 6*_board.square)
                ctx.stroke()
                }
            }

        //绘制九宫斜线
        Canvas {
            id: _palaceCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#000000";
                ctx.lineWidth = 2.5;

                //黑方九宫（上）
                ctx.beginPath();
                ctx.moveTo(_board.square*4, _board.square);
                ctx.lineTo(_board.square* 6, _board.square * 3);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_board.square* 6, _board.square);
                ctx.lineTo(_board.square* 4, _board.square*3);
                ctx.stroke();

                //红方九宫（下）
                ctx.beginPath();
                ctx.moveTo(_board.square*4, _board.square*10);
                ctx.lineTo(_board.square*6, _board.square*8);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_board.square* 6, _board.square*10);
                ctx.lineTo(_board.square* 4, _board.square*8);
                ctx.stroke();
            }
        }

        Text {
            id: riverText
            x:4*_board.square
            y:5*_board.square

            anchors.horizontalCenter: parent.horizontalCenter

            font.family: "SimHei"
            font.bold: true
            font.pixelSize: Math.max(_board.square * 0.8, 20)
            text: "楚 河        汉 界"
            color: "#8B4513"

            style: Text.Outline
            styleColor: "#00000011"
        }

        Repeater {
            model: chess.stones
            delegate: ChessPiece {
                centerX: (modelData.col +1)* _board.square
                centerY: (modelData.row +1)*  _board.square
                size: _board.square
                text: {
                          switch(modelData.type) {
                          case Stone.CHE: return "車"
                          case Stone.MA: return "马"
                          case Stone.XIANG: return modelData.isRed ? "相" : "象"
                          case Stone.SHI: return modelData.isRed? "仕" : "士"
                          case Stone.JIANG: return modelData.isRed ? "帅" : "将"
                          case Stone.PAO: return "炮"
                          case Stone.BING: return modelData.isRed ? "兵" : "卒"
                          default: return "?"
                          }
                      }
                isRed: modelData.isRed
                selected: modelData.selected//绑定到Stone的selected属性
                visible: !modelData.dead//死亡棋子不可见
                }
            }
        }

    TapHandler {
        property int selectedPieceId: -1
        property int selectedRow: -1//行坐标
        property int selectedCol: -1//列坐标

        onTapped: (event) => {
// <<<<<<< HEAD
// =======
//             //如果游戏结束，不允许操作
//             if (victoryOverlay.visible) {
//                 return;
//             }

// >>>>>>> CHN-Chess/main
            //chess.deselectPiece();
            var pos = chess.clickPosition(square, event.position.x, event.position.y);
            var boardCol = pos.x - 1;//点击位置的列
            var boardRow = pos.y - 1;//点击位置的行

                      for (var i = 0; i < chess.stones.length; i++) {
                                 var stone = chess.stones[i];
                                 if (stone.id !== -1) {
                                    //正确方式：使用赋值而不是调用函数
                                    stone.selected = false;
                                 }
                             }

            //判断点击位置是否有棋子
            var hasPiece = chess.isPiece(boardCol, boardRow);
            var pieceId = hasPiece ? chess.getPieceId(boardCol, boardRow) : -1;
            var piece = hasPiece ? chess.getStoneById(pieceId) : null;

            console.log("点击位置:", `(${boardCol},${boardRow})`,
                       "有棋子:", hasPiece,
                       piece ? "ID:" + piece.id + " 类型:" + piece.type : "");

            //1. 点击位置有棋子
            if (hasPiece) {
                //1.1 当前没有选中棋子
                if (selectedPieceId === -1) {
                    //检查是否轮到此方走棋(判断颜色)
                    if ((piece.isRed && chess.isRedTurn) || (!piece.isRed && !chess.isRedTurn)) {
                        //选中棋子
                        selectedPieceId = pieceId;
                        selectedCol = boardCol;
                        selectedRow = boardRow;
                        piece.selected = true;

                        console.log("选中棋子:", pieceId, "位置:", `(${selectedCol},${selectedRow})`);
                    } else {
                        console.log("不是当前回合的棋子");
                    }
                }
                //1.2当前已有选中棋子
                else {
                    //获取当前选中棋子对象
                    var selectedPiece = chess.getStoneById(selectedPieceId);

                    //1.2.1点击同一棋子：取消选中
                    if (selectedPieceId === pieceId) {
                        selectedPieceId = -1;
                        selectedRow = -1;
                        selectedCol = -1;
                        console.log("取消选中");
                    }
                    //1.2.2点击己方其他棋子：切换选中
                    else if (piece.isRed === selectedPiece.isRed) {
                        //检查轮次
                        if ((piece.isRed && chess.isRedTurn) || (!piece.isRed && !chess.isRedTurn)) {
                            selectedPiece.selected=false;//取消前一个棋子的选中
                            piece.selected=true;//选中新棋子

                            selectedPieceId = pieceId;
                            selectedCol = boardCol;
                            selectedRow = boardRow;
                            console.log("切换选中:", pieceId, "位置:", `(${selectedCol},${selectedRow})`);
                        } else {
                            console.log("不是当前回合的棋子");
                        }
                    }
                    //1.2.3点击敌方棋子：尝试吃子
                    else {
                        console.log("尝试吃子: 从(", selectedCol, selectedRow, ")到(", boardCol, boardRow, ")");

                        //尝试移动棋子(吃子)
                        if (chess.moveStone(selectedCol, selectedRow, boardCol, boardRow)) {
                            player.captureSound.play()
                            console.log("吃子成功");
                            selectedPieceId = -1;//清除选中状态
                            //不需要手动设置棋子状态，因为移动后棋子位置已经改变
                        } else {
                            console.log("吃子失败，不符合规则");
                            //移动失败保持选中状态
                        }
                    }
                }
            }
            //2.点击空白位置
            else {
                //有选中棋子时尝试移动
                if (selectedPieceId !== -1) {
                    //尝试移动棋子
                    if (chess.moveStone(selectedCol, selectedRow, boardCol, boardRow)) {
                        player.moveSound.play()
                        console.log("移动成功");
                        selectedPieceId = -1;//清除选中状态
                    } else {
                        console.log("移动失败，不符合规则");
                        //移动失败保持选中状态
                    }
                } else {
                    console.log("无选中棋子");
                }
            }
        }
    }
}

